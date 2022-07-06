<script lang="ts">
	import Icons from '$lib/components/layout/Icons.svelte';
	import LoadingInPlace from '$lib/components/layout/LoadingInPlace.svelte';
	import type { CommentItem_CommentFragmentFragment } from '$lib/graphql/_kitql/graphqlTypes';
	import { addS } from '$lib/utils/formatString';
	import { timeAgo } from '$lib/utils/time-ago';

	export let comment: CommentItem_CommentFragmentFragment | null;
</script>

{#if comment}
	<div class="flex space-x-3 py-4">
		<img class="h-6 w-6 rounded-full" src={comment.profile?.avatarUrl ?? undefined} alt="" />
		<div class="flex-1 space-y-1">
			<div class="flex items-center justify-between">
				<h3 class="text-sm font-medium">
					<a href={`/profile/${comment.profile?.id}`} class="text-gray-800 hover:text-green-500">
						{comment.profile?.username}
					</a>
				</h3>
				<p class="text-sm text-gray-500">
					<a
						href={`/item/${comment.post?.id}`}
						class="text-gray-800 hover:text-green-500 inline-flex items-center text-sm"
					>
						<Icons name="CalendarIcon" class="w-4 h-4 mr-1" />
						{timeAgo.format(new Date(comment.createdAt))}
					</a>
				</p>
			</div>
			<p class="text-sm text-gray-500">
				{comment.message}
				<!-- {user?.id && user.id === props.comment.profile?.id ? (
      <button
        type="button"
        class="inline-flex items-center ml-2 p-1 border border-transparent rounded-full shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
        onClick={() => {
          deleteComment({
            commentId: props.comment.id,
          });
        }}
      >
        <TrashIcon class="h-2 w-2" />
      </button>
    ) : null} -->
			</p>
		</div>
	</div>
{:else}
	<div class="flex space-x-3 py-4">
		<span class="inline-block h-6 w-6 rounded-full mr-1 bg-slate-400" />
		<div class="flex-1 space-y-1">
			<div class="flex items-center justify-between">
				<h3 class="text-sm font-medium">
					<span class="text-gray-800 hover:text-green-500">
						<LoadingInPlace class="h-8" />
					</span>
				</h3>
				<p class="text-sm text-gray-500">
					<span class="text-gray-800 hover:text-green-500 inline-flex items-center text-sm">
						<Icons name="CalendarIcon" class="w-4 h-4 mr-1" />
						{addS(0, 'days ago')}
					</span>
				</p>
			</div>
			<p class="text-sm text-gray-500">
				<LoadingInPlace class="h-8" />
			</p>
		</div>
	</div>
{/if}
