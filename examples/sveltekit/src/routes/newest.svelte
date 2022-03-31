<script context="module" lang="ts">
	// import { KitQLInfo } from '@kitql/all-in';
	import FeedItem from '$lib/components/hackernews/post/FeedItem.svelte';
	import Loading from '$lib/components/layout/Loading.svelte';
	import Button from '$lib/components/supabase/ui/Button.svelte';
	import { KQL_NewestRouteQuery } from '$lib/graphql/_kitql/graphqlStores';
	import { noopUUID } from '$lib/utils/noop-uuid';
	import { onMount } from 'svelte';

	export async function load({ fetch }) {
		await KQL_NewestRouteQuery.queryLoad({ fetch, variables: { profileId: noopUUID } });
		return {};
	}
</script>

<script lang="ts">
	let infiniteList = [];

	onMount(async () => {
		await KQL_NewestRouteQuery.query({ variables: { profileId: noopUUID } });
		infiniteList = $KQL_NewestRouteQuery.data?.feed?.edges ?? [];
	});

	async function loadMore(cursor: string) {
		const newData = await KQL_NewestRouteQuery.query({
			variables: { profileId: noopUUID, after: cursor }
		});
		infiniteList = [...infiniteList, ...newData.data?.feed?.edges];
	}
</script>

<svelte:head>
	<title>supanews | Newest</title>
</svelte:head>

<!-- Just for development help ✅ -->
<!-- <KitQLInfo store={KQL_NewestRouteQuery} /> -->

<section class="text-gray-600 body-font overflow-hidden w-full">
	<div class="container px-3 py-24 mx-auto">
		<div class="-my-8">
			{#each infiniteList as edge}
				<FeedItem post={edge.node} />
			{:else}
				{#if $KQL_NewestRouteQuery.status !== 'NEVER'}
					<Loading />
					{#each new Array(10) as item}
						<FeedItem post={null} />
					{/each}
				{:else}
					No data!
				{/if}
			{/each}
			{#if $KQL_NewestRouteQuery.isFetching}
				<Loading />
			{/if}
		</div>
	</div>

	<div class="flex justify-center content-center">
		<Button on:click={() => loadMore($KQL_NewestRouteQuery.data?.feed?.pageInfo.endCursor)}
			>Load more.</Button
		>
	</div>
</section>
