import { Button } from "@supabase/ui";
import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";
import React from "react";
import { useQuery } from "urql";
import { gql } from "../gql";
import { CommentItem } from "../lib/comment-item";
import { Container } from "../lib/container";
import { Loading } from "../lib/loading";
import { MainSection } from "../lib/main-section";
import { withConfiguredUrql } from "../lib/urql";
import { usePaginatedQuery } from "../lib/use-paginated-query";

const CommentsRouteQuery = gql(/* GraphQL */ `
  query CommentsRouteQuery($after: Cursor) {
    comments: commentCollection(
      orderBy: [{ createdAt: DescNullsFirst }]
      first: 15
      after: $after
    ) {
      pageInfo {
        hasNextPage
        endCursor
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
  const [lastCursor, setLastCursor] = React.useState<string | undefined>(
    undefined
  );
  const [commentsQuery] = usePaginatedQuery({
    query: CommentsRouteQuery,
    variables: {
      after: lastCursor,
    },
    mergeResult(oldData, newData) {
      return {
        ...oldData,
        ...newData,
        comments: {
          ...oldData.comments!,
          ...newData.comments!,
          edges: [...oldData.comments!.edges, ...newData.comments!.edges],
        },
      };
    },
  });

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
            <div className="-my-8 divide-y-2 divide-gray-100">
              {commentsQuery?.data?.comments?.edges.map((edge) => (
                <CommentItem comment={edge.node!} key={edge.cursor} />
              ))}
            </div>
            {commentsQuery.fetching ? <Loading /> : null}
          </div>
          {commentsQuery.data?.comments?.pageInfo.hasNextPage ? (
            <div className="flex justify-center content-center">
              <Button
                onClick={() =>
                  setLastCursor(
                    commentsQuery.data?.comments?.pageInfo.endCursor ??
                      undefined
                  )
                }
              >
                Load more.
              </Button>
            </div>
          ) : null}
        </section>
      </MainSection>
    </Container>
  );
};

export default withConfiguredUrql(Comments);
