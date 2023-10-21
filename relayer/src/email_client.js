import Pop3Command from 'node-pop3';
export class EmailClient {
    constructor(user, password, host, port, tls = true) {
        this.client = new Pop3Command({
            user,
            password,
            host,
            port: Number(port),
            tls,
        });
    }
    async getStat() {
        try {
            const stat = await this.client.STAT();
            return [stat, null];
        }
        catch (e) {
            return [null, new Error(`Error getting email stats ${e}`)];
        }
    }
    async getEmailById(id, del = false) {
        try {
            const email = await this.client.RETR(id);
            if (del) {
                await this.client.QUIT();
            }
            return [email, null];
        }
        catch (e) {
            return [null, new Error(`Error getting email ${e}`)];
        }
    }
    async updateChanges() {
        try {
            await this.client.QUIT();
            return null;
        }
        catch (e) {
            return new Error(`Error updating changes ${e}`);
        }
    }
}
