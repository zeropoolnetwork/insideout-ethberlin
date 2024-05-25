<script lang="ts">
	import { goto } from '$app/navigation';
	import { initWallet } from '$lib';

	let mnemonic = '';

	async function init() {
		try {
			await initWallet(mnemonic);
			goto('/app');
		} catch (err) {
			console.error(err);
		}
	}
</script>

<div class="border rounded-lg p-4 w-1/3">
	<div class="flex space-x-2">
		<input
			bind:value={mnemonic}
			type="text"
			placeholder="Mnemonic"
			class="border rounded-lg p-2 w-full"
		/>
		<button
			on:click={init}
			class="bg-yellow-400 hover:bg-yellow-500 text-white font-bold py-2 px-4 rounded"
		>
			Init
		</button>
	</div>
</div>
