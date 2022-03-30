<script context="module" lang="ts">
	import FeedItem from '$lib/FeedItem.svelte';
	import { KQL_IndexRouteQuery } from '$lib/graphql/_kitql/graphqlStores';
	import Loading from '$lib/Loading.svelte';
	import { noopUUID } from '$lib/noop-uuid';
	import { KitQLInfo } from '@kitql/all-in';

	export async function load({ fetch, url, params, session, stuff }) {
		await KQL_IndexRouteQuery.queryLoad({ fetch, variables: { profileId: noopUUID } });
		return {};
	}
</script>

<svelte:head>
	<title>supanews | Feed</title>
</svelte:head>

<!-- Just for development purposes. -->
<KitQLInfo store={KQL_IndexRouteQuery} />

<section class="text-gray-600 body-font overflow-hidden w-full">
	<div class="container px-3 py-24 mx-auto">
		<div class="-my-8">
			{#each $KQL_IndexRouteQuery.data?.feed?.edges ?? [] as edge}
				<FeedItem post={edge.node} />
			{:else}
				No data
			{/each}
			{#if $KQL_IndexRouteQuery.isFetching}
				<Loading />
			{/if}
		</div>
	</div>
	<!-- {indexQuery.data?.feed?.pageInfo.hasNextPage ? (
		<div class="flex justify-center content-center">
			<Button
				onClick={() => {
					setLastCursor(
						indexQuery.data?.feed?.pageInfo.endCursor ?? undefined
					);
				}}
			>
				Load more.
			</Button>
		</div>
	) : null} -->
</section>
