import { getPubKey64, pubKey64toCircomBigIntBytes } from "../helpers";

async function main() {
    let args = process.argv.slice(2);
    console.log("Pulling and processing DKIM for", args);
    let pubkey64 = await getPubKey64(args[0], args[1]);
    console.log(pubKey64toCircomBigIntBytes(pubkey64));
}

(async () => {
    await main();
})();