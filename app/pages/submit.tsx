import React from "react";
import { NextPage } from "next";
import { useRouter } from "next/router";
import { Auth, Input, Button } from "@supabase/ui";
import { gql } from "../gql";
import { useMutation } from "urql";

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

  return (
    <form>
      <Input
        placeholder="Title"
        value={title}
        onChange={(ev) => setTitle(ev.target.value)}
      />
      <Input
        placeholder="URL"
        value={url}
        onChange={(ev) => setUrl(ev.target.value)}
      />
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
    </form>
  );
};

export default Submit;
