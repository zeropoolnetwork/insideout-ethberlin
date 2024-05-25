<script>
	import '../app.css';
	import { afterNavigate, beforeNavigate } from '$app/navigation';

	let loading = false;

	beforeNavigate(() => {
		loading = true;
	});

	afterNavigate(() => {
		loading = false;
	});
</script>

<div class="flex h-screen items-center justify-center">
	{#if loading}
		<p>Loading...</p>
	{:else}
		<slot />
	{/if}
</div>
