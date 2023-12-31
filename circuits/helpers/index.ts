import {pki} from "node-forge";
import { toCircomBigIntBytes } from "@zk-email/helpers/dist/binaryFormat";
import dns from "dns"
import { verifyDKIMSignature } from "@zk-email/helpers/dist/dkim";
import { generateCircuitInputs } from "@zk-email/helpers/dist/input-helpers";
// @ts-ignore
import { groth16 } from "snarkjs";

export async function getPubKey64(domain: string, selector: string) {
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

export function pubKey64toCircomBigIntBytes(pubkey64: string) {
    let pem = '-----BEGIN PUBLIC KEY-----\n'+pubkey64+'-----END PUBLIC KEY-----';
    let pubKey = pki.publicKeyFromPem(pem);
    return toCircomBigIntBytes(BigInt(pubKey.n.toString()));
}

export type CircuitInput = {
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

export async function generateCircuitInputsFromEmail (rawEmail: Buffer, fromEmail: string ): Promise<CircuitInput> {
    const dkimResult = await verifyDKIMSignature(rawEmail);
    let proposalId = dkimResult.message.indexOf(Buffer.from("APPROVE #")) + 9;
    let safeId = dkimResult.message.indexOf(Buffer.from("@ 0x")) + 2;
    let emailFromId = await dkimResult.message.indexOf(Buffer.from(fromEmail));

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

export async function generateCallDataFromCircuitInputs(input: CircuitInput, path_to_wasm: string, path_to_zkey: string, verbose = false) {
    const {proof, publicSignals} = await groth16.fullProve(input, path_to_wasm, path_to_zkey, verbose ? console : undefined);
    return await groth16.exportSolidityCallData(proof, publicSignals);
}