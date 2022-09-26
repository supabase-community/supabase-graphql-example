import React from "react";
import { NextPage } from "next";
import { useRouter } from "next/router";
import { Auth, Button } from "@supabase/ui";
import { CombinedError, useMutation, useQuery } from "urql";
import { Input } from "@supabase/ui";
import { DocumentType, gql } from "../gql";
import { Container } from "../lib/container";
import { Loading } from "../lib/loading";
import { MainSection } from "../lib/main-section";
import { withConfiguredUrql } from "../lib/urql";

const UserProfileQuery = gql(/* GraphQL */ `
  query UserProfileQuery($profileId: UUID!) {
    profileCollection(filter: { id: { eq: $profileId } }) {
      edges {
        node {
          ...AccountProfileFragment
        }
      }
    }
  }
`);

const Account: NextPage = () => {
  const session = Auth.useUser();
  const [profileQuery] = useQuery({
    query: UserProfileQuery,
    variables: { profileId: session.user?.id },
    pause: session.user === null,
  });
  const router = useRouter();

  const profile = profileQuery.data?.profileCollection?.edges?.[0].node;

  React.useEffect(() => {
    if (session.user === null || (profileQuery.data && profile === null)) {
      router.replace("/login");
    }
  }, [session.user, profile, profileQuery.data]);

  if (profile) {
    return <AccountForm profile={profile} />;
  }

  return (
    <div className="w-full">{profileQuery.fetching ? <Loading /> : null}</div>
  );

  return null;
};

const ProfileFragment = gql(/* GraphQL */ `
  fragment AccountProfileFragment on Profile {
    id
    username
    website
    bio
  }
`);

const UpdateProfileMutation = gql(/* GraphQL */ `
  mutation updateProfile(
    $userId: UUID!
    $newUsername: String!
    $newWebsite: String!
    $newBio: String!
  ) {
    updateProfileCollection(
      filter: { id: { eq: $userId } }
      set: { username: $newUsername, website: $newWebsite, bio: $newBio }
    ) {
      affectedCount
      records {
        id
        username
        website
      }
    }
  }
`);

function extractExpectedGraphQLErrors(
  error: CombinedError | undefined
): null | string {
  if (error === undefined) {
    return null;
  }

  for (const graphQLError of error.graphQLErrors) {
    if (graphQLError.message.includes("usernamelength")) {
      return "Username must have a minimum length of 3 characters.";
    }
    if (graphQLError.message.includes("Profile_username_key")) {
      return "The name is already taken.";
    }
  }

  return null;
}

function AccountForm(props: { profile: DocumentType<typeof ProfileFragment> }) {
  const [username, setUsername] = React.useState(props.profile.username ?? "");
  const [website, setWebsite] = React.useState(props.profile.website ?? "");
  const [bio, setBio] = React.useState(props.profile.bio ?? "");

  const [updateProfileMutation, updateProfile] = useMutation(
    UpdateProfileMutation
  );

  const errorState = extractExpectedGraphQLErrors(updateProfileMutation.error);

  return (
    <Container>
      <MainSection>
        <section className="container px-5 py-24 mx-auto max-w-md">
          <h1 className="font-semibold text-xl tracking-tight mb-5">Account</h1>
          <div className="mb-4">
            <label htmlFor="username" className="block mb-2">
              Name
            </label>
            <Input
              id="username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
          </div>
          <div className="mb-4">
            <label htmlFor="website" className="block mb-2">
              Website
            </label>
            <Input
              id="website"
              type="website"
              value={website}
              onChange={(e) => setWebsite(e.target.value)}
            />
          </div>

          <div className="mb-4">
            <label htmlFor="bio" className="block mb-2">
              Bio
            </label>
            <textarea
              id="bio"
              className="w-full border-solid  border-2 border-gray-100 rounded-sm"
              value={bio}
              onChange={(e) => setBio(e.target.value)}
            />
          </div>

          <div>
            <Button
              onClick={() =>
                updateProfile({
                  userId: props.profile.id,
                  newUsername: username,
                  newWebsite: website,
                  newBio: bio,
                })
              }
              disabled={updateProfileMutation.fetching}
            >
              {updateProfileMutation.fetching ? "Loading ..." : "Update"}
            </Button>
          </div>

          <div>{errorState}</div>
        </section>
      </MainSection>
    </Container>
  );
}

export default withConfiguredUrql(Account);
