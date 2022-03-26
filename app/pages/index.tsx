import { Auth, Button } from "@supabase/ui";
import type { NextPage } from "next";
import Head from "next/head";
import { useQuery } from "urql";
import { gql } from "../gql";
import { Container } from "../lib/container";
import { FeedItem } from "../lib/feed-item";
import { Loading } from "../lib/loading";
import { MainSection } from "../lib/main-section";
import { noopUUID } from "../lib/noop-uuid";

const IndexRouteQuery = gql(/* GraphQL */ `
  query IndexRouteQuery($profileId: UUID!) {
    feed: postCollection(
      orderBy: [
        { voteRank: AscNullsFirst }
        { score: DescNullsFirst }
        { createdAt: DescNullsFirst }
      ]
      first: 15
    ) {
      pageInfo {
        hasNextPage
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
  const [indexQuery] = useQuery({
    query: IndexRouteQuery,
    variables: {
      profileId: user?.id ?? noopUUID,
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
              {indexQuery.fetching && <Loading />}
              {indexQuery?.data?.feed?.edges.map((edge) => (
                <FeedItem post={edge.node!} key={edge.cursor} />
              ))}
            </div>
          </div>
          {indexQuery.data?.feed?.pageInfo.hasNextPage ? (
            <div className="flex justify-center content-center">
              <Button>Load more.</Button>
            </div>
          ) : null}
        </section>
      </MainSection>
    </Container>
  );
};

export default Home;
