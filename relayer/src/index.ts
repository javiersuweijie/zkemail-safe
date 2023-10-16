import dotenv from 'dotenv';
import { EmailClient } from './email_client';
import { generateCircuitInputsFromEmail, generateCallDataFromCircuitInputs } from "@zkemail-safe/circuits/helpers";
import { ParsedMail, simpleParser } from 'mailparser';
import mongoose, { Model } from 'mongoose';
import { Email, EmailStatus, emailSchema } from './models/email';
import path from 'path';
import { exit } from 'process';
import {verify} from "dkim";

interface Context {
    db: {
        Email: Model<Email>,
    }
}

type Result<T> = [T, null] | [null, Error];
type MaybeError = Error | null; 

async function sleep(seconds: number) {
    return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}

const main = async () => {
    dotenv.config();
    const mongo_uri = process.env.MONGO_URI;
    const mongo_db = process.env.MONGO_DB;
    // connect to mongo db
    await mongoose.connect(`mongodb://${mongo_uri}/${mongo_db}`, {
    });
    console.log("Connected to mongo db");
    const ctx: Context = {
        db: {
            Email: mongoose.model<Email>("email", emailSchema),
        }
    };

    const interval = 5;
    pullEmailLoop(ctx, interval);

    exit(0);
}

async function pullEmailLoop(ctx: Context, interval: number) {
    const emailClient = new EmailClient(
        process.env.EMAIL_USER!,
        process.env.EMAIL_PASSWORD!,
        process.env.EMAIL_HOST!,
        process.env.EMAIL_PORT ?? "995",
    );
    while (true) {
        await sleep(interval); 
        const [stat, statError] = await emailClient.getStat();
        if (statError) {
            console.log(statError);
            continue;
        }
        let countString , _ = stat.split(" ") ;
        let count = countString ? +countString : 0;
        for (let i = 0; i < +count; i++) {
            const [email, emailError] = await emailClient.getLastEmail(true);
            if (emailError) {
                console.log(emailError);
                continue;
            }
            const [parsedEmail, parseError] = await parseEmail(email);
            if (parseError) {
                console.log(parseError);
                continue;
            }
            const error = await validateEmail(parsedEmail);
            if (error) {
                console.log(error);
                continue;
            }
            await processEmail(ctx, email);
        }
    }
}

async function processEmail(ctx: Context, email: string) {
    let [parsedMail, err] = await parseEmail(email);
    if (err) {
        console.log(err);
        return
    } else {
        parsedMail?.from
    }
    if (!parsedMail?.subject) {
        console.log(new Error("Email has no subject"));
        return
    }
    let [
        command,
        parseError
    ] = parseSubject(parsedMail.subject);
    if (parseError) {
        console.log(parseError);
        return
    }
    const e = new ctx.db.Email({ 
        from: parsedMail?.from?.value[0].address,
        body: email,
        status: EmailStatus.Pending,
        subject: parsedMail?.subject,
        safe: command?.safeAddress,
    })
    return e.save()
}

async function generateCalldata(email: string): Promise<Result<any>> {
    const inputs = await generateCircuitInputsFromEmail(Buffer.from(email, "utf-8"));
    const startTime = Date.now();
    try {
        const calldata = await generateCallDataFromCircuitInputs(inputs, path.join(__dirname, "../lib/circuit/email_safe.wasm"), path.join(__dirname, "../lib/circuit/email_safe.zkey"))
        console.log("Time taken: ", (Date.now() - startTime) / 1000, " seconds");
        return [calldata, null];
    } catch (e) {
        return [null, new Error(`Error generating calldata: ${e}`)];
    }
}

const approveRegex = /APPROVE #\d+ @ 0x[a-z0-9]/;
const sendRegex = /SEND #\d+ ETH to 0x[a-z0-9] using 0x[a-z0-9]/;

interface ApproveCommand {
    type: "APPROVE";
    proposalId: string;
    safeAddress: string;
}

interface SendCommand {
    type: "SEND";
    amount: string;
    recipient: string;
    safeAddress: string;
}

function parseSubject(subject: string): Result<(ApproveCommand | SendCommand)> {
    if (subject.match(approveRegex)) {
        const [_, proposalId, __, safeAddress] = subject.split(" ");
        return [{
            type: "APPROVE",
            proposalId,
            safeAddress,
        }, null];
    } else if (subject.match(sendRegex)) {
        const [_, amount, __, ___, recipient, ____, safeAddress] = subject.split(" ");
        return [{
            type: "SEND",
            amount,
            recipient,
            safeAddress,
        }, null];
    } else {
        return [null, new Error(`Subject ${subject} does not match pattern`)];
    }
}

async function parseEmail(email: string) {
    return new Promise<Result<ParsedMail>>(resolve => {
        simpleParser(email, {
            skipHtmlToText: true,
            skipTextToHtml: true,
        }, (err, mail) => {
            if (err) resolve([null, new Error(`Error parsing email: ${err}`)]);
            resolve([mail, null]);
        });
    });
}

async function verifyEmailHeaders(mail: string): Promise<Result<boolean>> {
    return new Promise<Result<boolean>>(resolve => {
        verify(Buffer.from(mail), (err, result) => {
            if (err) {
                return resolve([null, new Error(`Error verifying email: ${err}`)]);
            };
            return resolve([result[0].verified, null]);
        });
    })
}

function validateEmail(mail: ParsedMail):MaybeError  {
    // check if subject matches pattern
    if (mail.subject && !(mail.subject.match(approveRegex) || mail.subject.match(sendRegex))) {
        return new Error(`Subject ${mail.subject} does not match pattern`);
    }
    // check if body is too long
    const body = mail.html ? mail.html : (mail.text ?? "");
    if (body.length > 1536) return new Error(`Email body too long: ${body.length}`);
    return null;
}

(async () => {
    await main();
})()