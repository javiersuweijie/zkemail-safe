import dotenv from 'dotenv';
import { EmailClient } from './email_client';
import { generateCircuitInputsFromEmail, generateCallDataFromCircuitInputs } from "@zkemail-safe/circuits/helpers";
import { simpleParser } from 'mailparser';
import mongoose from 'mongoose';
import { EmailStatus, emailSchema } from './models/email';
import path from 'path';
import { verify } from "dkim";
import { sleep } from "./utils";
import { ZkEmailSafeClient } from './eth_client';
import { scrollSepolia } from 'viem/chains';
import { hexToBigInt } from 'viem';
const main = async () => {
    dotenv.config();
    const mongo_uri = process.env.MONGO_URI;
    const mongo_db = process.env.MONGO_DB;
    // connect to mongo db
    await mongoose.connect(`${mongo_uri}/${mongo_db}`, {
        tls: mongo_uri?.includes("localhost") ? false : true,
    });
    console.log("Connected to mongo db");
    const ctx = {
        db: {
            Email: mongoose.model("email", emailSchema),
        },
        ethClient: new ZkEmailSafeClient(scrollSepolia, process.env.PRIVATE_KEY),
    };
    const interval = 10;
    pullEmailLoop(ctx, interval);
    processEmailLoop(ctx, interval);
};
async function pullEmailLoop(ctx, interval) {
    const emailClient = new EmailClient(process.env.EMAIL_USER, process.env.EMAIL_PASSWORD, process.env.EMAIL_HOST, process.env.EMAIL_PORT ?? "995");
    while (true) {
        await sleep(interval);
        console.log("Pulling emails");
        const [stat, statError] = await emailClient.getStat();
        if (statError) {
            console.log(statError);
            continue;
        }
        let [countString, _] = stat.split(" ");
        let count = countString ? +countString : 0;
        console.log("Found ", count, " emails");
        for (let i = 1; i <= count; i++) {
            console.log("Getting email", i);
            const [email, emailError] = await emailClient.getEmailById(i, false);
            if (emailError) {
                console.log(emailError);
                continue;
            }
            console.log("Parsing email");
            const [parsedEmail, parseError] = await parseEmail(email);
            if (parseError) {
                console.log(parseError);
                continue;
            }
            console.log(`Found email from ${JSON.stringify(parsedEmail.from)} with subject ${parsedEmail?.subject}`);
            // const [verified, verificatioError] = await verifyEmailHeaders(email)
            // if (!verified || verificatioError) {
            //     console.log("Unable to verify email header", verificatioError);
            //     continue;
            // }
            const error = await validateEmail(parsedEmail);
            if (error) {
                console.log(error);
                continue;
            }
            await saveEmail(ctx, email);
            console.log("Processed email");
        }
        const updateError = await emailClient.updateChanges();
        if (updateError) {
            console.log(updateError);
        }
    }
}
function hexToBigIntRecursive(obj) {
    console.log(obj);
    if (Array.isArray(obj)) {
        return obj.map(hexToBigIntRecursive);
    }
    else {
        return hexToBigInt(obj);
    }
}
async function processEmailLoop(ctx, interval) {
    while (true) {
        console.log("Processing email");
        await sleep(interval);
        let email = await ctx.db.Email.findOne({ status: EmailStatus.Pending }, null, { sort: { createdAt: 1 } });
        if (!email) {
            console.log("No emails to process");
            continue;
        }
        console.log("Processing email with subject", email?.subject, email?.from);
        try {
            switch (email.type) {
                case "APPROVE": {
                    let circuitInputs = await generateCircuitInputsFromEmail(Buffer.from(email.body, "utf-8"), email.from);
                    let calldata = await generateCallDataFromCircuitInputs(circuitInputs, path.join(__dirname, "../lib/circuit/email_safe.wasm"), path.join(__dirname, "../lib/circuit/email_safe.zkey"));
                    let calldataBn = hexToBigIntRecursive(JSON.parse("[" + calldata + "]"));
                    let [hash, voteError] = await ctx.ethClient.vote(calldataBn[0], calldataBn[1], calldataBn[2], calldataBn[3]);
                    if (!hash || voteError) {
                        console.log(voteError);
                        email.status = EmailStatus.Failed;
                        await email.save();
                        continue;
                    }
                    email.tx_hash = hash;
                    email.status = EmailStatus.Processed;
                    email.save();
                    console.log("Vote tx hash", hash);
                    break;
                }
                case "SEND": {
                    const [_, amount, __, ___, recipient, ____, _____] = email.subject.split(" ");
                    let [hash, proposeError] = await ctx.ethClient.proposeSpendEth(email.safe, recipient, BigInt(Math.round(Number(amount) * 1e18)));
                    if (!hash || proposeError) {
                        console.log(proposeError);
                        continue;
                    }
                    email.tx_hash = hash;
                    email.status = EmailStatus.Processed;
                    email.save();
                    console.log("Propose tx hash", hash);
                    break;
                }
                case "EXECUTE": {
                    const [_, proposalId, __, ___] = email.subject.split(" ");
                    let [hash, executeError] = await ctx.ethClient.execute(email.safe, BigInt(proposalId.slice(1)));
                    if (!hash || executeError) {
                        console.log(executeError);
                        continue;
                    }
                    email.tx_hash = hash;
                    email.status = EmailStatus.Processed;
                    email.save();
                    console.log("Execute tx hash", hash);
                    break;
                }
                default: {
                    throw new Error("Unknown email type");
                }
            }
        }
        catch (e) {
            console.log(e);
            email.status = EmailStatus.Failed;
            await email.save();
        }
    }
}
async function saveEmail(ctx, email) {
    let [parsedMail, err] = await parseEmail(email);
    if (err) {
        console.log(err);
        return;
    }
    else {
        parsedMail?.from;
    }
    if (!parsedMail?.subject) {
        console.log(new Error("Email has no subject"));
        return;
    }
    let [command, parseError] = parseSubject(parsedMail.subject);
    if (parseError) {
        console.log(parseError);
        return;
    }
    const e = new ctx.db.Email({
        type: command?.type,
        from: parsedMail?.from?.value[0].address,
        body: email,
        status: EmailStatus.Pending,
        subject: parsedMail?.subject,
        safe: command?.safeAddress,
    });
    return e.save();
}
async function generateCalldata(email, from) {
    const inputs = await generateCircuitInputsFromEmail(Buffer.from(email, "utf-8"), from);
    const startTime = Date.now();
    try {
        const calldata = await generateCallDataFromCircuitInputs(inputs, path.join(__dirname, "../lib/circuit/email_safe.wasm"), path.join(__dirname, "../lib/circuit/email_safe.zkey"));
        console.log("Time taken: ", (Date.now() - startTime) / 1000, " seconds");
        return [calldata, null];
    }
    catch (e) {
        return [null, new Error(`Error generating calldata: ${e}`)];
    }
}
const approveRegex = /APPROVE #\d+ @ 0x[a-fA-F0-9]+/;
const sendRegex = /SEND \d+(.\d+)? ETH to 0x[a-fA-F0-9]+ using 0x[a-fA-F0-9]+/;
const exeuteRegex = /EXECUTE #\d+ @ 0x[a-fA-F0-9]+/;
function parseSubject(subject) {
    if (subject.match(approveRegex)) {
        const [_, proposalId, __, safeAddress] = subject.split(" ");
        return [{
                type: "APPROVE",
                proposalId,
                safeAddress,
            }, null];
    }
    else if (subject.match(sendRegex)) {
        const [_, amount, __, ___, recipient, ____, safeAddress] = subject.split(" ");
        return [{
                type: "SEND",
                amount,
                recipient,
                safeAddress,
            }, null];
    }
    else if (subject.match(exeuteRegex)) {
        const [_, proposalId, __, safeAddress] = subject.split(" ");
        return [{
                type: "EXECUTE",
                proposalId: proposalId,
                safeAddress,
            }, null];
    }
    else {
        return [null, new Error(`Subject ${subject} does not match pattern`)];
    }
}
async function parseEmail(email) {
    return new Promise(resolve => {
        simpleParser(email, {
            skipHtmlToText: true,
            skipTextToHtml: true,
        }, (err, mail) => {
            if (err)
                resolve([null, new Error(`Error parsing email: ${err}`)]);
            resolve([mail, null]);
        });
    });
}
async function verifyEmailHeaders(mail) {
    return new Promise(resolve => {
        verify(Buffer.from(mail), (err, result) => {
            if (err) {
                return resolve([null, new Error(`Error verifying email: ${err}`)]);
            }
            ;
            return resolve([result[0].verified, null]);
        });
    });
}
function validateEmail(mail) {
    // check if subject matches pattern
    if (mail.subject && !(mail.subject.match(approveRegex) || mail.subject.match(sendRegex) || mail.subject.match(exeuteRegex))) {
        return new Error(`Subject ${mail.subject} does not match pattern`);
    }
    // check if body is too long
    const body = mail.html ? mail.html : (mail.text ?? "");
    if (body.length > 1536)
        return new Error(`Email body too long: ${body.length}`);
    return null;
}
(async () => {
    await main();
})();
