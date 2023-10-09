import fs from "fs";
import { buildMimcSponge } from "circomlibjs";
import { wasm as wasm_tester } from "circom_tester";
import { Scalar } from "ffjavascript";
import path from "path";
import { DKIMVerificationResult } from "@zk-email/helpers/dist/dkim";
import { generateCircuitInputs } from "@zk-email/helpers/dist/input-helpers";
import { verifyDKIMSignature } from "@zk-email/helpers/dist/dkim";
import { assert_reveal, convertMsg } from './helpers';

exports.p = Scalar.fromString(
  "21888242871839275222246405745257275088548364400416034343698204186575808495617"
);

describe("Subject Regex", () => {
  jest.setTimeout(10 * 60 * 1000); // 10 minutes

  let circuit: any;
  let dkimResult: DKIMVerificationResult;

  beforeAll(async () => {
    circuit = await wasm_tester(
      path.join(__dirname, "./subject_regex.circom"),
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

  it("should output correct reveal with an email", async function () {
      const preSignedHeader = dkimResult.message.toString("ascii");
      // console.log(convertMsg(preSignedHeader), convertMsg(preSignedHeader).length)
      const witness = await circuit.calculateWitness({
        msg: convertMsg(preSignedHeader),
      });
      await circuit.checkConstraints(witness);
      const signals = await circuit.getJSONOutput('main', witness);
      // console.log(signals.main.reveal_proposal)
      // console.log(signals.main.reveal_safe)
      assert_reveal(signals.main.reveal_proposal, "1")
      assert_reveal(signals.main.reveal_safe, "0x478958e6da0f9a9e5d83654555590225734df73b")
  });
});