import React from "react";
import { NextPage } from "next";
import Head from "next/head";
import { useRouter } from "next/router";
import { Auth, Input, Button } from "@supabase/ui";
import { gql } from "../gql";
import { CombinedError, useMutation } from "urql";
import { Container } from "../lib/container";
import { MainSection } from "../lib/main-section";

const CreatePostMutation = gql(/* GraphQL */ `
  mutation createPostMutation($input: PostInsertInput!) {
    insertIntoPostCollection(objects: [$input]) {
      affectedCount
      records {
        id
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
    if (graphQLError.message.includes("Post_url_key")) {
      return "This news has already been submitted.";
    }
  }

  return null;
}

const Submit: NextPage = () => {
  const session = Auth.useUser();
  const router = useRouter();
  const [createPostMutation, createPost] = useMutation(CreatePostMutation);
  const [title, setTitle] = React.useState("");
  const [url, setUrl] = React.useState("");

  React.useEffect(() => {
    if (session.user === null) {
      router.replace("/login");
    }
  }, []);

  React.useEffect(() => {
    if (createPostMutation.fetching === false && createPostMutation.data) {
      router.push(
        `/item/${createPostMutation.data.insertIntoPostCollection?.records[0].id}`
      );
    }
  }, [createPostMutation.fetching]);

  if (session.user == null) {
    return null;
  }

  const error = extractExpectedGraphQLErrors(createPostMutation.error);

  return (
    <Container>
      <Head>
        <title>supanews | Submit New Item</title>
        <meta name="description" content="What is hot?" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <MainSection>
        <form className="container px-5 py-24 mx-auto max-w-md">
          <h1 className="font-semibold text-xl tracking-tight mb-5">Submit</h1>
          <div className="mb-4">
            <Input
              placeholder="Title"
              value={title}
              onChange={(ev) => setTitle(ev.target.value)}
            />
          </div>
          <div className="mb-4">
            <Input
              placeholder="URL"
              value={url}
              onChange={(ev) => setUrl(ev.target.value)}
            />
          </div>
          <div className="mb-4 min-h-1">{error}</div>
          {createPostMutation.fetching ? (
            <Button type="outline">Loading...</Button>
          ) : (
            <Button
              onClick={() => {
                createPost({
                  input: {
                    url,
                    title,
                    profileId: session.user!.id,
                    score: 1,
                  },
                });
              }}
            >
              Submit
            </Button>
          )}
        </form>
      </MainSection>
    </Container>
  );
};

export default Submit;
