<script>
    import {getAllProposals} from "$lib"
    export let data;
    let amount = 0;
    let recipient = "";
    let mailto = "";
    let refreshing = false;

    function refreshProposals() {
        refreshing = true;
        getAllProposals(data.safe).then((p) => {
            if (!areProposalsEqual(p, data.streamed.proposals)) {
                refreshing = false;
                data.streamed.proposals = p;
                return;
            }
            setTimeout(() => {
                refreshProposals();
            }, 5000);
        })
    }

    function areProposalsEqual(a, b) {
        if (a.length !== b.length) {
            return false;
        }
        for (const i in a) {
            if (a[i].voters.length !== b[i].voters.length) {
                return false;
            }
        }
        return true;
    }

    function generateMailTo() {
        mailto = `mailto:zkemail.safe.relayer@gmail.com?subject=SEND%20${amount}%20ETH%20to%20${recipient}%20using%20${data.safe}&body=%20`
    }

    function generateApproveMail(proposalId) {
        return `mailto:zkemail.safe.relayer@gmail.com?subject=APPROVE%20#${proposalId}%20@%20${data.safe}&body=%20`
    }
    
    function generateExecuteMail(proposalId) {
        return `mailto:zkemail.safe.relayer@gmail.com?subject=EXECUTE%20#${proposalId}%20@%20${data.safe}&body=%20`
    }

    function proposalStatus(proposal) {
        if (proposal.executed) {
            return "Executed"
        }
        if (proposal.voters.length >= data.threshold) {
            return "Pending Execution"
        } else {
            return "Pending Approval"
        }
    }
</script>
    <div class="p-10">
    <div class="block sm:flex w-full">
    <!-- Section 1: Two-panel 50:50 page with some space in between -->
        <div class="w-full sm:w-1/2 p-4 mb-4 md:mb-0 border-primary-content border-solid border-4 rounded-xl">
            <div class="container text-primary-content overflow-hidden overflow-ellipsis min-h-[150px]">
                <p class="text-lg font-bold">Safe Address</p>
                <p class="text-sm font-medium">{data.safe}</p>
                <p class="text-lg mt-3 font-bold">Assets</p>
                <p class="text-sm font-medium">{data.balance} ETH</p>
                <button class="btn btn-outline btn-sm mt-4">Deposit</button>
            </div>
        </div>
        <div class="w-full sm:w-1/2 md:ml-4 p-4 border-primary-content border-solid border-4 rounded-xl">
            <div class="text-primary-content min-h-[150px] ">
            <p class="text-lg font-bold">Signers</p>
                {#each data.signers as signer, i}
                    <p class="text-sm font-medium">{i+1}. {signer}</p>
                {/each}
            <p class="text-lg mt-3 font-bold">Threshold</p>
            <p class="text-sm font-medium">{data.threshold}/{data.signers.length}</p>
            <button class="btn btn-outline btn-sm mt-4">Edit</button>
            </div>
        </div>
    </div>

    <!-- Section 2: Single column panel with multiple full width items -->
    <div class="flex flex-grow-0 mt-4 items-center">
        <div class="w-full text-2xl mt-4 mb-4 font-extrabold border-primary-content">Proposals</div>
        <button>
            <img class="w-10" class:animate-spin-reverse={refreshing} on:click={refreshProposals} src="/refresh.svg" alt="Icon Description" /> 
        </button>
        <button class="btn btn-primary ml-4" onclick="my_modal_2.showModal()">Create Proposal</button>
    </div>
    <!-- Open the modal using ID.showModal() method -->
    <dialog id="my_modal_2" class="modal">
    <div class="modal-box">
        <h3 class="font-bold text-lg">Send some ETH</h3>
        <form>
            <label class="label">
                <span class="label-text">Amount</span>
                <span class="label-text-alt" on:click={() => amount = data.balance}>Max: {data.balance} ETH</span>
                </label>
            <div class="form-control w-full mb-1">
                <input type="text" class:input-error={false} bind:value={amount} class="input input-bordered w-full" on:change={generateMailTo}/>
            </div>
            <label class="label">
                <span class="label-text">Recipient</span>
            </label>
            <div class="form-control w-full mb-1">
                <input type="text" class:input-error={false} bind:value={recipient} on:change={generateMailTo} class="input input-bordered w-full" />
            </div>
            <form method="dialog" class="flex justify-end items-center pt-4" onclick="my_modal_2.close()">
                <button class="btn btn-disabled">Sign with wallet</button>
                <span class="mx-2">or</span>
                <a class="btn" href={mailto} target="_blank">Send email</a>
            </form>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
    </dialog>

{#await data.streamed.proposals}
    <div>Loading proposals</div>
{:then proposals}
    <div class="overflow-x-scroll">
        <table class="table">
        <!-- head -->
        <thead>
            <tr class="border-b-stone-300">
            <th>ID</th>
            <th>Proposal</th>
            <th>Signers</th>
            <th>Status</th>
            <th>Action</th>
            </tr>
        </thead>
        <tbody>
            {#each proposals as proposal}
                <tr class="border-b-stone-300">
                <th>{proposal.id}</th>
                <td>Send {proposal.amount} ETH to {proposal.to}</td>
                <td>
                    <ol>
                    {#each proposal.voters as voter}
                        <li>{voter}</li>
                    {/each}
                    </ol>
                </td>
                <td>
                    {proposalStatus(proposal)}
                </td>
                <td>
                    {#if proposalStatus(proposal) === "Pending Approval"}
                        <a class="btn btn-sm btn-outline border-1" href="{generateApproveMail(proposal.id)}" target="_blank">Approve</a>
                    {:else if proposalStatus(proposal) === "Pending Execution"}
                        <a class="btn btn-sm btn-outline border-1" href="{generateExecuteMail(proposal.id)}" target="_blank">Execute</a>
                    {:else}
                        <a class="btn btn-sm btn-outline border-1 btn-disabled" href="{generateExecuteMail(proposal.id)}" target="_blank">Executed</a>
                    {/if}
                </td>
                </tr>
            {/each}
        </tbody>
        </table>
    </div>
{:catch error}
{/await}
</div>
