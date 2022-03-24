import Link from "next/link";
import React from "react";

import { DocumentType, gql } from "../gql";
import { CalendarIcon, CommentIcon, PointIcon, UserIcon } from "./icons";
import { timeAgo } from "./time-ago";

const FeedItem_PostFragment = gql(/* GraphQL */ `
  fragment FeedItem_PostFragment on Post {
    id
    title
    url
    score
    createdAt
    commentCollection {
      totalCount
    }
    profile {
      id
      username
    }
  }
`);

export function FeedItem(props: {
  post: DocumentType<typeof FeedItem_PostFragment>;
}) {
  const createdAt = React.useMemo(
    () => timeAgo.format(new Date(props.post.createdAt)),
    [props.post.createdAt]
  );
  return (
    <div className="py-1 flex flex-wrap md:flex-nowrap mb-8 border-gray-100 border-b-2">
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
            {props.post.score}{" "}
            {props.post.commentCollection?.totalCount === 1
              ? "point"
              : "points"}
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
        </div>
      </div>
    </div>
  );
}
