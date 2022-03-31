<script context="module" lang="ts">
	// import { KitQLInfo } from '@kitql/all-in';
	import FeedItem from '$lib/components/FeedItem.svelte';
	import Loading from '$lib/components/layout/Loading.svelte';
	import Button from '$lib/components/supabase/ui/Button.svelte';
	import { KQL_IndexRouteQuery } from '$lib/graphql/_kitql/graphqlStores';
	import { noopUUID } from '$lib/utils/noop-uuid';
	import { onMount } from 'svelte';

	export async function load({ fetch }) {
		await KQL_IndexRouteQuery.queryLoad({ fetch, variables: { profileId: noopUUID } });
		return {};
	}
</script>

<script lang="ts">
	let infiniteList = [];

	onMount(async () => {
		await KQL_IndexRouteQuery.query({ fetch, variables: { profileId: noopUUID } });
		infiniteList = $KQL_IndexRouteQuery.data?.feed?.edges ?? [];
	});

	async function loadMore(cursor: string) {
		const newData = await KQL_IndexRouteQuery.query({
			variables: { profileId: noopUUID, after: cursor }
		});
		infiniteList = [...infiniteList, ...newData.data?.feed?.edges];
	}
</script>

<svelte:head>
	<title>supanews | Feed</title>
</svelte:head>

<!-- Just for development help ✅ -->
<!-- <KitQLInfo store={KQL_IndexRouteQuery} /> -->

<section class="text-gray-600 body-font overflow-hidden w-full">
	<div class="container px-3 py-24 mx-auto">
		<div class="-my-8">
			{#each infiniteList as edge}
				<FeedItem post={edge.node} />
			{:else}
				{#if $KQL_IndexRouteQuery.status === 'LOADING'}
					<Loading />
					{#each new Array(10) as item}
						<FeedItem post={null} />
					{/each}
				{:else}
					No data!
				{/if}
			{/each}
			{#if $KQL_IndexRouteQuery.isFetching}
				<Loading />
			{/if}
		</div>
	</div>

	<div class="flex justify-center content-center">
		<Button on:click={() => loadMore($KQL_IndexRouteQuery.data?.feed?.pageInfo.endCursor)}
			>Load more.</Button
		>
	</div>
</section>
