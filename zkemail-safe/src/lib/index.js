// place files you want to import through the `$lib` alias in this folder.

import { createPublicClient, decodeAbiParameters, formatEther, http, parseAbi, parseAbiParameters} from "viem";
import { scrollSepolia } from "viem/chains";
import { writable } from 'svelte/store';

export let zkEmailSafeAddress = "0x2aa54741b34173eB843A78Bc5ABCeeDbbF332C6C";
export let zkEmailSafeAddressAbi = [
    "function isSigner(address safe, bytes32 email) returns (bool)",
    "function isSafe(address safe) returns (bool)",
    "function iterateSigner(address safe, bytes32 email) returns (bytes32)",
    "function iterateVotes(address safe, uint64 proposalId, bytes32 email) returns (bytes32)",
    "function voteCount(address safe, uint64 proposalId) returns (uint64)",
    "function proposalCount(address safe) returns (uint64)",
    "function proposal(address safe, uint64 proposalId) external view returns (bytes memory)",
    "function thresholds(address safe) returns (uint64)",
    "function executed(address safe, uint64 proposalId) returns (bool)"
];

let publicClient = createPublicClient({
    chain: scrollSepolia,
    transport: http(),
})

export const step = writable(0);

export function emailToByte32(email) {
    const signerInBytes = Buffer.from(email, 'utf8');
    const signerInByte32 = '0x' + signerInBytes.toString('hex').padEnd(64, '0');
    return signerInByte32;
}

export function byte32ToEmail(byte32hex) {
    const signerInBytes = Buffer.from(byte32hex.slice(2), 'hex');
    const signerInString = signerInBytes.toString('utf8').replace(/\0.*$/g, '');
    return signerInString;
}

export async function isSafeCreated(safe) {
    return publicClient.readContract({
        address: zkEmailSafeAddress,
        abi: parseAbi(zkEmailSafeAddressAbi),
        functionName: "isSafe",
        args: [safe],
    });
}

const firstSigner = "_";
const emptySigner = "0x" + "0".repeat(64);
export async function getAllSigners(safe) {
    let signerByte32s = [];
    let signer = await publicClient.readContract({
        address: zkEmailSafeAddress,
        abi: parseAbi(zkEmailSafeAddressAbi),
        functionName: "iterateSigner",
        args: [safe, emailToByte32(firstSigner)],
    });
    while (signer !== emptySigner) {
        signerByte32s.push(signer);
        signer = await publicClient.readContract({
            address: zkEmailSafeAddress,
            abi: parseAbi(zkEmailSafeAddressAbi),
            functionName: "iterateSigner",
            args: [safe, signer],
        });
    }
    return signerByte32s.map(byte32ToEmail);
}

export async function getAllVoters(safe, proposalId) {
    let signerByte32s = [];
    let signer = await publicClient.readContract({
        address: zkEmailSafeAddress,
        abi: parseAbi(zkEmailSafeAddressAbi),
        functionName: "iterateVotes",
        args: [safe, proposalId, emailToByte32(firstSigner)],
    });
    while (signer !== emptySigner) {
        signerByte32s.push(signer);
        signer = await publicClient.readContract({
            address: zkEmailSafeAddress,
            abi: parseAbi(zkEmailSafeAddressAbi),
            functionName: "iterateVotes",
            args: [safe, proposalId, signer],
        });
    }
    return signerByte32s.map(byte32ToEmail);
}

export async function getAllProposals(safe, limit=10) {
    let proposals = [];
    let proposalCount = await publicClient.readContract({
        address: zkEmailSafeAddress,
        abi: parseAbi(zkEmailSafeAddressAbi),
        functionName: "proposalCount",
        args: [safe],
    });

    for (let i = 0; i < limit; i++) {
        const proposalId = Number(proposalCount) - i - 1;
        if (proposalId < 0) {
            break;
        }
        let proposal = await publicClient.readContract({
            address: zkEmailSafeAddress,
            abi: parseAbi(zkEmailSafeAddressAbi),
            functionName: "proposal",
            args: [safe, BigInt(proposalId)],
        });
        if (proposal !== "0x") {
            proposals.push({data: proposal, id: proposalId});
        }
    }

    if (proposals.length === 0) {
        return proposals;
    }

    for (const p of proposals) {
        let votes = await publicClient.readContract({
            address: zkEmailSafeAddress,
            abi: parseAbi(zkEmailSafeAddressAbi),
            functionName: "voteCount",
            args: [safe, p.id],
        });
        p.votes =  Number(votes);
        if (p.votes === 0) {
            p.voters = [];
            continue;
        }
        const voters = await getAllVoters(safe, p.id);
        p.voters = voters;

        const executed = await publicClient.readContract({
            address: zkEmailSafeAddress,
            abi: parseAbi(zkEmailSafeAddressAbi),
            functionName: "executed",
            args: [safe, p.id],
        });
        p.executed = executed;
    }

    if (proposals.length === 0) {
        step.set(2);
    } else {
        step.set(3);
    }
    
    return proposals.map(p => {
        const [to, amount, _, __] = decodeAbiParameters(parseAbiParameters("address to, uint256 amount, bytes data, uint operation"), p.data)
        return {
            ...p,
            to,
            amount: formatEther(amount),
        }
    })
}

export async function getEthBalance(safe) {
    const balance = await publicClient.getBalance({
        address: safe,
    })
    return formatEther(balance)
}

export async function isSigner(safe, email) {
    return publicClient.readContract({
        address: zkEmailSafeAddress,
        abi: parseAbi(zkEmailSafeAddressAbi),
        functionName: "isSigner",
        args: [safe, emailToByte32(email)],
    });
}

export async function getThreshold(safe) {
    return (Number(await publicClient.readContract({
        address: zkEmailSafeAddress,
        abi: parseAbi(zkEmailSafeAddressAbi),
        functionName: "thresholds",
        args: [safe],
    })));
}