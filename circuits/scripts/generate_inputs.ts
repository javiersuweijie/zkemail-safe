import fs from "fs";
import path from "path";
// @ts-ignore
import { groth16 } from "snarkjs";
import { generateCircuitInputsFromEmail } from "../helpers";

const PATH_TO_WASM = path.join(__dirname, "../build/email_safe_js/email_safe.wasm");
const PATH_TO_ZKEY = path.join(__dirname, "../build/manual/manual2.zkey");

async function main () {
    const startTime = Date.now();
    const rawEmail = fs.readFileSync(path.join(__dirname, "../tests/email4.eml"));
    const circuitInput = await generateCircuitInputsFromEmail(rawEmail, "j.avier.su.weijie@gmail.com");
    const {proof, publicSignals} = await groth16.fullProve(circuitInput, PATH_TO_WASM, PATH_TO_ZKEY, console);
    console.log(await groth16.exportSolidityCallData(proof, publicSignals));
    console.log(`Time taken: ${(Date.now() - startTime) / 1000} seconds`);
    process.exit(0);
}

(async () => {
 await main();
})()