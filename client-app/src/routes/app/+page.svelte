<script lang="ts">
	import { goto } from '$app/navigation';
	import { initWallet, getAddress } from '$lib';
	import {
		uploadFile,
		mint,
		getAccount,
		checkStatus,
		ROLLUP_API_URL,
		NODE_API_URL
	} from '$lib/api';

	let files: { name: string; url: string }[] = [];
	let balance = 0;

	const handleUpload = async () => {
		let input = document.createElement('input');
		input.type = 'file';
		input.onchange = async (_) => {
			// @ts-ignore
			let files = Array.from(input.files);
			await uploadFile(files[0] as File, getAddress());
			await update();
		};
		input.click();
	};

	const handleMint = async () => {
		await mint(getAddress(), 100);
		balance += 100;
	};

	async function load() {
		try {
			await initWallet();
			await update();
		} catch (err) {
			console.error(err);
			return goto('/init');
		}
	}

	async function update() {
		const account = await getAccount(getAddress());
		files = account.files.map((name: string) => ({
			name,
			url: `${NODE_API_URL}/files/${name}`
		}));
		balance = account.balance;
	}

	let nodeStatus = true;
	let rollupStatus = true;

	setInterval(async () => {
		let status = await checkStatus();
		nodeStatus = status.node;
		rollupStatus = status.rollup;
	}, 1000);

	let promise = load();
</script>

<div class="border rounded-lg p-4 w-full sm:w-2/3 md:w-1/2 lg:w-1/3">
	{#await promise}
		<p>Loading...</p>
	{:then}
		<div class="mb-4">
			<div class="flex justify-between">
				<p class="text-sm text-gray-300">
					Rollup: {ROLLUP_API_URL}
					{#if rollupStatus}
						<span class="text-green-500">✅</span>
					{:else}
						<span class="text-red-500">❌</span>
					{/if}
				</p>
				<p class="text-sm text-gray-300">
					Node: {NODE_API_URL}
					{#if nodeStatus}
						<span class="text-green">✅</span>
					{:else}
						<span class="text-red"> ❌ </span>
					{/if}
				</p>
			</div>
		</div>
		<div class="mb-4">
			<div class="mb-4">
				<p class="text-sm text-gray-600 overflow-hidden">Address: {getAddress()}</p>
			</div>
			<div class="mb-4">
				<p class="text-sm text-gray-600">Balance: {balance}</p>
			</div>
			<div class="flex space-x-2">
				<button
					on:click={handleUpload}
					class="bg-yellow-400 hover:bg-yellow-500 text-white font-bold py-2 px-4 rounded"
				>
					Upload
				</button>
				<button
					on:click={handleMint}
					class="bg-yellow-400 hover:bg-yellow-500 text-white font-bold py-2 px-4 rounded"
				>
					Mint
				</button>
			</div>
		</div>
		<div class="border-t pt-4">
			<h2 class="text-xl font-bold mb-2">Files</h2>
			{#each files as file}
				<div class="flex items-center mb-2">
					<img src={file.url} alt={file.name} class="w-12 h-12 mr-2 rounded" />
					<a href={file.url} target="_blank" class="text-blue-500 overflow-hidden">{file.name}</a>
				</div>
			{/each}
		</div>
	{:catch error}
		<p>Error: {error.message}</p>
	{/await}
</div>
