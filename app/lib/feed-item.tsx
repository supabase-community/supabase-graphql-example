import { Auth } from "@supabase/ui";
import Link from "next/link";
import { useRouter } from "next/router";
import React from "react";
import { useMutation } from "urql";
import { Modal } from "@supabase/ui";

import { DocumentType, gql } from "../gql";
import {
  CalendarIcon,
  ChevronDownIcon,
  ChevronUpIcon,
  CommentIcon,
  PointIcon,
  TrashIcon,
  UserIcon,
} from "./icons";
import { timeAgo } from "./time-ago";

const VoteButtons_PostFragment = gql(/* GraphQL */ `
  fragment VoteButtons_PostFragment on Post {
    id
    upVoteByViewer: voteCollection(
      filter: { profileId: { eq: $profileId }, direction: { eq: "UP" } }
    ) {
      totalCount
    }
    downVoteByViewer: voteCollection(
      filter: { profileId: { eq: $profileId }, direction: { eq: "DOWN" } }
    ) {
      totalCount
    }
  }
`);

const VoteButtons_DeleteVoteMutation = gql(/* GraphQL */ `
  mutation VoteButtons_DeleteVoteMutation($postId: BigInt!, $profileId: UUID!) {
    deleteFromVoteCollection(
      filter: { postId: { eq: $postId }, profileId: { eq: $profileId } }
    ) {
      __typename
    }
  }
`);

const VoteButtons_VoteMutation = gql(/* GraphQL */ `
  mutation VoteButtons_VoteMutation(
    $postId: BigInt!
    $profileId: UUID!
    $voteDirection: String!
  ) {
    insertIntoVoteCollection(
      objects: [
        { postId: $postId, profileId: $profileId, direction: $voteDirection }
      ]
    ) {
      __typename
      affectedCount
      records {
        id
        direction
      }
    }
  }
`);

function VoteButtons(props: {
  post: DocumentType<typeof VoteButtons_PostFragment>;
}) {
  const router = useRouter();
  const { user } = Auth.useUser();
  const [, deleteVote] = useMutation(VoteButtons_DeleteVoteMutation);
  const [voteMutation, vote] = useMutation(VoteButtons_VoteMutation);

  React.useEffect(() => {
    if (voteMutation.data) {
      router.reload();
    }
  }, [voteMutation.data]);

  return (
    <div className="flex flex-col self-center mr-3 pb-8">
      <button
        onClick={async () => {
          if (!user) {
            router.push("/login");
          } else if (props.post.upVoteByViewer?.totalCount === 0) {
            await deleteVote({
              postId: props.post.id,
              profileId: user.id,
            });
            vote({
              postId: props.post.id,
              profileId: user.id,
              voteDirection: "UP",
            });
          }
        }}
      >
        <ChevronUpIcon
          strokeWidth={props.post.upVoteByViewer?.totalCount !== 0 ? "4" : "2"}
        />
      </button>
      <button
        onClick={async () => {
          if (!user) {
            router.push("/login");
          } else if (props.post.downVoteByViewer?.totalCount === 0) {
            await deleteVote({
              postId: props.post.id,
              profileId: user.id,
            });
            vote({
              postId: props.post.id,
              profileId: user.id,
              voteDirection: "DOWN",
            });
          }
        }}
      >
        <ChevronDownIcon
          strokeWidth={
            props.post.downVoteByViewer?.totalCount !== 0 ? "4" : "2"
          }
        />
      </button>
    </div>
  );
}

const FeedItem_PostFragment = gql(/* GraphQL */ `
  fragment FeedItem_PostFragment on Post {
    id
    title
    url
    voteTotal
    createdAt
    commentCollection {
      totalCount
    }
    profile {
      id
      username
    }
    ...VoteButtons_PostFragment
    ...DeleteButton_PostFragment
  }
`);

export function FeedItem(props: {
  post: DocumentType<typeof FeedItem_PostFragment>;
}) {
  const { user } = Auth.useUser();
  const createdAt = React.useMemo(
    () => timeAgo.format(new Date(props.post.createdAt)),
    [props.post.createdAt]
  );
  return (
    <div className="py-1 flex flex-wrap md:flex-nowrap mb-8 border-gray-100 border-b-2">
      <VoteButtons post={props.post} />
      <div className="flex-1 md:flex-grow">
        <Link href={props.post.url}>
          <a>
            <h2 className="text-2xl font-medium text-gray-900 title-font mb-2">
              {props.post.title}
            </h2>
          </a>
        </Link>

        <div className="flex items-center flex-wrap pb-4 border-gray-100 mt-auto w-full">
          <span className="text-gray-400 mr-3 inline-flex items-center  text-sm pr-3 py-1 border-r-2 border-gray-200">
            <PointIcon className="w-4 h-4 mr-1" />
            {props.post.voteTotal}{" "}
            {props.post.voteTotal === 1 ? "point" : "points"}
          </span>
          <Link href={`/item/${props.post.id}`}>
            <a className="text-gray-400 mr-3 inline-flex items-center text-sm pr-3 py-1 border-r-2 border-gray-200">
              <CommentIcon className="w-4 h-4 mr-1" />
              {props.post.commentCollection?.totalCount}{" "}
              {props.post.commentCollection?.totalCount === 1
                ? "comment"
                : "comments"}
            </a>
          </Link>
          <Link href={`/profile/${props.post.profile?.id}`}>
            <a className="text-gray-400 mr-3 inline-flex items-center text-sm pr-3 py-1 border-r-2 border-gray-200">
              <UserIcon className="w-4 h-4 mr-1" />
              {props.post.profile?.username}
            </a>
          </Link>
          <Link href={`/item/${props.post.id}`}>
            <a className="text-gray-400 inline-flex items-center text-sm">
              <CalendarIcon className="w-4 h-4 mr-1" />
              {createdAt}
            </a>
          </Link>
          {user?.id && props.post.profile?.id === user?.id ? (
            <DeleteButton post={props.post} />
          ) : null}
        </div>
      </div>
    </div>
  );
}

const DeleteButton_DeletePostMutation = gql(/* GraphQL */ `
  mutation DeleteButton_DeletePostMutation($postId: BigInt!) {
    deleteFromPostCollection(atMost: 1, filter: { id: { eq: $postId } }) {
      affectedCount
    }
  }
`);

const DeleteButton_PostFragment = gql(/* GraphQL */ `
  fragment DeleteButton_PostFragment on Post {
    id
  }
`);

const DeleteButton = (props: {
  post: DocumentType<typeof DeleteButton_PostFragment>;
}) => {
  const router = useRouter();
  const [show, setShow] = React.useState(false);
  const [deletePostMutation, deletePost] = useMutation(
    DeleteButton_DeletePostMutation
  );

  React.useEffect(() => {
    if (deletePostMutation.data) {
      router.push("/");
    }
  }, [deletePostMutation.data, deletePostMutation.error]);

  return (
    <>
      <button
        className="text-gray-400 inline-flex items-center text-sm pl-3 ml-3 border-l-2 border-gray-200"
        onClick={() => setShow(true)}
      >
        <TrashIcon className="w-4 h-4 mr-1" />
        Delete
      </button>
      <Modal
        title="Do you want to delete your post?"
        visible={show}
        onCancel={() => setShow(false)}
        onConfirm={() => {
          deletePost({
            postId: props.post.id,
          });
        }}
      >
        Deleting your post can not be reverted
      </Modal>
    </>
  );
};
