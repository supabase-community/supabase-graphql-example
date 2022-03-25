# Row Level Security Matrix (RLS)

## Profile

- All users can `SELECT` all `PROFILE`s
- Only authenticated users can CREATE `PROFILE`
- Only `PROFILE`s where auth user is `id` can `UPDATE`
- No `PROFILE` `DELETE`. This might be an Admin role eventually.

## Posts

- All users can `SELECT` all `POST`s
- Only authenticated users can `CREATE POST`
- Only `POST`s where auth user is `profileId` can `UPDATE`
- Only `POST`s where auth user is `profileId` can `DELETE`

FYI: `DELETE POST` cascade to `COMMENT`s and `VOTE`s

## Comment

- All users can `SELECT` all `COMMENT`s
- Only authenticated users can `CREATE COMMENT`
- Only `COMMENT`s where auth user is `profileId` can `UPDATE`
- Only `COMMENT`s where auth user is `profileId` can `DELETE`

## Vote

- All users can `SELECT` all `VOTE`s
- Only authenticated users can `CREATE VOTE`
- Only `VOTE`s where auth user is `profileId` can `UPDATE`
- Only `VOTE`s where auth user is `profileId` can `DELETE`

Note: Does this mean I can see how people voted?
