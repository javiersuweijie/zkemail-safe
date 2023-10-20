import { getAllProposals, getAllSigners, getEthBalance, isSafeCreated, isSigner, getThreshold } from '$lib';
import { error } from '@sveltejs/kit';

/** @type {import('./$types').PageLoad} */
export function load({ params }) {
    let isSafe = isSafeCreated(params.safe).then((isCreated) => {
        if (!isCreated) {
            throw error(404, 'Not found');
        }
        return isCreated;
    });
    let signers = getAllSigners(params.safe);
    let proposals = getAllProposals(params.safe);
    let balance = getEthBalance(params.safe);
    let canSign = isSigner(params.safe, "javier.su.weijie@gmail.com");
    let threshold = getThreshold(params.safe);

    return {
        safe: params.safe.toLowerCase(),
        isSafe,
        signers,
        balance,
        canSign,
        threshold,
        streamed: {
            proposals
        }
    }
}