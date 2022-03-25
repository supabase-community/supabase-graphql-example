import Link from "next/link";
import React from "react";

import { DocumentType, gql } from "../gql";
import { CalendarIcon, CommentIcon, PointIcon } from "./icons";
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

export function CommentItem(props: {
  comment: DocumentType<typeof CommentItem_CommentFragment>;
}) {
  const createdAt = React.useMemo(
    () => timeAgo.format(new Date(props.comment.createdAt)),
    [props.comment.createdAt]
  );
  return (
    <div className="py-8">
      <div>
        <span>{props.comment.profile?.username} </span>
        <span>{createdAt}</span>
      </div>
      <div className="flex-1 md:flex-grow">{props.comment.message}</div>
    </div>
  );
}
