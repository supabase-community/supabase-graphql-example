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
    () =>
      timeAgo.format(
        props.comment.createdAt ? new Date(props.comment.createdAt) : new Date()
      ),
    [props.comment.createdAt]
  );
  return (
    <div className="py-8 flex flex-wrap md:flex-nowrap">
      <div className="flex-1 md:flex-grow">{props.comment.message}</div>
      {createdAt}
    </div>
  );
}
