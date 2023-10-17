import Pop3Command from 'node-pop3';
import { MaybeError, Result } from './utils';

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

    async getStat(): Promise<Result<string>> {
        try {
            const stat = await this.client.STAT();
            return [stat, null];
        } catch (e) {
            return [null, new Error(`Error getting email stats ${e}`)];
        }
    }

    async getEmailById(id: number, del = false): Promise<Result<string>> {
        try {
            const email = await this.client.RETR(id);
            if (del) {
                await this.client.QUIT();
            }
            return [email, null];
        } catch (e) {
            return [null, new Error(`Error getting email ${e}`)];
        }
    }

    async updateChanges(): Promise<MaybeError> {
        try {
            await this.client.QUIT();
            return null;
        } catch (e) {
            return new Error(`Error updating changes ${e}`);
        }
    }
}