import { getAddress, createPublicClient, createWalletClient, getContract, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { zesABI } from "../lib/contract/ZkEmailSafe";
import zesDeployment from "../lib/contract/deployment.json";
export class ZkEmailSafeClient {
    constructor(chain, privateKey) {
        this.account = privateKeyToAccount(privateKey);
        this.pubClient = createPublicClient({
            chain,
            transport: http()
        });
        this.client = createWalletClient({
            account: this.account,
            chain,
            transport: http()
        });
        this.deployment = zesDeployment;
        this.chainName = chain?.name ?? "Foundry";
        this.contract = getContract({
            address: this.deployment[this.chainName].ZkEmailSafe,
            abi: zesABI,
            walletClient: this.client,
            publicClient: this.pubClient,
        });
    }
    async proposeSpendEth(safe, to, amount) {
        try {
            const safeAddress = getAddress(safe);
            const toAddress = getAddress(to);
            const hash = await this.contract.write.propose([safeAddress, toAddress, amount, "0x", 0]);
            return [hash, null];
        }
        catch (e) {
            return [null, new Error(`Error proposing spend: ${e}`)];
        }
    }
    async vote(a, b, c, signal) {
        if (signal.length !== 33) {
            return [null, new Error("Signal must be 33 elements long")];
        }
        try {
            const hash = await this.contract.write.vote([a, b, c, signal]);
            return [hash, null];
        }
        catch (e) {
            return [null, new Error(`Error voting: ${e}`)];
        }
    }
    async execute(safe, proposal_id) {
        try {
            const hash = await this.contract.write.execute([getAddress(safe), proposal_id]);
            return [hash, null];
        }
        catch (e) {
            return [null, new Error(`Error executing: ${e}`)];
        }
    }
}
