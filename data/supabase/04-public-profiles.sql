-- Create a table for Public Profiles
create table "Profile" (
  id uuid references auth.users not null,
  updatedAt timestamp with time zone,
  username text unique,
  avatarUrl text,
  website text,

  primary key (id),
  unique(username),
  constraint usernameLength check (char_length(username) >= 3)
);

alter table "Profile" enable row level security;

create policy "Public profiles are viewable by everyone."
  on "Profile" for select
  using ( true );

create policy "Users can insert their own profile."
  on "Profile" for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on "Profile" for update
  using ( auth.uid() = id );

-- Set up Realtime!
begin;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime;
commit;
alter publication supabase_realtime add table "Profile";

-- Set up Storage!
insert into storage.buckets (id, name)
values ('avatars', 'avatars');

create policy "Avatar images are publicly accessible."
  on storage.objects for select
  using ( bucket_id = 'avatars' );

create policy "Anyone can upload an avatar."
  on storage.objects for insert
  with check ( bucket_id = 'avatars' );

create policy "Anyone can update an avatar."
  on storage.objects for update
  with check ( bucket_id = 'avatars' );
