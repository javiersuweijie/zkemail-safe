import { getAllProposals, getAllSigners, getEthBalance, isSafeCreated, isSigner, getThreshold } from '$lib';
import { error } from '@sveltejs/kit';


/** @type {import('../[safe]/$types').PageLoad} */
export function load({ params }) {

    let safe = params.safe.toLowerCase();
    let isSafe = isSafeCreated(safe).then((isCreated) => {
        if (!isCreated) {
            throw error(404, 'Not found');
        }
        return isCreated;
    });
    let signers = getAllSigners(safe);
    let proposals = getAllProposals(safe);
    let balance = getEthBalance(safe);
    let threshold = getThreshold(safe);

    return {
        safe,
        isSafe,
        signers,
        balance,
        threshold,
        streamed: {
            proposals
        }
    }
}