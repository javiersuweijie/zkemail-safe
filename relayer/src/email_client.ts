import Pop3Command from 'node-pop3';

export class EmailClient {
    private client: Pop3Command;
    constructor(user: string, password: string, host:string , port:string, tls = true) {
        this.client = new Pop3Command({
            user,
            password,
            host,
            port: Number(port),
            tls,
        })
    }

    async getStat() {
        return await this.client.STAT();
    }

    async getLastEmail(del = false) {
        const email = await this.client.RETR(1);
        if (del) {
            await this.client.QUIT();
            // await this.client.DELE(1);
        }
        return email;
    }
}