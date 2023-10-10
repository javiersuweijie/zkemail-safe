export function convertMsg(msg: string, maxLen = 640) {
    let msgEncoded = msg.split('').map((x) => x.charCodeAt(0));
    while (msgEncoded.length < maxLen) {
        msgEncoded.push(0);
    }
    return msgEncoded.map((x) => `${x}`);
}

export function assert_reveal(reveal: any, expected_reveal: string) {
    const output = Buffer.from(reveal.map(Number)).toString('ascii').replaceAll("\x00", '')
    expect(output).toEqual(expected_reveal)
}

export function assert_unpacked(unpacked: string, expected_reveal: string) {
    const output = unpacked.replaceAll("\x00", '')
    expect(output).toEqual(expected_reveal)
}