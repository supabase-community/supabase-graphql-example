import React from "react";
import type { NextPage } from "next";
import Head from "next/head";
import { useQuery } from "urql";
import { gql } from "../gql";
import { Container } from "../lib/container";
import { FeedItem } from "../lib/feed-item";
import { MainSection } from "../lib/main-section";
import { noopUUID } from "../lib/noop-uuid";

const About: NextPage = () => {
  return (
    <Container>
      <Head>
        <title>supanews | About</title>
        <meta name="description" content="What is hot?" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <MainSection>
        <section className="text-gray-600 body-font overflow-hidden w-full">
          <div className="container px-3 py-24 mx-auto">
            <div className="-my-8">
              <h1 className="text-2xl py-6">Supabase PG GraphQL Example App</h1>

              <p>
                A basic HackerNews-like clone where posts can be submitted with
                url links and then up and down voted.
              </p>

              <h2 className="text-xl pt-4">Showcase</h2>

              <h3 className="text-lg py-6"> Backend pg_graphql / supabase</h3>
              <ul>
                <li>CRUD (Query + Mutation Operations)</li>
                <li>Cursor Based Pagination</li>
                <li>Authorization / RLS</li>
              </ul>
              <h3 className="text-lg py-6">Frontend</h3>
              <ul>
                <li>[Next.js](https://nextjs.org) React Framework</li>
                <li>
                  [TypeScript](https://www.typescriptlang.org) TypeScript is a
                  strongly typed programming language that builds on JavaScript,
                  giving you better tooling at any scale.
                </li>
                <li>
                  [graphql-code-generator](https://www.graphql-code-generator.com){" "}
                  Generate code from your GraphQL schema and operations with a
                  simple CLI
                </li>
                <li>
                  [gql-tag-operations-preset](https://www.graphql-code-generator.com/plugins/gql-tag-operations-preset){" "}
                  This code gen preset generates typings for your inline gql
                  function usages, without having to manually specify import
                  statements for the documents
                </li>
                <li>
                  [urql](https://formidable.com/open-source/urql/) A highly
                  customizable and versatile GraphQL client
                </li>
                <li>
                  [Gravatar](https://en.gravatar.com) Default avatar profile
                  images from Gravatar
                </li>
              </ul>
              <h3 className="text-lg py-6">Backend</h3>
              <ul>
                <li>
                  [Supabase](https://supabase.com) Create a backend in less than
                  2 minutes. Start your project with a Postgres Database,
                  Authentication, instant APIs, Realtime subscriptions and
                  Storage.
                </li>
                <li>
                  [pg_graphql](https://supabase.com/blog/2021/12/03/pg-graphql){" "}
                  A native [PostgreSQL
                  extension](https://supabase.github.io/pg_graphql/) adding
                  [GraphQL support](https://graphql.org). The extension keeps
                  schema generation, query parsing, and resolvers all neatly
                  contained on your database server requiring no external
                  services.
                </li>
                <li>
                  [Postgres
                  Triggers](https://supabase.com/blog/2021/07/30/supabase-functions-updates)
                  and [Postgres
                  Functions](https://supabase.com/docs/guides/database/functions){" "}
                  When votes are in, use triggers to invoke a Postgres function
                  that calculates a post score to rank the feed
                </li>
                <li>
                  [Postgres Enumerated
                  Types](https://www.postgresql.org/docs/14/datatype-enum.html){" "}
                  Enums help defined the direction of a vote: UP or DOWN.
                </li>
              </ul>
              <h3 className="text-lg py-6">Functionality</h3>
              <ul>
                <li>Registration</li>
                <li>Get a ranked feed of posts</li>
                <li>Create Post</li>
                <li>Delete Post</li>
                <li>Create Comment</li>
                <li>Delete Comment</li>
                <li>Upvote/Downvote Post</li>
                <li>View Profile (Account)</li>
                <li>View Profile (Public)</li>
                <li>Pagination (Posts, Comments)</li>
              </ul>
            </div>
          </div>
        </section>
      </MainSection>
    </Container>
  );
};

export default About;
