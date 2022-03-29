# Supabase GraphQL Example

A basic HackerNews-like clone where posts can be submitted with url links and then up and down voted.

<img width="1000" alt="graphql-hn" src="https://user-images.githubusercontent.com/10214025/160611420-29705df8-3e0a-471e-baef-04a3e2ac5618.png">

- Example: [supabase-graphql-example.vercel.app](https://supabase-graphql-example.vercel.app/)
- Features: [supabase-graphql-example.vercel.app/about](https://supabase-graphql-example.vercel.app/about)

## Showcase

### Backend

- CRUD (Query + Mutation Operations)
- Cursor Based Pagination
- Authorization / Postgres Row Level Security
- [Supabase](https://supabase.com) - Create a backend in less than 2 minutes. Start your project with a Postgres Database, Authentication, instant APIs, Realtime subscriptions and Storage.
- [pg_graphql](https://supabase.com/blog/2021/12/03/pg-graphql) - A native [PostgreSQL extension](https://supabase.github.io/pg_graphql/) adding [GraphQL support](https://graphql.org). The extension keeps schema generation, query parsing, and resolvers all neatly contained on your database server requiring no external services.
- [Postgres Triggers](https://supabase.com/blog/2021/07/30/supabase-functions-updates) and [Postgres Functions](https://supabase.com/docs/guides/database/functions) - When votes are in, use triggers to invoke a Postgres function that calculates a post score to rank the feed
- [Postgres Enumerated Types](https://www.postgresql.org/docs/14/datatype-enum.html) - Enums help defined the direction of a vote: UP or DOWN.

### Frontend

- [Next.js](https://nextjs.org) - React Framework
- [TypeScript](https://www.typescriptlang.org) - TypeScript is a strongly typed programming language that builds on JavaScript, giving you better tooling at any scale.
- [graphql-code-generator](https://www.graphql-code-generator.com) - Generate code from your GraphQL schema and operations with a simple CLI
- [gql-tag-operations-preset](https://www.graphql-code-generator.com/plugins/gql-tag-operations-preset) - This code gen preset generates typings for your inline gql function usages, without having to manually specify import statements for the documents
- [urql](https://formidable.com/open-source/urql/) - A highly customizable and versatile GraphQL client
- [Gravatar](https://en.gravatar.com) - Default avatar profile images from Gravatar

### Functionality

- Registration
- Get a ranked feed of posts
- Create Post
- Delete Post
- Create Comment
- Delete Comment
- Upvote/Downvote Post
- View Profile (Account)
- View Profile (Public)
- Pagination (Posts, Comments)

## QuickStart

### Setup env vars

- `cp app/.env.example app/.env`
- Fill in your url and anon key from the Supabase Dashboard: https://app.supabase.io/project/_/settings/api

### Install dependencies, GraphQL codegen, run app

```bash
yarn
yarn codegen
yarn workspace app dev
```

### Deploy to Vercel

Provide the following settings to deploy a production build to Vercel:

- BUILD COMMAND: `yarn codegen && yarn workspace app build`
- OUTPUT DIRECTORY: `./app/.next`
- INSTALL COMMAND: `yarn`
- DEVELOPMENT COMMAND: `yarn codegen && yarn workspace app dev --port $PORT`

## Development

1. Fetch latest GraphQL Schema

```bash
yarn codegen:fetch
```

2. Generate Types and Watch for Changes

```bash
yarn codegen:watch
```

3. Run server

```bash
yarn workspace app dev
```

### Synchronize the GraphQL schema

Note: You need to call `select graphql.rebuild_schema()` manually to synchronize the GraphQL schema with the SQL schema after altering the SQL schema.

#### Manage Schema with dbmate

1. `brew install dbmate`
2. Setup `.env` with `DATABASE_URL`
3. Dump Schema

```
cd data
dbmate dump
```

> Note: If `pgdump` fails due to row locks, a workaround is to grant the `postgres` role superuser permissions with `ALTER USER postgres WITH SUPERUSER`. After dumping the schema, you should reset the permissions using `ALTER USER postgres WITH NOSUPERUSER`. You can run these statements in the Superbase Dashboard SQL Editors.

## Schema (Public)

- Profile belongs to auth.users
- Post
- Comment belongs to Post and Profile
- Vote belongs to Post (can have a direction of UP/DOWN)

- direction enum is "UP" or "DOWN"

### Constraints

- Post `url` is unique
- Vote is unique per Profile, Post (ie, you cannot vote more than once -- up or down)

See: [`./data/db/schema.sql`](./data/db/schema.sql)

> Note: The schema includes the entire Supabase schema with auth, storage, functions, etc.

## Seed Data

A data file for all Supabase Blog posts from the RSS feed can be found in `./data/seed/blog_posts.csv` and can be loaded. Another file for `comments` is available as well.

Note: Assumes a known `profileId` currently.

## GraphQL Schema

See: [`./graphql/schema/schema.graphql`](./graphql/schema/schema.graphql)

## Example Query

See: [`./graphql/queries/`](./graphql/queries/)

Use: `https://mvrfvzcivgabojxddwtk.supabase.co/graphql/v1`

> Note: Needs headers

```

Content-Type: application/json
apiKey: <supabase_anon_key>

```

## GraphiQL

GraphiQL is an in-browser IDE for writing, validating, and testing GraphQL queries.

Visit `http://localhost:3000/api/graphiql` for the [Yoga GraphiQL Playground](https://www.graphql-yoga.com/docs/features/graphiql) where you can experiment with queries and mutations.

> Note: Needs headers

```

Content-Type: application/json
apiKey: <supabase_anon_key>

```

> Note: In order for the RLS policies authenticate you. you've have to pass an authorization header:

```
authorization: Bearker <access_token>

```

### Ranked Feed

```gql
query {
  rankedFeed: postCollection(orderBy: [{ voteRank: AscNullsFirst }]) {
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

# Row Level Security Matrix (RLS)

You can query all policies via: `select * from pg_policies`.

See: [Row Level Security Matrix (RLS)](./data/supabase/rls-policies.md)

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
