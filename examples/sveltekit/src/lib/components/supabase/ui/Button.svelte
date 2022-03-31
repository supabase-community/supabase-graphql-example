<script lang="ts">
	export let type: 'button' | 'submit' = 'button';
	export let isLoading = false;
	import { fly } from 'svelte/transition';
	import SvgLoader from './SVGLoader.svelte';
</script>

<button
	on:click
	class="bg-primary text-white font-sans text-center px-2.5 py-1.5 text-xs shadow-md rounded flex"
	{type}
>
	<slot />
	{#if isLoading}
		<div in:fly={{ x: -20 }}><SvgLoader /></div>
	{/if}
</button>
