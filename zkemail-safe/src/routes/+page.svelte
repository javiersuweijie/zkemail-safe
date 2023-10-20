<script>
    import {browser} from '$app/environment';
	import { goto } from '$app/navigation';
	import { emailToByte32, zkEmailSafeAddressAbi, zkEmailSafeAddress, isSafeCreated, step } from '$lib';
    import SafeAppsSDK from '@safe-global/safe-apps-sdk'
	import {createPublicClient, http, encodeFunctionData} from 'viem';
	import {parseAbi} from 'viem/abi';
	import {scrollSepolia} from 'viem/chains';
	let safeAddress = "";
	let zkSafeCreated = false;
	let loadingMsg = "Loading your Safe details"

	let safeAppSdk;
	let signers = [];
	let threshold = 1;

	const opts = {
		allowedDomains: [/gnosis-safe.io$/, /app.safe.global$/, /safe.scroll.xyz$/],
		debug: false,
	};

    if (browser) {
        safeAppSdk = new SafeAppsSDK(opts);
        safeAppSdk.safe.getInfo().then((info) => {
			$step = 0;
			isSafeCreated(info.safeAddress).then((isCreated) => {
				console.log({...info, isCreated});
				if (isCreated) {
					goto(`/safes/${info.safeAddress}`);
				} else {
					$step = 1;
					safeAddress = info.safeAddress
					zkSafeCreated = isCreated;
				}
			})
		});
    }


	function prepareEmailCalldata(signers) {
		const signersInByte32 = [];
		const filteredSigners = signers.filter((signer) =>  /\S+@\S+\.\S+/.test(signer));
		console.log(filteredSigners);
		for (let i = 0; i < filteredSigners.length; i++) {
			const signer = filteredSigners[i];
			const signerInByte32 = emailToByte32(signer);
			signersInByte32.push(signerInByte32);
		}
		return signersInByte32;
	}

	function sendTxn() {
		const abi = parseAbi(["function enableModule(address module)"])
		const zkSafeAbi = parseAbi(["function add_safe(uint64 threshold, bytes32[] memory emails)"])
		const txns = zkSafeCreated ? [] : [
			{
				to: safeAddress,
				value: "0",
				data: encodeFunctionData({
					abi,
					functionName: "enableModule",
					args: [zkEmailSafeAddress],
				})
			}
		];
		safeAppSdk.txs.send({
			txs: [
				...txns,
				{
					to: zkEmailSafeAddress,
					value: "0",
					data: encodeFunctionData({
						abi: zkSafeAbi,
						functionName: "add_safe",
						args: [BigInt(threshold), prepareEmailCalldata(signers)],
					}),
				},
			]
		})
	}

	function validateEmail(email) {
		if (!email) return true;
		var re = /\S+@\S+\.\S+/;
		return re.test(email);
	}

</script>

<div class="h-screen flex items-center justify-center">
{#if !safeAddress}
<div class="text-center">
	<p class="font-extrabold text-4xl mb-4">{loadingMsg}</p>
	<p><span class="loading loading-ring loading-lg"></span></p>
</div>
{:else}
<div class="container mx-12 w-8/12">
<p class="font-extrabold text-4xl mb-4">Your Safe is not (yet) enabled with the ZK Email Safe module</p>
<p class="text-lg">Add ZkEmail Safe Module</p>
<form>
	<label class="label">
		<span class="label-text">Signer emails</span>
	</label>
	{#each {length: signers.length+1} as _,i}
	<div class="form-control w-full mb-4">
		<input type="text" class:input-error={!validateEmail(signers[i])} bind:value={signers[i]} placeholder="test@example.com" class="input input-bordered w-full" />
	</div>
	{/each}
	<div class="form-control w-full">
		<label class="label">
			<span class="label-text">Threshold {threshold} / {signers.length}</span>
		</label>
		<input type="range" bind:value={threshold} min="0" max="{Math.max(signers.length, 1)}"  class="range" />
	</div>
	<button class="btn mt-4" on:click={sendTxn}>Add Module</button>
</form>
</div>
{/if}
</div>