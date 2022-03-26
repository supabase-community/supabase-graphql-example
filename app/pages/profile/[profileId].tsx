import type { NextPage } from "next";
import Head from "next/head";
import { useRouter } from "next/router";
import { useQuery } from "urql";
import { gql } from "../../gql";
import { CommentItem } from "../../lib/comment-item";
import { Container } from "../../lib/container";
import { FeedItem } from "../../lib/feed-item";
import { Loading } from "../../lib/loading";
import { MainSection } from "../../lib/main-section";

const ProfileRouteQuery = gql(/* GraphQL */ `
  query ProfileRouteQuery($profileId: UUID!) {
    profileCollection(filter: { id: { eq: $profileId } }) {
      edges {
        node {
          id
          username
          bio
          avatarUrl
          website
          latestPosts: postCollection(
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
                ...FeedItem_PostFragment
              }
            }
          }
          latestComments: commentCollection(
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
      }
    }
  }
`);

const Profile: NextPage = () => {
  const router = useRouter();
  const { profileId } = router.query;
  const [profileQuery] = useQuery({
    query: ProfileRouteQuery,
    variables: {
      profileId,
    },
  });

  const profile = profileQuery.data?.profileCollection?.edges?.[0].node;

  return (
    <Container>
      <Head>
        <title>supanews | {profile?.username}</title>
        <meta name="description" content="What is hot?" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <MainSection>
        <div className="w-full">
          {profileQuery.fetching && <Loading />}
          {profile == null ? null : (
            <section className="text-gray-600 body-font overflow-hidden">
              <div className="container px-5 py-24 pt-10 mx-auto">
                <h1 className="font-semibold text-xl tracking-tight mb-5">
                  Profile
                </h1>{" "}
                <div>
                  <span className="inline-block font-bold pr-2 w-20">User</span>{" "}
                  {profile.username}
                </div>
                <div>
                  <span className="inline-block font-bold pr-2 w-20">
                    Avatar
                  </span>{" "}
                  <img
                    className="inline-block h-6 w-6 rounded-full"
                    src={profile.avatarUrl}
                  />
                </div>
                <div>
                  <span className="inline-block font-bold pr-2 w-20">
                    Website
                  </span>{" "}
                  {profile.website}
                </div>
                <div className="mb-10">
                  <span className="inline-block font-bold pr-2 w-20">Bio</span>{" "}
                  {profile.bio}
                </div>
                <h1 className="font-semibold text-xl tracking-tight mb-5">
                  Latest Posts
                </h1>
                <div>
                  {profile.latestPosts?.edges.map((edge) => (
                    <FeedItem post={edge.node!} key={edge.cursor} />
                  ))}
                </div>
                <h1 className="font-semibold text-xl tracking-tight mb-5">
                  Latest Comments
                </h1>
                {profile.latestComments?.edges.map((edge) => (
                  <CommentItem comment={edge.node!} key={edge.cursor} />
                ))}
              </div>
            </section>
          )}
        </div>
      </MainSection>
    </Container>
  );
};

export default Profile;
