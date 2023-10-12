import fs from "fs";
import path from "path";
// @ts-ignore
import { groth16 } from "snarkjs";
import { DKIMVerificationResult } from "@zk-email/helpers/dist/dkim";
import { generateCircuitInputs } from "@zk-email/helpers/dist/input-helpers";
import { packedNBytesToString } from "@zk-email/helpers/dist/binaryFormat";
import { verifyDKIMSignature } from "@zk-email/helpers/dist/dkim";

const PATH_TO_WASM = path.join(__dirname, "../build/email_safe_js/email_safe.wasm");
const PATH_TO_ZKEY = path.join(__dirname, "../build/manual/manual2.zkey");

type CircuitInput = {
  in_padded: string[];
  pubkey: string[];
  signature: string[];
  in_len_padded_bytes: string;
  proposal_idx: number;
  safe_idx: number;
  email_from_idx: number;
  nullifier: string;
  relayer: string;
};

async function generateCircuitInputsFromEmail (rawEmail: Buffer, ): Promise<CircuitInput> {
    const dkimResult = await verifyDKIMSignature(rawEmail);
    let proposalId = dkimResult.message.indexOf(Buffer.from("#")) + 1;
    let safeId = dkimResult.message.indexOf(Buffer.from("@ 0x")) + 2;
    let emailFromId = dkimResult.message.indexOf(Buffer.from("from:")) + 5;
    const circuitInput = generateCircuitInputs({
      body: dkimResult.body,
      message: dkimResult.message,
      bodyHash: dkimResult.bodyHash,
      rsaSignature: dkimResult.signature,
      rsaPublicKey: dkimResult.publicKey,
      maxMessageLength: 1024,
      maxBodyLength: 1536
    });
    return {
      in_padded: circuitInput.in_padded,
      pubkey: circuitInput.pubkey,
      signature: circuitInput.signature,
      in_len_padded_bytes: circuitInput.in_len_padded_bytes,
      proposal_idx: proposalId,
      safe_idx: safeId,
      email_from_idx: emailFromId,
      nullifier: "0",
      relayer: "1",
    };
}


async function main () {
    const startTime = Date.now();
    const rawEmail = fs.readFileSync(path.join(__dirname, "../tests/email2.eml"));
    const circuitInput = await generateCircuitInputsFromEmail(rawEmail);
    const {proof, publicSignals} = await groth16.fullProve(circuitInput, PATH_TO_WASM, PATH_TO_ZKEY, console);
    console.log(await groth16.exportSolidityCallData(proof, publicSignals));
    console.log(`Time taken: ${(Date.now() - startTime) / 1000} seconds`);
    process.exit(0);
}

(async () => {
 await main();
})()