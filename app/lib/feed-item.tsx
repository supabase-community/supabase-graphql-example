import Link from "next/link";
import React from "react";
import TimeAgo from "javascript-time-ago";
import en from "javascript-time-ago/locale/en.json";

import { DocumentType, gql } from "../gql";

TimeAgo.addDefaultLocale(en);

const timeAgo = new TimeAgo("en-US");

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

function CalendarIcon(props: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <rect x={3} y={4} width={18} height={18} rx={2} ry={2} />
      <path d="M16 2v4M8 2v4M3 10h18" />
    </svg>
  );
}

function CommentIcon(props: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      stroke="currentColor"
      stroke-width="2"
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
      {...props}
    >
      <path d="M21 11.5a8.38 8.38 0 01-.9 3.8 8.5 8.5 0 01-7.6 4.7 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8 8.5 8.5 0 014.7-7.6 8.38 8.38 0 013.8-.9h.5a8.48 8.48 0 018 8v.5z"></path>
    </svg>
  );
}

function PointIcon(props: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      className="w-4 h-4 mr-1"
      stroke="currentColor"
      stroke-width="2"
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
      {...props}
    >
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
      <circle cx="12" cy="12" r="3"></circle>
    </svg>
  );
}

export function FeedItem(props: {
  post: DocumentType<typeof FeedItem_PostFragment>;
}) {
  const createdAt = React.useMemo(
    () => timeAgo.format(new Date(props.post.createdAt)),
    [props.post.createdAt]
  );
  return (
    <div className="py-8 flex flex-wrap md:flex-nowrap">
      <div className="flex-1 md:flex-grow">
        <Link href={props.post.url}>
          <a>
            <h2 className="text-2xl font-medium text-gray-900 title-font mb-2">
              {props.post.title}
            </h2>
          </a>
        </Link>

        <div className="flex items-center flex-wrap pb-4 mb-4 border-gray-100 mt-auto w-full">
          <span className="text-gray-400 mr-3 inline-flex items-center  text-sm pr-3 py-1 border-r-2 border-gray-200">
            <PointIcon className="w-4 h-4 mr-1" />
            {props.post.score} points
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
