import dotenv from 'dotenv';
import { EmailClient } from './email_client';
import { generateCircuitInputsFromEmail } from "@zkemail-safe/circuits/helpers";
import { simpleParser } from 'mailparser';

const main = async () => {
    dotenv.config();
    const emailClient = new EmailClient(
        process.env.EMAIL_USER!,
        process.env.EMAIL_PASSWORD!,
        process.env.EMAIL_HOST!,
        process.env.EMAIL_PORT ?? "995",
    );
    // console.log(await emailClient.getStat());
    const email = await emailClient.getLastEmail();
    const error = await validateEmail(email);
    if (error) {
        console.log(error);
        return;
    }
    const inputs = await generateCircuitInputsFromEmail(Buffer.from(email, "utf-8"));
    console.log(inputs);
}

async function validateEmail(email: string) {
    return new Promise<Error | null>((resolve, reject) => {
        simpleParser(email, {
            skipHtmlToText: true,
            skipTextToHtml: true,
        }, (err, mail) => {
            if (err) {
                reject(err);
            }
            // check if subject matches pattern
            if (mail.subject) {
                return mail.subject.match(/APPROVE #\d+ @ 0x[a-z0-9]/) ? resolve(null) : resolve(new Error(`Subject ${mail.subject} does not match pattern`));
            }
            // check if body is too long
            const body = mail.html ? mail.html : (mail.text ?? "");
            return body.length > 1536 ? resolve(new Error(`Email body too long: ${body.length}`)) : resolve(null);
        });
});
}

(async () => {
    await main();
})()