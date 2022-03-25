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
    <div className="pb-4">
      <div className="text-sm">
        <Link href={`/profile/${props.comment.profile?.id}`}>
          <a className="font-bold">{props.comment.profile?.username} </a>
        </Link>
        <span>{createdAt}</span>
      </div>
      <div className="flex-1 md:flex-grow">{props.comment.message}</div>
    </div>
  );
}
