<script context="module" lang="ts">
	// import { KitQLInfo } from '@kitql/all-in';
	import CommentItem from '$lib/components/hackernews/comment/CommentItem.svelte';
	import Loading from '$lib/components/layout/Loading.svelte';
	import Button from '$lib/components/supabase/ui/Button.svelte';
	import { KQL_CommentsRouteQuery } from '$lib/graphql/_kitql/graphqlStores';
	import { onMount } from 'svelte';

	export async function load({ fetch }) {
		await KQL_CommentsRouteQuery.queryLoad({ fetch });
		return {};
	}
</script>

<script lang="ts">
	let infiniteList = [];

	onMount(async () => {
		await KQL_CommentsRouteQuery.query();
		infiniteList = $KQL_CommentsRouteQuery.data?.comments?.edges ?? [];
	});

	async function loadMore(cursor: string) {
		const newData = await KQL_CommentsRouteQuery.query({
			variables: { after: cursor }
		});
		infiniteList = [...infiniteList, ...newData.data?.comments?.edges];
	}
</script>

<svelte:head>
	<title>supanews | Comments</title>
</svelte:head>

<!-- Just for development help ✅ -->
<!-- <KitQLInfo store={KQL_CommentsRouteQuery} /> -->

<section class="text-gray-600 body-font overflow-hidden w-full">
	<div class="container px-3 py-24 mx-auto">
		<div class="-my-8 divide-y-2 divide-gray-100">
			{#each infiniteList as edge}
				<CommentItem comment={edge.node} />
			{:else}
				{#if $KQL_CommentsRouteQuery.status !== 'NEVER'}
					<Loading />
					{#each new Array(10) as item}
						<CommentItem comment={null} />
					{/each}
				{:else}
					No data!
				{/if}
			{/each}
			{#if $KQL_CommentsRouteQuery.isFetching}
				<Loading />
			{/if}
		</div>
	</div>

	<div class="flex justify-center content-center">
		<Button on:click={() => loadMore($KQL_CommentsRouteQuery.data?.comments?.pageInfo.endCursor)}
			>Load more.</Button
		>
	</div>
</section>
