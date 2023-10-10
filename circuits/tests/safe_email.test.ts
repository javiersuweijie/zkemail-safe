import fs from "fs";
import { buildMimcSponge } from "circomlibjs";
import { wasm as wasm_tester } from "circom_tester";
import { Scalar } from "ffjavascript";
import path from "path";
import { DKIMVerificationResult } from "@zk-email/helpers/dist/dkim";
import { generateCircuitInputs } from "@zk-email/helpers/dist/input-helpers";
import { packedNBytesToString } from "@zk-email/helpers/dist/binaryFormat";
import { verifyDKIMSignature } from "@zk-email/helpers/dist/dkim";
import { assert_reveal, assert_unpacked, convertMsg } from './helpers';

exports.p = Scalar.fromString(
  "21888242871839275222246405745257275088548364400416034343698204186575808495617"
);

describe("Subject Regex", () => {
  jest.setTimeout(10 * 60 * 1000); // 10 minutes

  let circuit: any;
  let dkimResult: DKIMVerificationResult;

  beforeAll(async () => {
    circuit = await wasm_tester(
      path.join(__dirname, "../src/email_safe.circom"),
      {
        // @dev During development recompile can be set to false if you are only making changes in the tests.
        // This will save time by not recompiling the circuit every time.
        // Compile: circom "./tests/email-verifier-test.circom" --r1cs --wasm --sym --c --wat --output "./tests/compiled-test-circuit"
        recompile: true,
        output: path.join(__dirname, "./compiled-test-circuit"),
        include: path.join(__dirname, "../node_modules"),
      }
    );

    const rawEmail = fs.readFileSync(path.join(__dirname, "./email.eml"));
    dkimResult = await verifyDKIMSignature(rawEmail);
  });
  
  it("should verify email and output from email, proposal and safe details", async function () {
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
    })
    const witness = await circuit.calculateWitness({
      in_padded: circuitInput.in_padded,
      pubkey: circuitInput.pubkey,
      signature: circuitInput.signature,
      in_len_padded_bytes: circuitInput.in_len_padded_bytes,
      proposal_idx: proposalId,
      safe_idx: safeId,
      email_from_idx: emailFromId,
      nullifier: "0",
      relayer: "1",
    });
    await circuit.checkConstraints(witness);
    const signals = await circuit.getJSONOutput('main', witness);

    let proposal = packedNBytesToString(signals.main.reveal_proposal_packed, 8);
    let safe = packedNBytesToString(signals.main.reveal_safe_packed, 8);
    let emailFrom = packedNBytesToString(signals.main.reveal_email_from_packed, 8);

    assert_unpacked(proposal, "1");
    assert_unpacked(safe, "0x478958e6da0f9a9e5d83654555590225734df73b");
    assert_unpacked(emailFrom, "javier.su.weijie@gmail.com");
  });
});