import { Auth, Button } from "@supabase/ui";
import React from "react";
import type { NextPage } from "next";
import Head from "next/head";
import { useRouter } from "next/router";
import { useMutation, useQuery } from "urql";
import { gql } from "../../gql";
import { CommentItem } from "../../lib/comment-item";
import { Container } from "../../lib/container";
import { FeedItem } from "../../lib/feed-item";
import { MainSection } from "../../lib/main-section";
import { noopUUID } from "../../lib/noop-uuid";

const ItemRouteQuery = gql(/* GraphQL */ `
  query ItemRouteQuery($postId: BigInt!, $profileId: UUID!) {
    post: postCollection(filter: { id: { eq: $postId } }, first: 1) {
      edges {
        cursor
        node {
          id
          ...FeedItem_PostFragment
          comments: commentCollection(
            first: 15
            orderBy: [{ createdAt: DescNullsLast }]
          ) {
            edges {
              cursor
              node {
                id
                ...CommentItem_CommentFragment
              }
            }
            pageInfo {
              hasNextPage
            }
          }
        }
      }
    }
  }
`);

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
      <div className="mb-2 font-bold">Write comment</div>
      <textarea
        className="w-full border-solid  border-2 border-gray-100 rounded-sm"
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

  if (post == null) {
    return null;
  }

  return (
    <Container>
      <MainSection>
        {post.node == null ? null : (
          <>
            <Head>
              <title>supanews | {post.node?.title}</title>
              <meta name="description" content={post.node?.url} />
            </Head>
            <section className="text-gray-600 body-font overflow-hidden w-full">
              <div className="container px-5 py-24 mx-auto">
                <FeedItem post={post.node} key={post.cursor} />

                <div className="max-w-md">
                  <PostCommentForm postId={post.node.id} />

                  <div className="mt-10">
                    {post.node?.comments?.edges.map((edge) => (
                      <CommentItem comment={edge.node!} key={edge.cursor} />
                    ))}
                  </div>
                </div>
              </div>
            </section>
          </>
        )}
      </MainSection>
    </Container>
  );
};

export default Item;
