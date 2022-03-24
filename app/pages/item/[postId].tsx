import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";
import { useRouter } from "next/router";
import { useQuery } from "urql";
import { gql } from "../../gql";
import { FeedItem } from "../../lib/feed-item";
import styles from "../../styles/Home.module.css";

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

const Item: NextPage = (args) => {
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
    <div className={styles.container}>
      <Head>
        <title>supanews | Feed</title>
        <meta name="description" content="What is hot?" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <section className="text-gray-600 body-font overflow-hidden">
          <div className="container px-5 py-24 mx-auto">
            <FeedItem post={post.node!} key={post.cursor} />
          </div>
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

export default Item;
