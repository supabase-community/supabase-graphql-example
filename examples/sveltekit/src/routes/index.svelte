<script context="module" lang="ts">
	// import { KitQLInfo } from '@kitql/all-in';
	import FeedItem from '$lib/components/hackernews/post/FeedItem.svelte';
	import Loading from '$lib/components/layout/Loading.svelte';
	import Button from '$lib/components/supabase/ui/Button.svelte';
	import { KQL_IndexRouteQuery } from '$lib/graphql/_kitql/graphqlStores';
	import { noopUUID } from '$lib/utils/noop-uuid';
	import { onMount } from 'svelte';

	export async function load({ fetch, session }) {
		const profileId = session.user ? session.user.id : noopUUID;
		await KQL_IndexRouteQuery.queryLoad({ fetch, variables: { profileId } });
		return {
			props: { profileId }
		};
	}
</script>

<script lang="ts">
	export let profileId: string;

	$: infiniteList = $KQL_IndexRouteQuery.data?.feed?.edges ?? [];

	onMount(async () => {
		await KQL_IndexRouteQuery.query({ variables: { profileId } });
	});

	async function loadMore(cursor: string) {
		const newData = await KQL_IndexRouteQuery.query({
			variables: { profileId, after: cursor }
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
				{#if $KQL_IndexRouteQuery.status !== 'NEVER'}
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
