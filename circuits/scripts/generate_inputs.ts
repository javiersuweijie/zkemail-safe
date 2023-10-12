import fs from "fs";
import path from "path";
import { DKIMVerificationResult } from "@zk-email/helpers/dist/dkim";
import { generateCircuitInputs } from "@zk-email/helpers/dist/input-helpers";
import { packedNBytesToString } from "@zk-email/helpers/dist/binaryFormat";
import { verifyDKIMSignature } from "@zk-email/helpers/dist/dkim";


async function main () {
    const rawEmail = fs.readFileSync(path.join(__dirname, "../tests/email.eml"));
    const dkimResult = await verifyDKIMSignature(rawEmail);
    let proposalId = dkimResult.message.indexOf(Buffer.from("#1")) + 1;
    let safeId = dkimResult.message.indexOf(Buffer.from("@ 0x")) + 2;
    let emailFromId = dkimResult.message.indexOf(Buffer.from("javier.su.weijie@gmail.com"));
    const circuitInput = generateCircuitInputs({
      body: dkimResult.body,
      message: dkimResult.message,
      bodyHash: dkimResult.bodyHash,
      rsaSignature: dkimResult.signature,
      rsaPublicKey: dkimResult.publicKey,
      maxMessageLength: 1024,
      maxBodyLength: 1536
    });

    console.log(JSON.stringify({
        in_padded: circuitInput.in_padded,
        pubkey: circuitInput.pubkey,
        signature: circuitInput.signature,
        in_len_padded_bytes: circuitInput.in_len_padded_bytes,
        proposal_idx: proposalId,
        safe_idx: safeId,
        email_from_idx: emailFromId,
        nullifier: "0",
        relayer: "1",
    }));
}

(async () => {
 await main();
})()