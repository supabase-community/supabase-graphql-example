<script lang="ts">
	import { fly } from 'svelte/transition';
	import SvgLoader from './SVGLoader.svelte';

	export let type: 'button' | 'submit' = 'button';
	export let disabled = false;
	export let isLoading = false;
</script>

<button
	{disabled}
	on:click
	class="{disabled || isLoading
		? 'bg-gray-400'
		: 'bg-primary'}  text-white font-sans text-center px-2.5 py-1.5 text-xs shadow-md rounded flex"
	{type}
>
	<slot />
	{#if isLoading}
		<div in:fly={{ x: -20 }}><SvgLoader /></div>
	{/if}
</button>
