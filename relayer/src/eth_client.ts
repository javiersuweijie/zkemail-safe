import { AcceptsDiscriminator } from "mongoose";
import {Account, Address, getAddress, GetContractReturnType, PublicClient, WalletClient, createPublicClient, createWalletClient, getAbiItem, getContract, http} from "viem"
import { scrollSepolia, foundry, Chain} from "viem/chains"
import {mnemonicToAccount, privateKeyToAccount} from "viem/accounts"
import { zesABI } from "../lib/contract/ZkEmailSafe"
import zesDeployment from "../lib/contract/deployment.json"
import { writeContract } from "viem/_types/actions/wallet/writeContract";
import { Result, FixedLengthArray } from "./utils";

type Deployment = {
    [key: string]: {
        ZkEmailSafe: `0x${string}`
    }
};


export class ZkEmailSafeClient {
    private client;
    private pubClient;
    private contract;
    private account: Account;
    private deployment: Deployment; 
    private chainName: string;

    constructor(chain: Chain, mnemonic: string) {
        this.account = mnemonicToAccount( mnemonic) 
        this.pubClient = createPublicClient({
            chain,
            transport: http()
        });
        this.client = createWalletClient({
            account: this.account,
            chain,
            transport: http()
        });

        this.deployment = zesDeployment as Deployment;
        this.chainName = chain?.name ?? "Foundry";
        this.contract = getContract({
            address: this.deployment[this.chainName].ZkEmailSafe,
            abi: zesABI,
            walletClient: this.client,
            publicClient: this.pubClient,
        });
    }

    async proposeSpendEth(safe: string, to: string, amount: bigint):Promise<Result<string>> {
        try {
            const safeAddress = getAddress(safe);
            const toAddress = getAddress(to);
            const hash = await this.contract.write.propose([safeAddress, toAddress, amount, "0x",0])
            return [hash, null];
        } catch (e) {
            return [null, new Error(`Error proposing spend: ${e}`)];
        }
    }

    async vote(a: [bigint, bigint], b: [[bigint, bigint], [bigint, bigint]], c: [bigint, bigint], signal: any): Promise<Result<string>> {
        if (signal.length !== 33) {
            return [null, new Error("Signal must be 33 elements long")];
        }
        try {
            const hash = await this.contract.write.vote([a, b, c, signal])
            return [hash, null];
        } catch (e) {
            return [null, new Error(`Error voting: ${e}`)];
        }
    }

    async execute(safe: string, proposal_id: bigint): Promise<Result<string>> {
        try {
            const hash = await this.contract.write.execute([getAddress(safe), proposal_id])
            return [hash, null];
        } catch (e) {
            return [null, new Error(`Error executing: ${e}`)];
        }
    }
}