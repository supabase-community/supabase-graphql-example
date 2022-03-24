import { Button } from "@supabase/ui";
import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";
import { useQuery } from "urql";
import { gql } from "../gql";
import { FeedItem } from "../lib/feed-item";
import styles from "../styles/Home.module.css";

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
    <div className={styles.container}>
      <Head>
        <title>supanews | Feed</title>
        <meta name="description" content="What is hot?" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <section className="text-gray-600 body-font overflow-hidden">
          <div className="container px-5 py-24 mx-auto">
            <div className="-my-8 divide-y-2 divide-gray-100">
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
      </main>

      <footer className={styles.footer}>
        <a
          href="https://vercel.com?utm_source=create-next-app&utm_medium=default-template&utm_campaign=create-next-app"
          target="_blank"
          rel="noopener noreferrer"
        >
          Powered by{" "}
          <span className={styles.logo}>
            <Image src="/vercel.svg" alt="Vercel Logo" width={72} height={16} />
          </span>
        </a>
      </footer>
    </div>
  );
};

export default Home;
