import { Button } from "@supabase/ui";
import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";
import { useQuery } from "urql";
import { gql } from "../gql";
import { CommentItem } from "../lib/comment-item";
import { Container } from "../lib/container";
import { Loading } from "../lib/loading";
import { MainSection } from "../lib/main-section";

const CommentsRouteQuery = gql(/* GraphQL */ `
  query CommentsRouteQuery {
    comments: commentCollection(
      orderBy: [{ createdAt: DescNullsFirst }]
      first: 15
    ) {
      pageInfo {
        hasNextPage
      }
      edges {
        cursor
        node {
          id
          ...CommentItem_CommentFragment
        }
      }
    }
  }
`);

const Comments: NextPage = () => {
  const [commentsQuery] = useQuery({ query: CommentsRouteQuery });

  return (
    <Container>
      <MainSection>
        <Head>
          <title>supanews | Comments</title>
          <meta name="description" content="New comments" />
          <link rel="icon" href="/favicon.ico" />
        </Head>

        <section className="text-gray-600 body-font overflow-hidden w-full">
          <div className="container px-3 py-24 mx-auto">
            {commentsQuery.fetching && <Loading />}
            <div className="-my-8 divide-y-2 divide-gray-100">
              {commentsQuery?.data?.comments?.edges.map((edge) => (
                <CommentItem comment={edge.node!} key={edge.cursor} />
              ))}
            </div>
          </div>
          {commentsQuery.data?.comments?.pageInfo.hasNextPage ? (
            <div className="flex justify-center content-center">
              <Button>Load more.</Button>
            </div>
          ) : null}
        </section>
      </MainSection>
    </Container>
  );
};

export default Comments;
