import { Auth, Button } from "@supabase/ui";
import type { NextPage } from "next";
import Head from "next/head";
import React from "react";
import { gql } from "../gql";
import { Container } from "../lib/container";
import { FeedItem } from "../lib/feed-item";
import { Loading } from "../lib/loading";
import { MainSection } from "../lib/main-section";
import { noopUUID } from "../lib/noop-uuid";
import { usePaginatedQuery } from "../lib/use-paginated-query";

const IndexRouteQuery = gql(/* GraphQL */ `
  query IndexRouteQuery($profileId: UUID!, $after: Cursor) {
    feed: postCollection(
      orderBy: [
        { voteRank: AscNullsFirst }
        { score: DescNullsFirst }
        { createdAt: DescNullsFirst }
      ]
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
          ...FeedItem_PostFragment
        }
      }
    }
  }
`);

const Home: NextPage = () => {
  const { user } = Auth.useUser();
  const [lastCursor, setLastCursor] = React.useState<string | undefined>(
    undefined
  );
  const [indexQuery] = usePaginatedQuery({
    query: IndexRouteQuery,
    variables: {
      profileId: user?.id ?? noopUUID,
      after: lastCursor,
    },
    mergeResult(oldData, newData) {
      return {
        ...oldData,
        ...newData,
        feed: {
          ...oldData.feed!,
          ...newData.feed!,
          edges: [...oldData.feed!.edges, ...newData.feed!.edges],
        },
      };
    },
  });

  return (
    <Container>
      <Head>
        <title>supanews | Feed</title>
        <meta name="description" content="What is hot?" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <MainSection>
        <section className="text-gray-600 body-font overflow-hidden w-full">
          <div className="container px-3 py-24 mx-auto">
            <div className="-my-8">
              {indexQuery?.data?.feed?.edges.map((edge) => (
                <FeedItem post={edge.node!} key={edge.cursor} />
              ))}
              {indexQuery.fetching ? <Loading /> : null}
            </div>
          </div>
          {indexQuery.data?.feed?.pageInfo.hasNextPage ? (
            <div className="flex justify-center content-center">
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
          ) : null}
        </section>
      </MainSection>
    </Container>
  );
};

export default Home;
