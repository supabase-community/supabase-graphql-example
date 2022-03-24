import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";
import { useRouter } from "next/router";
import { useQuery } from "urql";
import { gql } from "../../gql";
import { Container } from "../../lib/container";
import { FeedItem } from "../../lib/feed-item";
import { MainSection } from "../../lib/main-section";

const ItemRouteQuery = gql(/* GraphQL */ `
  query ItemRouteQuery($postId: BigInt!) {
    post: postCollection(filter: { id: { eq: $postId } }, first: 1) {
      edges {
        cursor
        node {
          id
          ...FeedItem_PostFragment
        }
      }
    }
  }
`);

const Item: NextPage = () => {
  const router = useRouter();
  const { postId } = router.query;
  const [itemRouteQuery] = useQuery({
    query: ItemRouteQuery,
    variables: {
      postId,
    },
  });

  const post = itemRouteQuery?.data?.post?.edges?.[0];

  if (post == null) {
    return null;
  }

  return (
    <Container>
      <MainSection>
        {post === null ? null : (
          <>
            <Head>
              <title>supanews | {post.node?.title}</title>
              <meta name="description" content={post.node?.url} />
            </Head>
            <section className="text-gray-600 body-font overflow-hidden">
              <div className="container px-5 py-24 mx-auto">
                <FeedItem post={post.node!} key={post.cursor} />
              </div>
            </section>
          </>
        )}
      </MainSection>
    </Container>
  );
};

export default Item;
