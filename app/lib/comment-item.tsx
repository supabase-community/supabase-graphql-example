import React from "react";
import Link from "next/link";
import { useRouter } from "next/router";

import { useMutation } from "urql";

import { Auth } from "@supabase/ui";
import { TrashIcon } from "@heroicons/react/outline";

import { DocumentType, gql } from "../gql";
import { timeAgo } from "./time-ago";

const CommentItem_CommentFragment = gql(/* GraphQL */ `
  fragment CommentItem_CommentFragment on Comment {
    id
    message
    createdAt
    post {
      title
    }
    profile {
      id
      username
      avatarUrl
    }
  }
`);

const CommentItem_DeleteCommentFragment = gql(/* GraphQL */ `
  mutation CommentItem_DeleteComment($commentId: BigInt!) {
    deleteFromCommentCollection(atMost: 1, filter: { id: { eq: $commentId } }) {
      affectedCount
    }
  }
`);

export function CommentItem(props: {
  comment: DocumentType<typeof CommentItem_CommentFragment>;
}) {
  const router = useRouter();
  const { user } = Auth.useUser();
  const [deleteCommentMutation, deleteComment] = useMutation(
    CommentItem_DeleteCommentFragment
  );
  const createdAt = React.useMemo(
    () => timeAgo.format(new Date(props.comment.createdAt)),
    [props.comment.createdAt]
  );

  React.useEffect(() => {
    if (deleteCommentMutation.data) {
      router.reload();
    }
  }, [deleteCommentMutation.data]);
  return (
    <div className="flex space-x-3 py-4">
      <img
        className="h-6 w-6 rounded-full"
        src={props.comment.profile?.avatarUrl ?? undefined}
        alt=""
      />
      <div className="flex-1 space-y-1">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-medium">
            <Link href={`/profile/${props.comment.profile?.id}`}>
              <a className="text-gray-800">{props.comment.profile?.username}</a>
            </Link>
          </h3>
          <p className="text-sm text-gray-500">{createdAt}</p>
        </div>
        <p className="text-sm text-gray-500">
          {props.comment.message}
          {user?.id && user.id === props.comment.profile?.id ? (
            <button
              type="button"
              className="inline-flex items-center ml-2 p-1 border border-transparent rounded-full shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
              onClick={() => {
                deleteComment({
                  commentId: props.comment.id,
                });
              }}
            >
              <TrashIcon className="h-2 w-2" />
            </button>
          ) : null}
        </p>
      </div>
    </div>
  );
}
