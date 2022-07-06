<script lang="ts">
	/**
	 * If you override class, you should maybe add a default height? `h-4`
	 */
	export { extraClass as class };

	let extraClass = 'h-4';
</script>

<div class="animate-pulse">
	<div class="bg-slate-200/50 rounded {extraClass}">
		<slot />
	</div>
</div>
