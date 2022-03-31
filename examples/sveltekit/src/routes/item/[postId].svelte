<script context="module" lang="ts">
	import FeedItem from '$lib/FeedItem.svelte';
	import { KQL_IndexRouteQuery, KQL_ItemRouteQuery } from '$lib/graphql/_kitql/graphqlStores';
	import type { ItemRouteQueryQuery } from '$lib/graphql/_kitql/graphqlTypes';
	import Loading from '$lib/Loading.svelte';
	import { noopUUID } from '$lib/utils/noop-uuid';
	import { get } from 'svelte/store';

	export async function load({ fetch, url, params, session, stuff }) {
		const { postId } = params;

		const postFound = get(KQL_IndexRouteQuery).data.feed.edges.find((c) => c.node.id === postId);
		if (postFound) {
			const newItem: ItemRouteQueryQuery = {
				__typename: 'Query',
				post: {
					edges: [postFound]
				}
			};
			KQL_ItemRouteQuery.patch(newItem, { postId, profileId: noopUUID }, 'store-only');
		}

		await KQL_ItemRouteQuery.queryLoad({ fetch, variables: { postId, profileId: noopUUID } });
		return {};
	}
</script>

<svelte:head>
	<title>supanews | {$KQL_ItemRouteQuery.data?.post.edges[0].node.title}</title>
	<meta name="description" content={$KQL_ItemRouteQuery.data?.post.edges[0].node.url} />
</svelte:head>

<div class="h-screen w-full">
	{#if $KQL_ItemRouteQuery.isFetching}
		<Loading />
	{/if}

	<section class="text-gray-600 body-font overflow-hidden w-full">
		<div class="container px-5 py-24 mx-auto">
			<FeedItem post={$KQL_ItemRouteQuery.data?.post.edges[0].node} />

			<div class="max-w-md">
				<!-- {user && <PostCommentForm postId={post.node.id} />} -->

				<div class="mt-10">
					<!-- {post.node?.comments?.edges.map((edge) => (
                <CommentItem comment={edge.node!} key={edge.cursor} />
              ))} -->
				</div>
			</div>
		</div>
	</section>
</div>

<!-- import { Auth, Button } from "@supabase/ui";
import React from "react";
import type { NextPage } from "next";
import Head from "next/head";
import { useRouter } from "next/router";
import { useMutation, useQuery } from "urql";
import { gql } from "../../gql";
import { CommentItem } from "../../lib/comment-item";
import { Container } from "../../lib/container";
import { FeedItem } from "../../lib/feed-item";
import { Loading } from "../../lib/loading";
import { MainSection } from "../../lib/main-section";
import { noopUUID } from "../../lib/noop-uuid";

const PostCommentMutation = gql(/* GraphQL */ `
  mutation postComment($profileId: UUID!, $message: String!, $postId: BigInt) {
    insertIntoCommentCollection(
      objects: [{ profileId: $profileId, message: $message, postId: $postId }]
    ) {
      affectedCount
    }
  }
`);

function PostCommentForm(props: { postId: string }) {
  const [postCommentMutation, postComment] = useMutation(PostCommentMutation);
  const [message, setMessage] = React.useState("");
  const { user } = Auth.useUser();
  const router = useRouter();

  React.useEffect(() => {
    if (postCommentMutation.data) {
      router.reload();
    }
  }, [postCommentMutation.data]);

  return (
    <form>
      <div class="mb-2 font-bold">Write comment</div>
      <textarea
        class="w-full border-solid  border-2 border-gray-100 rounded-sm"
        value={message}
        onChange={(ev) => setMessage(ev.target.value)}
      />
      <Button
        onClick={() => {
          postComment({
            profileId: user?.id!,
            message,
            postId: props.postId,
          });
        }}
      >
        add comment
      </Button>
    </form>
  );
}

const Item: NextPage = () => {
  const { user } = Auth.useUser();
  const router = useRouter();
  const { postId } = router.query;
  const [itemRouteQuery] = useQuery({
    query: ItemRouteQuery,
    variables: {
      postId,
      profileId: user?.id ?? noopUUID,
    },
  });

  const post = itemRouteQuery?.data?.post?.edges?.[0];

  return (
    <Container>
      <MainSection>
        JYCJYC
      </MainSection>
    </Container>
  );
};

export default Item; -->
