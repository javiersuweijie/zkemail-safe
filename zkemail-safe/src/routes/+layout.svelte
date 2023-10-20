<script>
	import '../app.css';
	import { step } from '$lib'

	function isAtStep(s,c) {
		return c === s || s === 0 || s === undefined || s === null;
	}
</script>

<main>
	<div class="h-screen bg-base-100">
		<!-- header -->
		<div class="w-full h-1/6 text-center text-primary-content pt-5 md:hidden bg-base-200 pl-8 pr-8">
			<h1 class="text-4xl font-extrabold">ZKEmail Safe</h1>
			<p class="text-left">
				Email Safe Module allows you to control your safe purely using your email, allowing a much easier way to on-board non-crypto natives to be part of a multi-sig.
			</p>
		</div>
		<div class="w-full flex h-5/6 md:h-full">
			<div class="w-4/12 items-center justify-center hidden md:flex bg-base-200">
				<div class="px-8 text-left text-primary-content">
					<h1 class="text-4xl font-extrabold">ZKEmail Safe</h1>
					<br/>
						<p>
							<span class="font-bold"> ZkEmail Safe Module</span> allows you to control your safe purely using your email, allowing a much
							easier way to on-board non-crypto natives to be part of a multi-sig.
						</p>
					<p>
						The module uses zero-knowledge proofs generated from email headers to authenticate your identity.
					</p>
					<div tabindex="0" class="collapse collapse-open" class:collapse-open={isAtStep($step, 1)} class:opacity-50={!isAtStep($step, 1)} class:collapse-arrow={!isAtStep($step, 1)}> 
						<h2 class="collapse-title text-2xl font-bold pl-0 pr-0" >Step 1: Enable the Module</h2>
						<p class="collapse-content">
							Add signers and threshold to your safe. Sign the Safe transaction with your wallet to enable the module.
						</p>
					</div>
					<div tabindex="0" class="collapse collapse-open" class:collapse-open={isAtStep($step, 2)} class:opacity-50={!isAtStep($step, 2)} class:collapse-arrow={!isAtStep($step, 2)}> 
						<h2 class="collapse-title text-2xl font-bold pl-0 pr-0">Step 2: Create a Proposal</h2>
						<p class="collapse-content">
							Use the dashboard to create a proposal. You can currently send ETH to any address.
						</p>
					</div>
					<div tabindex="0" class="collapse collapse-open" class:collapse-open={isAtStep($step, 3)} class:opacity-50={!isAtStep($step, 3)} class:collapse-arrow={!isAtStep($step, 3)}> 
							<h2 class="collapse-title text-2xl font-bold pl-0 pr-0">Step 3: Approve Using Email</h2>
							<div class="collapse-content">
								<p>
									Send an email to <span>zkemail.safe.relayer@gmail.com</span> using a signer email. The subject has to be the following format.
								</p>
								<code class="w-full p-4 mt-2 bg-base-300 block rounded-md">APPROVE #&lt;proposal_id&gt; @ &lt;safe_address&gt;</code>
							</div>
					</div>
				</div>
			</div>
			<div class="w-full md:w-8/12">
				<slot />
			</div>
		</div>
	</div>
</main>