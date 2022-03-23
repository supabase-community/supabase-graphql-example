# Supabase pg_graphql Example App

A basic HackerNews-like clone where posts can be submitted with url links and then up and down voted.

## Showcase

### Backend pg_graphql / supabase

- CRUD (Query + Mutation Operations)
- Cursor Based Pagination
- Authorization / RLS

### Frontend

- Next.js
- TypeScript
- graphql-code-generator gql-tag-operations-preset
- urql

### Functionality

- Registration
- Get feed of posts
- Create Post
- Delete Post
- Create Comment
- Delete Comment
- Upvote/Downvote Post

## Installation

### Manage Schema with dbmate

1. `brew install dbmate`
2. Setup `.env` with `DATABASE_URL`

> TODO

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

- [ph_graphql](https://supabase.github.io/pg_graphql)
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
