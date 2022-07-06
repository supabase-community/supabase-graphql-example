<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import Icons from '$lib/components/layout/Icons.svelte';
	import {
		KQL_IndexRouteQuery,
		KQL_NewestRouteQuery,
		KQL_VoteButtonsDeleteVoteMutation,
		KQL_VoteButtonsVoteMutation
	} from '$lib/graphql/_kitql/graphqlStores';
	import type { FeedItem_PostFragmentFragment } from '$lib/graphql/_kitql/graphqlTypes';
	import { userStore } from '$lib/utils/userStore';
	import { get } from 'svelte/store';

	export let post: FeedItem_PostFragmentFragment | null;

	async function vote(voteDirection: 'UP' | 'DOWN') {
		let user = get(userStore);
		if (!user) {
			goto('/login');
		} else if (
			(voteDirection === 'UP' && post.upVoteByViewer?.totalCount === 0) ||
			(voteDirection === 'DOWN' && post.downVoteByViewer?.totalCount === 0)
		) {
			// Double mutation?!
			await KQL_VoteButtonsDeleteVoteMutation.mutate({
				variables: {
					postId: post.id,
					profileId: user.id
				}
			});
			await KQL_VoteButtonsVoteMutation.mutate({
				variables: {
					postId: post.id,
					profileId: user.id,
					voteDirection
				}
			});

			// Not that nice to check the page here! And what about the item page.
			// And what about Optimistic UI?
			if ($page.url.pathname === '/') {
				KQL_IndexRouteQuery.query({
					variables: { profileId: user.id },
					settings: { policy: 'network-only' }
				});
				KQL_NewestRouteQuery.resetCache();
			}
			if ($page.url.pathname === '/newest') {
				KQL_NewestRouteQuery.query({
					variables: { profileId: user.id },
					settings: { policy: 'network-only' }
				});
				KQL_IndexRouteQuery.resetCache();
			}
		}
	}
</script>

<div class="flex flex-col self-center mr-3 pb-8">
	<button disabled={post.upVoteByViewer?.totalCount !== 0} on:click={() => vote('UP')}>
		<Icons name="ChevronUpIcon" strokeWidth={post.upVoteByViewer?.totalCount !== 0 ? 4 : 2} />
	</button>
	<button disabled={post.downVoteByViewer?.totalCount !== 0} on:click={() => vote('DOWN')}>
		<Icons name="ChevronDownIcon" strokeWidth={post.downVoteByViewer?.totalCount !== 0 ? 4 : 2} />
	</button>
</div>
