pragma circom 2.1.5;

include "circomlib/circuits/bitify.circom";
include "@zk-email/circuits/helpers/sha.circom";
include "@zk-email/circuits/helpers/rsa.circom";
include "@zk-email/circuits/helpers/base64.circom";
include "@zk-email/circuits/helpers/extract.circom";
include "@zk-email/circuits/regexes/from_regex.circom";
include "@zk-email/circuits/regexes/tofrom_domain_regex.circom";
include "@zk-email/circuits/regexes/body_hash_regex.circom";
include "@zk-email/circuits/regexes/message_id_regex.circom";
include "@zk-email/circuits/email-verifier.circom";
include "./subject_regex.circom";

// Here, n and k are the biginteger parameters for RSA
// This is because the number is chunked into k pack_size of n bits each
template EmailSafe(max_header_bytes, max_body_bytes, n, k, pack_size) {
    signal input in_padded[max_header_bytes]; // prehashed email data, includes up to 512 + 64? bytes of padding pre SHA256, and padded with lots of 0s at end after the length
    signal input pubkey[k]; // rsa pubkey, verified with smart contract + DNSSEC proof. split up into k parts of n bits each.
    signal input signature[k]; // rsa signature. split up into k parts of n bits each.
    signal input in_len_padded_bytes; // length of in email data including the padding, which will inform the sha256 block length

    // Header reveal vars
    // TODO: In reality, this max value is 320, and would allow people to break our gaurantees and spoof arbitrary email addresses by registering disgustingly subdomains and going past the end of the 30
    var max_email_len = 31;
    var max_subject_proposal_len = max_email_len;
    var max_subject_proposal_packed_bytes = count_packed(max_subject_proposal_len, pack_size);
    var max_subject_safe_len = 44;
    var max_subject_safe_packed_bytes = count_packed(max_subject_safe_len, pack_size);
    var max_message_id_len = 128;
    var max_email_from_len = max_email_len;
    var max_email_recipient_len = max_email_len;

    signal input proposal_idx;
    signal input safe_idx;

    // Identity commitment variables
    // Note that you CANNOT use --O1 with this circuit, as it will break the malleability protection: circom 2.1.5: "Improving --O1 simplification: removing signals that do not appear in any constraint and avoiding unnecessary constraint normalizations."
    signal input nullifier;
    signal input relayer;

    // Verify email signature
    // ignore_body_hash_check is set to true as we dont care about body contents
    component verifier = EmailVerifier(max_header_bytes, max_body_bytes, n, k, 1);
    verifier.in_padded <== in_padded;
    verifier.pubkey <== pubkey;
    verifier.signature <== signature;
    verifier.in_len_padded_bytes <== in_len_padded_bytes;
    // verifier.body_hash_idx <== body_hash_idx;

    // SUBJECT HEADER REGEX: 736,553 constraints
    // This extracts the subject, and the precise regex format can be viewed in the README
    signal subject_regex_out, subject_regex_reveal_proposal[max_header_bytes], subject_regex_reveal_safe[max_header_bytes];
    (subject_regex_out, subject_regex_reveal_proposal, subject_regex_reveal_safe) <== SubjectRegex(max_header_bytes)(in_padded);
    // log(subject_regex_out);
    subject_regex_out === 1;

    signal output reveal_proposal_packed[max_subject_proposal_packed_bytes];
    signal output reveal_safe_packed[max_subject_safe_packed_bytes];

    reveal_proposal_packed <== ShiftAndPack(max_header_bytes, max_subject_proposal_len, pack_size)(subject_regex_reveal_proposal, proposal_idx);
    reveal_safe_packed <== ShiftAndPack(max_header_bytes, max_subject_safe_len, pack_size)(subject_regex_reveal_safe, safe_idx);

    // FROM HEADER REGEX: 736,553 constraints
    // This extracts the from email, and the precise regex format can be viewed in the README
    // TODO: Mitigation for the critical vuln where I can pretend to be another email address by making my email address <max_len_minus_10>@gmail.commydomain.com and <max_len_minus_10>@gmail.com reaches max_len so it truncates is done by ensuring the array index via QuinSelector as such: message_id_regex_reveal[message_id_idx + max_message_id_len] === 0
    var max_email_from_packed_bytes = count_packed(max_email_from_len, pack_size);
    assert(max_email_from_packed_bytes < max_header_bytes);

    signal input email_from_idx;
    signal email_from[max_email_from_len];

    signal from_regex_out, from_regex_reveal[max_header_bytes];
    (from_regex_out, from_regex_reveal) <== FromRegex(max_header_bytes)(in_padded);
    // log(from_regex_out);
    from_regex_out === 1;
    email_from <== VarShiftLeft(max_header_bytes, max_email_from_len)(from_regex_reveal, email_from_idx);

    signal output reveal_email_from_packed[max_email_from_packed_bytes];
    reveal_email_from_packed <== ShiftAndPack(max_header_bytes, max_email_from_len, pack_size)(from_regex_reveal, email_from_idx);
}

// Args:
// * max_header_bytes = 1024 is the max number of bytes in the header
// * max_body_bytes = 1536 is the max number of bytes in the body after precomputed slice
// * n = 121 is the number of bits in each chunk of the modulus (RSA parameter)
// * k = 17 is the number of chunks in the modulus (RSA parameter)
// * pack_size = 7 is the number of bytes that can fit into a 255ish bit signal (can increase later)
component main { public [ pubkey, nullifier, relayer ] } = EmailSafe(1024, 1536, 121, 17, 8);