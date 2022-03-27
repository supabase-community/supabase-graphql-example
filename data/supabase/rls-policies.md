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

## Export of Policies

See: [row_level_security_polices.csv](../db/row_level_security_polices.csv)

| schemaname | tablename | policyname                                | permissive | roles    | cmd    | qual                          | with_check                            |
| ---------- | --------- | ----------------------------------------- | ---------- | -------- | ------ | ----------------------------- | ------------------------------------- |
| public     | Profile   | Public profiles are viewable by everyone. | PERMISSIVE | {public} | SELECT | true                          |                                       |
| public     | Profile   | Users can insert their own profile.       | PERMISSIVE | {public} | INSERT |                               | (auth.uid() = id)                     |
| public     | Profile   | Users can update own profile.             | PERMISSIVE | {public} | UPDATE | (auth.uid() = id)             |                                       |
| storage    | objects   | Avatar images are publicly accessible.    | PERMISSIVE | {public} | SELECT | (bucket_id = 'avatars'::text) |                                       |
| storage    | objects   | Anyone can upload an avatar.              | PERMISSIVE | {public} | INSERT |                               | (bucket_id = 'avatars'::text)         |
| storage    | objects   | Anyone can update an avatar.              | PERMISSIVE | {public} | UPDATE |                               | (bucket_id = 'avatars'::text)         |
| public     | Post      | All users can view posts                  | PERMISSIVE | {public} | SELECT | true                          |                                       |
| public     | Post      | Only authenticated users can create posts | PERMISSIVE | {public} | INSERT |                               | (auth.role() = 'authenticated'::text) |
| public     | Post      | Users can delete their own posts          | PERMISSIVE | {public} | DELETE | (auth.uid() = "profileId")    |                                       |
| public     | Post      | Users can edit their own posts            | PERMISSIVE | {public} | UPDATE | (auth.uid() = "profileId")    | (auth.uid() = "profileId")            |
| public     | Comment   | Everyone can view comments                | PERMISSIVE | {public} | SELECT | true                          |                                       |
| public     | Comment   | Only authenticated users can comment      | PERMISSIVE | {public} | INSERT |                               | (auth.role() = 'authenticated'::text) |
| public     | Comment   | User can edit their own comments          | PERMISSIVE | {public} | UPDATE | (auth.uid() = "profileId")    | (auth.uid() = "profileId")            |
| public     | Comment   | Users can delete their own comments       | PERMISSIVE | {public} | DELETE | (auth.uid() = "profileId")    |                                       |
| public     | Vote      | Everyone can view votes                   | PERMISSIVE | {public} | SELECT | true                          |                                       |
| public     | Vote      | Only authenticated users can vote         | PERMISSIVE | {public} | INSERT |                               | (auth.role() = 'authenticated'::text) |
| public     | Vote      | Users can change their vote               | PERMISSIVE | {public} | UPDATE | (auth.uid() = "profileId")    | (auth.uid() = "profileId")            |
| public     | Vote      | Users can delete their own votes          | PERMISSIVE | {public} | DELETE | (auth.uid() = "profileId")    |                                       |
