# Supabase PG GraphQL Example App

A basic HackerNews-like clone where posts can be submitted with url links and then up and down voted.

## Showcase

### Backend pg_graphql / supabase

- CRUD (Query + Mutation Operations)
- Cursor Based Pagination
- Authorization / RLS

### Frontend

- [Next.js](https://nextjs.org) - React Framework
- [TypeScript](https://www.typescriptlang.org) - TypeScript is a strongly typed programming language that builds on JavaScript, giving you better tooling at any scale.
- [graphql-code-generator](https://www.graphql-code-generator.com) - Generate code from your GraphQL schema and operations with a simple CLI
- [gql-tag-operations-preset](https://www.graphql-code-generator.com/plugins/gql-tag-operations-preset) - This code gen preset generates typings for your inline gql function usages, without having to manually specify import statements for the documents
- [urql](https://formidable.com/open-source/urql/) - A highly customizable and versatile GraphQL client

### Backend

- [Supabase](https://supabase.com) - Create a backend in less than 2 minutes. Start your project with a Postgres Database, Authentication, instant APIs, Realtime subscriptions and Storage.
- [pg_graphql](https://supabase.com/blog/2021/12/03/pg-graphql) - A native [PostgreSQL extension](https://supabase.github.io/pg_graphql/) adding [GraphQL support](https://graphql.org). The extension keeps schema generation, query parsing, and resolvers all neatly contained on your database server requiring no external services.
- [Postgres Triggers](https://supabase.com/blog/2021/07/30/supabase-functions-updates) and [Postgres Functions](https://supabase.com/docs/guides/database/functions) - When votes are in, use triggers to invoke a Postgres function that calculates a post score to rank the feed
- [Postgres Enumerated Types](https://www.postgresql.org/docs/14/datatype-enum.html) - Enums help defined the direction of a vote: UP or DOWN.

### Functionality

- Registration
- Get a ranked feed of posts
- Create Post
- Delete Post
- Create Comment
- Delete Comment
- Upvote/Downvote Post

## Installation

```bask
yarn
yarn codegen:watch
yarn workspace app dev
```

### Manage Schema with dbmate

1. `brew install dbmate`
2. Setup `.env` with `DATABASE_URL`

```
cd data
dbmate dump
```

## Schema (Public)

- Profile belongs to auth.users
- Post
- Comment belongs to Post and Profile
- Vote belongs to Post (can have a direction of UP/DOWN)

- direction enum is "UP" or "DOWN"

### Constraints

- Post `url` is unique
- Vote is unique per Profile, Post (ie, you cannot vote more than once -- up or down)

See: `./data/db/schema.sql`

> Note: The schema includes the entire Supabase schema with auth, storage, functions, etc.

## Seed Data

A data file for all Supabase Blog posts from the RSS feed can be found in `./data/seed/blog_posts.csv` and can be loaded.

Note: Assumes a known `profileId` currently.

## GraphQL Schema

See: `./graphql/schema/schema.graphql`

## Example Query

Use: `https://mvrfvzcivgabojxddwtk.supabase.co/rest/v1/rpc/graphql`

Note: Needs headers

```
Content-Type: application/json
apiKey: <supabase_anon_key>
```

### Ranked Feed

```gql
query {
  rankedFeed: postCollection(
    orderBy: [
      { voteRank: AscNullsFirst }
      { score: DescNullsFirst }
      { createdAt: DescNullsFirst }
    ]
  ) {
    edges {
      post: node {
        id
        title
        url
        upVoteTotal
        downVoteTotal
        voteTotal
        voteDelta
        score
        voteRank
        comments: commentCollection {
          edges {
            node {
              id
              message
              profile {
                id
                username
                avatarUrl
              }
            }
          }
          commentCount: totalCount
        }
      }
    }
  }
}
```

## Read More

- [pg_graphql](https://supabase.github.io/pg_graphql)
- [pg_graphql Configuration](https://supabase.github.io/pg_graphql/configuration)

## Troubleshooting

1. `dbmate` can create `schema_migrations` tables in schemas. To make sure they are not included in your GraphQL Schema:

```sql
revoke select on table public.schema_migrations from anon, authenticated;
```

2. To [enable inflection](https://supabase.github.io/pg_graphql/configuration/#inflection)

```sql
comment on schema public is e'@graphql({"inflect_names": true})';
```
