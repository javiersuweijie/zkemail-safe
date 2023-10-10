pragma circom 2.1.5;

include "../src/subject_regex.circom";

component main { public [ msg ] } = SubjectRegex(640);