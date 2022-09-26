<script context="module" lang="ts">
	// import { KitQLInfo } from '@kitql/all-in';
	import FeedItem from '$lib/components/hackernews/post/FeedItem.svelte';
	import Loading from '$lib/components/layout/Loading.svelte';
	import Button from '$lib/components/supabase/ui/Button.svelte';
	import { KQL_NewestRouteQuery } from '$lib/graphql/_kitql/graphqlStores';
	import { noopUUID } from '$lib/utils/noop-uuid';
	import { onMount } from 'svelte';

	export async function load({ fetch, session }) {
		const profileId = session.user ? session.user.id : noopUUID;
		await KQL_NewestRouteQuery.queryLoad({ fetch, variables: { profileId } });
		return { porps: { profileId } };
	}
</script>

<script lang="ts">
	export let profileId;
	$: infiniteList = $KQL_NewestRouteQuery.data?.feed?.edges ?? [];

	onMount(async () => {
		await KQL_NewestRouteQuery.query({ variables: { profileId } });
	});

	async function loadMore(cursor: string) {
		const newData = await KQL_NewestRouteQuery.query({
			variables: { profileId, after: cursor }
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
