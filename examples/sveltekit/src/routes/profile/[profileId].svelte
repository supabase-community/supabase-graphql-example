<script context="module" lang="ts">
	import { browser } from '$app/env';
	import CommentItem from '$lib/components/hackernews/comment/CommentItem.svelte';
	import FeedItem from '$lib/components/hackernews/post/FeedItem.svelte';
	import Loading from '$lib/components/layout/Loading.svelte';
	import { KQL_ProfileRouteQuery } from '$lib/graphql/_kitql/graphqlStores';

	export async function load({ fetch, params }) {
		const { profileId } = params;

		if (browser) {
			KQL_ProfileRouteQuery.patch(null, { profileId }, 'store-only');
		}

		await KQL_ProfileRouteQuery.queryLoad({ fetch, variables: { profileId } });
		return {};
	}
</script>

<script lang="ts">
	$: profile = $KQL_ProfileRouteQuery.data?.profileCollection?.edges?.[0].node;
</script>

<svelte:head>
	<title>supanews | {profile?.username}</title>
	<meta name="description" content="What is hot?" />
</svelte:head>

<div class="w-full">
	{#if $KQL_ProfileRouteQuery.isFetching}
		<Loading />
	{:else if $KQL_ProfileRouteQuery.data}
		<section class="text-gray-600 body-font overflow-hidden">
			<div class="container px-5 py-24 pt-10 mx-auto">
				<h1 class="font-semibold text-xl tracking-tight mb-5">Profile</h1>
				{' '}
				<div>
					<span class="inline-block font-bold pr-2 w-20">User</span>{' '}
					{profile.username}
				</div>
				<div>
					<span class="inline-block font-bold pr-2 w-20"> Avatar </span>{' '}
					<img
						class="inline-block h-6 w-6 rounded-full"
						src={profile.avatarUrl ?? ''}
						alt="avatar"
					/>
				</div>
				<div>
					<span class="inline-block font-bold pr-2 w-20"> Website </span>{' '}
					{profile.website}
				</div>
				<div class="mb-10">
					<span class="inline-block font-bold pr-2 w-20">Bio</span>{' '}
					{profile.bio}
				</div>
				<h1 class="font-semibold text-xl tracking-tight mb-5">Latest Posts</h1>
				<div>
					{#each profile.latestPosts?.edges ?? [] as edge}
						<FeedItem post={edge.node} />
					{/each}
				</div>
				<h1 class="font-semibold text-xl tracking-tight mb-5">Latest Comments</h1>
				{#each profile.latestComments?.edges ?? [] as edge}
					<CommentItem comment={edge.node} />
				{/each}
			</div>
		</section>
	{/if}
</div>
