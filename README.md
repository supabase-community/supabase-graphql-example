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

### manage Schema with dbmate

1. `brew install dbmate`

## Schema (Public)

- Profile belongs to auth.users
- Post
- Comment belongs to Post and Profile
- Vote belongs to Post (can have a direction of UP/DOWN)

- direction enum is "UP" or "DOWN"

See: `./data/db/schema.sql`

> Note: The schema includes the entire Supabase schema with auth, storage, functions, etc.

## GraphQL Schema

See: `./graphql/schema/schema.graphql`

## Example Query

Use: `https://mvrfvzcivgabojxddwtk.supabase.co/rest/v1/rpc/graphql`

Note: Needs headers

```
Content-Type: application/json
apiKey: <supabase_anon_key>
```

```gql
# Your GraphQL query or mutation goes here
query {
  postCollection {
    edges {
      node {
        id
        commentCollection {
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
        upVoteCollection {
          upVoteCount: totalCount
        }
        downVoteCollection {
          downVoteCount: totalCount
        }
      }
    }
  }
}
```
