import {pki} from "node-forge";
import { toCircomBigIntBytes } from "@zk-email/helpers/dist/binaryFormat";
import dns from "dns"

async function getPubKey64(domain: string, selector: string) {
    let p = new Promise<string>((resolve, reject) => {
        dns.resolveTxt(selector + "._domainkey." + domain, (err, records) => {
            if (err != null) return reject(err);
            records[0].join("").split(";").forEach((record) => {
                let [key, value] = record.split("=");
                if (key === "p") {
                    resolve(value);
                }
            });
        });
    });
    return p;
}

function pubKey64toCircomBigIntBytes(pubkey64: string) {
    let pem = '-----BEGIN PUBLIC KEY-----\n'+pubkey64+'-----END PUBLIC KEY-----';
    let pubKey = pki.publicKeyFromPem(pem);
    return toCircomBigIntBytes(BigInt(pubKey.n.toString()));
}

async function main() {
    let args = process.argv.slice(2);
    console.log("Pulling and processing DKIM for", args);
    let pubkey64 = await getPubKey64(args[0], args[1]);
    console.log(pubKey64toCircomBigIntBytes(pubkey64));
}

(async () => {
    await main();
})();