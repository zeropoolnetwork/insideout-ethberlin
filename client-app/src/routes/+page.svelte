<script>
	import { goto } from '$app/navigation';
	import { initWallet } from '$lib';
	import { onMount } from 'svelte';

	onMount(async () => {
		try {
			await initWallet();
			goto('/app');
		} catch (err) {
			console.error(err);
			goto('/init');
		}
	});
</script>
