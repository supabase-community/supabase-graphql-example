import { Auth } from "@supabase/ui";
import Link from "next/link";
import { useRouter } from "next/router";
import React from "react";
import { useMutation } from "urql";

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
    <div className="pb-4">
      <div className="text-sm">
        <Link href={`/profile/${props.comment.profile?.id}`}>
          <a className="font-bold">{props.comment.profile?.username} </a>
        </Link>
        <span>{createdAt}</span>
        {user?.id && user.id === props.comment.profile?.id ? (
          <button
            className="ml-2 text-xs text-gray-400 hover:text-gray-900"
            onClick={() => {
              deleteComment({
                commentId: props.comment.id,
              });
            }}
          >
            delete
          </button>
        ) : null}
      </div>
      <div className="flex-1 md:flex-grow">{props.comment.message}</div>
    </div>
  );
}
