import { Button } from "@supabase/ui";
import type { NextPage } from "next";
import Head from "next/head";
import { useQuery } from "urql";
import { gql } from "../gql";
import { Container } from "../lib/container";
import { FeedItem } from "../lib/feed-item";
import { MainSection } from "../lib/main-section";

const IndexRouteQuery = gql(/* GraphQL */ `
  query IndexRouteQuery {
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
  const [indexQuery] = useQuery({ query: IndexRouteQuery });

  return (
    <Container>
      <Head>
        <title>supanews | Feed</title>
        <meta name="description" content="What is hot?" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <MainSection>
        <section className="text-gray-600 body-font overflow-hidden">
          <div className="container px-5 py-24 mx-auto">
            <div className="-my-8">
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
