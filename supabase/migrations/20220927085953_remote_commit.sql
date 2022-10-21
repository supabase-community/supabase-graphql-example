--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.5 (Debian 14.5-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "public";


--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: direction; Type: TYPE; Schema: public; Owner: supabase_admin
--

CREATE TYPE "public"."direction" AS ENUM (
    'UP',
    'DOWN'
);


ALTER TYPE "public"."direction" OWNER TO "supabase_admin";

--
-- Name: myrowtype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."myrowtype" AS (
	"action" "text",
	"actor_id" "text",
	"actor_name" "text",
	"actor_user_name" "text",
	"log_type" "text",
	"timestamp" "text"
);


ALTER TYPE "public"."myrowtype" OWNER TO "postgres";

--
-- Name: graphql("text", "text", "jsonb", "jsonb"); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION "public"."graphql"("operationName" "text" DEFAULT NULL::"text", "query" "text" DEFAULT NULL::"text", "variables" "jsonb" DEFAULT NULL::"jsonb", "extensions" "jsonb" DEFAULT NULL::"jsonb") RETURNS "jsonb"
    LANGUAGE "sql"
    AS $$
    select graphql.resolve(query, coalesce(variables, '{}'));
$$;


ALTER FUNCTION "public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") OWNER TO "supabase_admin";

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public."Profile" (id, "avatarUrl", username)
  values (new.id, 'https://www.gravatar.com/avatar/' || md5(new.email) || '?d=mp', split_part(new.email, '@', 1) || '-' || floor(random() * 10000));
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "supabase_admin";

--
-- Name: update_vote_counts(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION "public"."update_vote_counts"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN

WITH r AS (
SELECT
	coalesce("Vote"."postId", "Post".id) AS "postId",
	count(1) "voteTotal",
	count(1) FILTER (WHERE direction = 'UP') "upVoteTotal",
	count(1) FILTER (WHERE direction = 'DOWN') "downVoteTotal",
	coalesce(sum(
			CASE WHEN direction = 'UP' THEN
				1
			WHEN direction = 'DOWN' THEN
				-1
			ELSE
				0
			END), 0) "voteDelta",
	round(coalesce((sum(
		CASE WHEN direction = 'UP' THEN
			1
		WHEN direction = 'DOWN' THEN
			-1
		ELSE
			0
		END ) - 1) / (DATE_PART('hour', now() - max("Vote"."createdAt")) + 2) ^ 1.8 * 100000, -2147483648)::numeric, 0) AS "score",
	rank() OVER (ORDER BY round(coalesce((sum( CASE WHEN direction = 'UP' THEN
			1
		WHEN direction = 'DOWN' THEN
			-1
		ELSE
			0
		END) - 1) / (DATE_PART('hour', now() - max("Vote"."createdAt")) + 2) ^ 1.8 * 100000, -2147483648)::numeric, 0)
		DESC,
		"Post"."createdAt" DESC,
		"Post".title ASC) "voteRank"
FROM
	"Vote"
	RIGHT JOIN "Post" ON "Vote"."postId" = "Post".id
GROUP BY
	"Post".id,
	"Vote"."postId"
)

UPDATE
	public. "Post"
SET
	"upVoteTotal" = r. "upVoteTotal",
	"downVoteTotal" = r. "downVoteTotal",
	"voteTotal" = r. "voteTotal",
  "voteDelta" = r. "voteDelta",
	"voteRank" = r. "voteRank",
  "score" = r. "score"
FROM
	r
WHERE
	r."postId" = public. "Post".id;

RETURN new;
END;
$$;


ALTER FUNCTION "public"."update_vote_counts"() OWNER TO "supabase_admin";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: Comment; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE "public"."Comment" (
    "id" bigint NOT NULL,
    "createdAt" timestamp with time zone DEFAULT "now"(),
    "updatedAt" timestamp with time zone,
    "message" "text" NOT NULL,
    "profileId" "uuid" NOT NULL,
    "postId" bigint NOT NULL
);


ALTER TABLE "public"."Comment" OWNER TO "supabase_admin";

--
-- Name: Comment_id_seq; Type: SEQUENCE; Schema: public; Owner: supabase_admin
--

ALTER TABLE "public"."Comment" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Comment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Vote; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE "public"."Vote" (
    "id" bigint NOT NULL,
    "createdAt" timestamp with time zone DEFAULT "now"(),
    "updatedAt" timestamp with time zone,
    "profileId" "uuid" NOT NULL,
    "postId" bigint NOT NULL,
    "direction" "public"."direction" NOT NULL
);


ALTER TABLE "public"."Vote" OWNER TO "supabase_admin";

--
-- Name: DownVote_id_seq; Type: SEQUENCE; Schema: public; Owner: supabase_admin
--

ALTER TABLE "public"."Vote" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."DownVote_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Post; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE "public"."Post" (
    "id" bigint NOT NULL,
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "title" "text" NOT NULL,
    "url" "text" NOT NULL,
    "profileId" "uuid" NOT NULL,
    "upVoteTotal" integer DEFAULT 0 NOT NULL,
    "downVoteTotal" integer DEFAULT 0 NOT NULL,
    "voteTotal" integer DEFAULT 0 NOT NULL,
    "voteRank" integer DEFAULT 1 NOT NULL,
    "score" integer DEFAULT 0,
    "voteDelta" integer DEFAULT 0 NOT NULL,
    CONSTRAINT "post_title_length" CHECK (("char_length"("title") > 0)),
    CONSTRAINT "post_url_length" CHECK (("char_length"("url") > 0))
);


ALTER TABLE "public"."Post" OWNER TO "supabase_admin";

--
-- Name: Post_id_seq; Type: SEQUENCE; Schema: public; Owner: supabase_admin
--

ALTER TABLE "public"."Post" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Post_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Profile; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE "public"."Profile" (
    "id" "uuid" NOT NULL,
    "updatedat" timestamp with time zone,
    "username" "text",
    "avatarUrl" "text",
    "website" "text",
    "bio" "text",
    CONSTRAINT "usernamelength" CHECK (("char_length"("username") >= 3))
);


ALTER TABLE "public"."Profile" OWNER TO "supabase_admin";

--
-- Name: Comment Comment_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Comment"
    ADD CONSTRAINT "Comment_pkey" PRIMARY KEY ("id");


--
-- Name: Vote DownVote_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Vote"
    ADD CONSTRAINT "DownVote_pkey" PRIMARY KEY ("id");


--
-- Name: Post Post_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Post"
    ADD CONSTRAINT "Post_pkey" PRIMARY KEY ("id");


--
-- Name: Post Post_url_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Post"
    ADD CONSTRAINT "Post_url_key" UNIQUE ("url");


--
-- Name: Profile Profile_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Profile"
    ADD CONSTRAINT "Profile_pkey" PRIMARY KEY ("id");


--
-- Name: Profile Profile_username_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Profile"
    ADD CONSTRAINT "Profile_username_key" UNIQUE ("username");


--
-- Name: idx_one_vote_per_post; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE UNIQUE INDEX "idx_one_vote_per_post" ON "public"."Vote" USING "btree" ("profileId", "postId");


--
-- Name: idx_unique_post_url; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE UNIQUE INDEX "idx_unique_post_url" ON "public"."Post" USING "btree" ("url");


--
-- Name: Vote on_vote_created; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER "on_vote_created" AFTER INSERT ON "public"."Vote" FOR EACH ROW EXECUTE FUNCTION "public"."update_vote_counts"();


--
-- Name: Vote on_vote_deleted; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER "on_vote_deleted" AFTER DELETE ON "public"."Vote" FOR EACH ROW EXECUTE FUNCTION "public"."update_vote_counts"();


--
-- Name: Vote test; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

-- CREATE TRIGGER "test" AFTER INSERT ON "public"."Vote" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('http://example.com', 'GET', '{"Content-type":"application/json"}', '{"api_key":"foo"}', '1000');


--
-- Name: Comment Comment_postId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Comment"
    ADD CONSTRAINT "Comment_postId_fkey" FOREIGN KEY ("postId") REFERENCES "public"."Post"("id") ON DELETE CASCADE;


--
-- Name: Comment Comment_profileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Comment"
    ADD CONSTRAINT "Comment_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "public"."Profile"("id");


--
-- Name: Vote DownVote_profileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Vote"
    ADD CONSTRAINT "DownVote_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "public"."Profile"("id");


--
-- Name: Post Post_profileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Post"
    ADD CONSTRAINT "Post_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "public"."Profile"("id");


--
-- Name: Profile Profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Profile"
    ADD CONSTRAINT "Profile_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");


--
-- Name: Vote Vote_postId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY "public"."Vote"
    ADD CONSTRAINT "Vote_postId_fkey" FOREIGN KEY ("postId") REFERENCES "public"."Post"("id") ON DELETE CASCADE;


--
-- Name: Post All users can view posts; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "All users can view posts" ON "public"."Post" FOR SELECT USING (true);


--
-- Name: Comment; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE "public"."Comment" ENABLE ROW LEVEL SECURITY;

--
-- Name: Comment Everyone can view comments; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Everyone can view comments" ON "public"."Comment" FOR SELECT USING (true);


--
-- Name: Vote Everyone can view votes; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Everyone can view votes" ON "public"."Vote" FOR SELECT USING (true);


--
-- Name: Comment Only authenticated users can comment; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Only authenticated users can comment" ON "public"."Comment" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));


--
-- Name: Post Only authenticated users can create posts; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Only authenticated users can create posts" ON "public"."Post" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));


--
-- Name: Vote Only authenticated users can vote; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Only authenticated users can vote" ON "public"."Vote" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));


--
-- Name: Post; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE "public"."Post" ENABLE ROW LEVEL SECURITY;

--
-- Name: Profile; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE "public"."Profile" ENABLE ROW LEVEL SECURITY;

--
-- Name: Profile Public profiles are viewable by everyone.; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Public profiles are viewable by everyone." ON "public"."Profile" FOR SELECT USING (true);


--
-- Name: Comment User can edit their own comments; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "User can edit their own comments" ON "public"."Comment" FOR UPDATE USING (("auth"."uid"() = "profileId")) WITH CHECK (("auth"."uid"() = "profileId"));


--
-- Name: Vote Users can change their vote; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can change their vote" ON "public"."Vote" FOR UPDATE USING (("auth"."uid"() = "profileId")) WITH CHECK (("auth"."uid"() = "profileId"));


--
-- Name: Comment Users can delete their own comments; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can delete their own comments" ON "public"."Comment" FOR DELETE USING (("auth"."uid"() = "profileId"));


--
-- Name: Post Users can delete their own posts; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can delete their own posts" ON "public"."Post" FOR DELETE USING (("auth"."uid"() = "profileId"));


--
-- Name: Vote Users can delete their own votes; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can delete their own votes" ON "public"."Vote" FOR DELETE USING (("auth"."uid"() = "profileId"));


--
-- Name: Post Users can edit their own posts; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can edit their own posts" ON "public"."Post" FOR UPDATE USING (("auth"."uid"() = "profileId")) WITH CHECK (("auth"."uid"() = "profileId"));


--
-- Name: Profile Users can insert their own profile.; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can insert their own profile." ON "public"."Profile" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));


--
-- Name: Profile Users can update own profile.; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can update own profile." ON "public"."Profile" FOR UPDATE USING (("auth"."uid"() = "id"));


--
-- Name: Vote; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE "public"."Vote" ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA "public"; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


--
-- Name: SCHEMA "net"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA "net" TO "supabase_functions_admin";
GRANT USAGE ON SCHEMA "net" TO "anon";
GRANT USAGE ON SCHEMA "net" TO "authenticated";
GRANT USAGE ON SCHEMA "net" TO "service_role";


--
-- Name: FUNCTION "algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "armor"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "dashboard_user";


--
-- Name: FUNCTION "armor"("bytea", "text"[], "text"[]); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "dashboard_user";


--
-- Name: FUNCTION "crypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "dearmor"("text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "dashboard_user";


--
-- Name: FUNCTION "decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "decrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "digest"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "digest"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "encrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "encrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "gen_random_bytes"(integer); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "dashboard_user";


--
-- Name: FUNCTION "gen_random_uuid"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "dashboard_user";


--
-- Name: FUNCTION "gen_salt"("text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "dashboard_user";


--
-- Name: FUNCTION "gen_salt"("text", integer); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "dashboard_user";


--
-- Name: FUNCTION "hmac"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "hmac"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric) TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "dashboard_user";


--
-- Name: FUNCTION "pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_key_id"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "sign"("payload" "json", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "try_cast_double"("inp" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "dashboard_user";


--
-- Name: FUNCTION "url_decode"("data" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "dashboard_user";


--
-- Name: FUNCTION "url_encode"("data" "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v1"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v1mc"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v3"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v4"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v5"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_nil"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_dns"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_oid"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_url"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_x500"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "dashboard_user";


--
-- Name: FUNCTION "verify"("token" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "_first_agg"("anyelement", "anyelement"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."_first_agg"("anyelement", "anyelement") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."_first_agg"("anyelement", "anyelement") TO "anon";
GRANT ALL ON FUNCTION "graphql"."_first_agg"("anyelement", "anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."_first_agg"("anyelement", "anyelement") TO "service_role";


--
-- Name: FUNCTION "alias_or_name_literal"("field" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."alias_or_name_literal"("field" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."alias_or_name_literal"("field" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."alias_or_name_literal"("field" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."alias_or_name_literal"("field" "jsonb") TO "service_role";


--
-- Name: FUNCTION "arg_clause"("name" "text", "arguments" "jsonb", "variable_definitions" "jsonb", "entity" "regclass", "default_value" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."arg_clause"("name" "text", "arguments" "jsonb", "variable_definitions" "jsonb", "entity" "regclass", "default_value" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."arg_clause"("name" "text", "arguments" "jsonb", "variable_definitions" "jsonb", "entity" "regclass", "default_value" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."arg_clause"("name" "text", "arguments" "jsonb", "variable_definitions" "jsonb", "entity" "regclass", "default_value" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."arg_clause"("name" "text", "arguments" "jsonb", "variable_definitions" "jsonb", "entity" "regclass", "default_value" "text") TO "service_role";


--
-- Name: FUNCTION "arg_coerce_list"("arg" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."arg_coerce_list"("arg" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."arg_coerce_list"("arg" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."arg_coerce_list"("arg" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."arg_coerce_list"("arg" "jsonb") TO "service_role";


--
-- Name: FUNCTION "arg_index"("arg_name" "text", "variable_definitions" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."arg_index"("arg_name" "text", "variable_definitions" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."arg_index"("arg_name" "text", "variable_definitions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."arg_index"("arg_name" "text", "variable_definitions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."arg_index"("arg_name" "text", "variable_definitions" "jsonb") TO "service_role";


--
-- Name: FUNCTION "arg_to_jsonb"("arg" "jsonb", "variables" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."arg_to_jsonb"("arg" "jsonb", "variables" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."arg_to_jsonb"("arg" "jsonb", "variables" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."arg_to_jsonb"("arg" "jsonb", "variables" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."arg_to_jsonb"("arg" "jsonb", "variables" "jsonb") TO "service_role";


--
-- Name: FUNCTION "argument_value_by_name"("name" "text", "ast" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."argument_value_by_name"("name" "text", "ast" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."argument_value_by_name"("name" "text", "ast" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."argument_value_by_name"("name" "text", "ast" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."argument_value_by_name"("name" "text", "ast" "jsonb") TO "service_role";


--
-- Name: FUNCTION "ast_pass_fragments"("ast" "jsonb", "fragment_defs" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."ast_pass_fragments"("ast" "jsonb", "fragment_defs" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."ast_pass_fragments"("ast" "jsonb", "fragment_defs" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."ast_pass_fragments"("ast" "jsonb", "fragment_defs" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."ast_pass_fragments"("ast" "jsonb", "fragment_defs" "jsonb") TO "service_role";


--
-- Name: FUNCTION "ast_pass_strip_loc"("body" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."ast_pass_strip_loc"("body" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."ast_pass_strip_loc"("body" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."ast_pass_strip_loc"("body" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."ast_pass_strip_loc"("body" "jsonb") TO "service_role";


--
-- Name: FUNCTION "build_args_on_field_query"("ast" "jsonb", "field_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_args_on_field_query"("ast" "jsonb", "field_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_args_on_field_query"("ast" "jsonb", "field_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_args_on_field_query"("ast" "jsonb", "field_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_args_on_field_query"("ast" "jsonb", "field_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb") TO "service_role";


--
-- Name: FUNCTION "build_connection_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_connection_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_connection_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_connection_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_connection_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text") TO "service_role";


--
-- Name: FUNCTION "build_delete"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_delete"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_delete"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_delete"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_delete"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "service_role";


--
-- Name: FUNCTION "build_enum_values_query"("ast" "jsonb", "type_block_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_enum_values_query"("ast" "jsonb", "type_block_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_enum_values_query"("ast" "jsonb", "type_block_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_enum_values_query"("ast" "jsonb", "type_block_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_enum_values_query"("ast" "jsonb", "type_block_name" "text") TO "service_role";


--
-- Name: FUNCTION "build_field_on_type_query"("ast" "jsonb", "type_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb", "is_input_fields" boolean); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_field_on_type_query"("ast" "jsonb", "type_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb", "is_input_fields" boolean) TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_field_on_type_query"("ast" "jsonb", "type_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb", "is_input_fields" boolean) TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_field_on_type_query"("ast" "jsonb", "type_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb", "is_input_fields" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_field_on_type_query"("ast" "jsonb", "type_block_name" "text", "variable_definitions" "jsonb", "variables" "jsonb", "is_input_fields" boolean) TO "service_role";


--
-- Name: FUNCTION "build_heartbeat_query"("ast" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_heartbeat_query"("ast" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_heartbeat_query"("ast" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_heartbeat_query"("ast" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_heartbeat_query"("ast" "jsonb") TO "service_role";


--
-- Name: FUNCTION "build_insert"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_insert"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_insert"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_insert"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_insert"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "service_role";


--
-- Name: FUNCTION "build_node_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_node_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_node_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_node_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_node_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb", "parent_type" "text", "parent_block_name" "text") TO "service_role";


--
-- Name: FUNCTION "build_schema_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_schema_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_schema_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_schema_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_schema_query"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "service_role";


--
-- Name: FUNCTION "build_type_query_core_selects"("ast" "jsonb", "block_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_type_query_core_selects"("ast" "jsonb", "block_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_type_query_core_selects"("ast" "jsonb", "block_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_type_query_core_selects"("ast" "jsonb", "block_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_type_query_core_selects"("ast" "jsonb", "block_name" "text") TO "service_role";


--
-- Name: FUNCTION "build_type_query_in_field_context"("ast" "jsonb", "field_block_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_type_query_in_field_context"("ast" "jsonb", "field_block_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_type_query_in_field_context"("ast" "jsonb", "field_block_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_type_query_in_field_context"("ast" "jsonb", "field_block_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_type_query_in_field_context"("ast" "jsonb", "field_block_name" "text") TO "service_role";


--
-- Name: FUNCTION "build_type_query_wrapper_selects"("ast" "jsonb", "kind" "text", "of_type_selects" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_type_query_wrapper_selects"("ast" "jsonb", "kind" "text", "of_type_selects" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_type_query_wrapper_selects"("ast" "jsonb", "kind" "text", "of_type_selects" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_type_query_wrapper_selects"("ast" "jsonb", "kind" "text", "of_type_selects" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_type_query_wrapper_selects"("ast" "jsonb", "kind" "text", "of_type_selects" "text") TO "service_role";


--
-- Name: FUNCTION "build_update"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."build_update"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."build_update"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."build_update"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."build_update"("ast" "jsonb", "variable_definitions" "jsonb", "variables" "jsonb") TO "service_role";


--
-- Name: FUNCTION "cache_key"("role" "regrole", "schemas" "text"[], "schema_version" integer, "ast" "jsonb", "variables" "jsonb", "variable_definitions" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."cache_key"("role" "regrole", "schemas" "text"[], "schema_version" integer, "ast" "jsonb", "variables" "jsonb", "variable_definitions" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."cache_key"("role" "regrole", "schemas" "text"[], "schema_version" integer, "ast" "jsonb", "variables" "jsonb", "variable_definitions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."cache_key"("role" "regrole", "schemas" "text"[], "schema_version" integer, "ast" "jsonb", "variables" "jsonb", "variable_definitions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."cache_key"("role" "regrole", "schemas" "text"[], "schema_version" integer, "ast" "jsonb", "variables" "jsonb", "variable_definitions" "jsonb") TO "service_role";


--
-- Name: FUNCTION "cache_key_variable_component"("variables" "jsonb", "variable_definitions" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."cache_key_variable_component"("variables" "jsonb", "variable_definitions" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."cache_key_variable_component"("variables" "jsonb", "variable_definitions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."cache_key_variable_component"("variables" "jsonb", "variable_definitions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."cache_key_variable_component"("variables" "jsonb", "variable_definitions" "jsonb") TO "service_role";


--
-- Name: FUNCTION "column_set_is_unique"("regclass", "columns" "text"[]); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."column_set_is_unique"("regclass", "columns" "text"[]) TO "postgres";
GRANT ALL ON FUNCTION "graphql"."column_set_is_unique"("regclass", "columns" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "graphql"."column_set_is_unique"("regclass", "columns" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."column_set_is_unique"("regclass", "columns" "text"[]) TO "service_role";


--
-- Name: FUNCTION "comment"("regclass"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment"("regclass") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment"("regclass") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment"("regclass") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment"("regclass") TO "service_role";


--
-- Name: FUNCTION "comment"("regnamespace"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment"("regnamespace") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment"("regnamespace") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment"("regnamespace") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment"("regnamespace") TO "service_role";


--
-- Name: FUNCTION "comment"("regproc"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment"("regproc") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment"("regproc") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment"("regproc") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment"("regproc") TO "service_role";


--
-- Name: FUNCTION "comment"("regtype"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment"("regtype") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment"("regtype") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment"("regtype") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment"("regtype") TO "service_role";


--
-- Name: FUNCTION "comment"("regclass", "column_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment"("regclass", "column_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment"("regclass", "column_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment"("regclass", "column_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment"("regclass", "column_name" "text") TO "service_role";


--
-- Name: FUNCTION "comment_directive"("comment_" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "service_role";


--
-- Name: FUNCTION "comment_directive_inflect_names"("regnamespace"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment_directive_inflect_names"("regnamespace") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment_directive_inflect_names"("regnamespace") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment_directive_inflect_names"("regnamespace") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment_directive_inflect_names"("regnamespace") TO "service_role";


--
-- Name: FUNCTION "comment_directive_name"("regclass"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regclass") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regclass") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regclass") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regclass") TO "service_role";


--
-- Name: FUNCTION "comment_directive_name"("regproc"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regproc") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regproc") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regproc") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regproc") TO "service_role";


--
-- Name: FUNCTION "comment_directive_name"("regtype"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regtype") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regtype") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regtype") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regtype") TO "service_role";


--
-- Name: FUNCTION "comment_directive_name"("regclass", "column_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regclass", "column_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regclass", "column_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regclass", "column_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment_directive_name"("regclass", "column_name" "text") TO "service_role";


--
-- Name: FUNCTION "comment_directive_totalcount_enabled"("regclass"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."comment_directive_totalcount_enabled"("regclass") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."comment_directive_totalcount_enabled"("regclass") TO "anon";
GRANT ALL ON FUNCTION "graphql"."comment_directive_totalcount_enabled"("regclass") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."comment_directive_totalcount_enabled"("regclass") TO "service_role";


--
-- Name: FUNCTION "cursor_where_clause"("block_name" "text", "column_orders" "graphql"."column_order_w_type"[], "cursor_" "text", "cursor_var_ix" integer, "depth_" integer); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."cursor_where_clause"("block_name" "text", "column_orders" "graphql"."column_order_w_type"[], "cursor_" "text", "cursor_var_ix" integer, "depth_" integer) TO "postgres";
GRANT ALL ON FUNCTION "graphql"."cursor_where_clause"("block_name" "text", "column_orders" "graphql"."column_order_w_type"[], "cursor_" "text", "cursor_var_ix" integer, "depth_" integer) TO "anon";
GRANT ALL ON FUNCTION "graphql"."cursor_where_clause"("block_name" "text", "column_orders" "graphql"."column_order_w_type"[], "cursor_" "text", "cursor_var_ix" integer, "depth_" integer) TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."cursor_where_clause"("block_name" "text", "column_orders" "graphql"."column_order_w_type"[], "cursor_" "text", "cursor_var_ix" integer, "depth_" integer) TO "service_role";


--
-- Name: FUNCTION "decode"("text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."decode"("text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."decode"("text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."decode"("text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."decode"("text") TO "service_role";


--
-- Name: FUNCTION "encode"("jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."encode"("jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."encode"("jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."encode"("jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."encode"("jsonb") TO "service_role";


--
-- Name: FUNCTION "exception"("message" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "service_role";


--
-- Name: FUNCTION "exception_required_argument"("arg_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."exception_required_argument"("arg_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."exception_required_argument"("arg_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."exception_required_argument"("arg_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."exception_required_argument"("arg_name" "text") TO "service_role";


--
-- Name: FUNCTION "exception_unknown_field"("field_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."exception_unknown_field"("field_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."exception_unknown_field"("field_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."exception_unknown_field"("field_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."exception_unknown_field"("field_name" "text") TO "service_role";


--
-- Name: FUNCTION "exception_unknown_field"("field_name" "text", "type_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."exception_unknown_field"("field_name" "text", "type_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."exception_unknown_field"("field_name" "text", "type_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."exception_unknown_field"("field_name" "text", "type_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."exception_unknown_field"("field_name" "text", "type_name" "text") TO "service_role";


--
-- Name: TABLE "_field"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON TABLE "graphql"."_field" TO "postgres";
GRANT ALL ON TABLE "graphql"."_field" TO "anon";
GRANT ALL ON TABLE "graphql"."_field" TO "authenticated";
GRANT ALL ON TABLE "graphql"."_field" TO "service_role";


--
-- Name: FUNCTION "field_name"("rec" "graphql"."_field"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."field_name"("rec" "graphql"."_field") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."field_name"("rec" "graphql"."_field") TO "anon";
GRANT ALL ON FUNCTION "graphql"."field_name"("rec" "graphql"."_field") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."field_name"("rec" "graphql"."_field") TO "service_role";


--
-- Name: FUNCTION "field_name_for_column"("entity" "regclass", "column_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."field_name_for_column"("entity" "regclass", "column_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."field_name_for_column"("entity" "regclass", "column_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."field_name_for_column"("entity" "regclass", "column_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."field_name_for_column"("entity" "regclass", "column_name" "text") TO "service_role";


--
-- Name: FUNCTION "field_name_for_function"("func" "regproc"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."field_name_for_function"("func" "regproc") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."field_name_for_function"("func" "regproc") TO "anon";
GRANT ALL ON FUNCTION "graphql"."field_name_for_function"("func" "regproc") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."field_name_for_function"("func" "regproc") TO "service_role";


--
-- Name: FUNCTION "field_name_for_query_collection"("entity" "regclass"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."field_name_for_query_collection"("entity" "regclass") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."field_name_for_query_collection"("entity" "regclass") TO "anon";
GRANT ALL ON FUNCTION "graphql"."field_name_for_query_collection"("entity" "regclass") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."field_name_for_query_collection"("entity" "regclass") TO "service_role";


--
-- Name: FUNCTION "field_name_for_to_many"("foreign_entity" "regclass", "foreign_name_override" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."field_name_for_to_many"("foreign_entity" "regclass", "foreign_name_override" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."field_name_for_to_many"("foreign_entity" "regclass", "foreign_name_override" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."field_name_for_to_many"("foreign_entity" "regclass", "foreign_name_override" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."field_name_for_to_many"("foreign_entity" "regclass", "foreign_name_override" "text") TO "service_role";


--
-- Name: FUNCTION "field_name_for_to_one"("foreign_entity" "regclass", "foreign_name_override" "text", "foreign_columns" "text"[]); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."field_name_for_to_one"("foreign_entity" "regclass", "foreign_name_override" "text", "foreign_columns" "text"[]) TO "postgres";
GRANT ALL ON FUNCTION "graphql"."field_name_for_to_one"("foreign_entity" "regclass", "foreign_name_override" "text", "foreign_columns" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "graphql"."field_name_for_to_one"("foreign_entity" "regclass", "foreign_name_override" "text", "foreign_columns" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."field_name_for_to_one"("foreign_entity" "regclass", "foreign_name_override" "text", "foreign_columns" "text"[]) TO "service_role";


--
-- Name: FUNCTION "get_arg_by_name"("name" "text", "arguments" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."get_arg_by_name"("name" "text", "arguments" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."get_arg_by_name"("name" "text", "arguments" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."get_arg_by_name"("name" "text", "arguments" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."get_arg_by_name"("name" "text", "arguments" "jsonb") TO "service_role";


--
-- Name: FUNCTION "get_built_schema_version"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."get_built_schema_version"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."get_built_schema_version"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."get_built_schema_version"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."get_built_schema_version"() TO "service_role";


--
-- Name: FUNCTION "inflect_type_default"("text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."inflect_type_default"("text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."inflect_type_default"("text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."inflect_type_default"("text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."inflect_type_default"("text") TO "service_role";


--
-- Name: FUNCTION "is_array"("regtype"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."is_array"("regtype") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."is_array"("regtype") TO "anon";
GRANT ALL ON FUNCTION "graphql"."is_array"("regtype") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."is_array"("regtype") TO "service_role";


--
-- Name: FUNCTION "is_composite"("regtype"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."is_composite"("regtype") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."is_composite"("regtype") TO "anon";
GRANT ALL ON FUNCTION "graphql"."is_composite"("regtype") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."is_composite"("regtype") TO "service_role";


--
-- Name: FUNCTION "is_literal"("field" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."is_literal"("field" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."is_literal"("field" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."is_literal"("field" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."is_literal"("field" "jsonb") TO "service_role";


--
-- Name: FUNCTION "is_variable"("field" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."is_variable"("field" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."is_variable"("field" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."is_variable"("field" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."is_variable"("field" "jsonb") TO "service_role";


--
-- Name: FUNCTION "join_clause"("local_columns" "text"[], "local_alias_name" "text", "parent_columns" "text"[], "parent_alias_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."join_clause"("local_columns" "text"[], "local_alias_name" "text", "parent_columns" "text"[], "parent_alias_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."join_clause"("local_columns" "text"[], "local_alias_name" "text", "parent_columns" "text"[], "parent_alias_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."join_clause"("local_columns" "text"[], "local_alias_name" "text", "parent_columns" "text"[], "parent_alias_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."join_clause"("local_columns" "text"[], "local_alias_name" "text", "parent_columns" "text"[], "parent_alias_name" "text") TO "service_role";


--
-- Name: FUNCTION "jsonb_coalesce"("val" "jsonb", "default_" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."jsonb_coalesce"("val" "jsonb", "default_" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."jsonb_coalesce"("val" "jsonb", "default_" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."jsonb_coalesce"("val" "jsonb", "default_" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."jsonb_coalesce"("val" "jsonb", "default_" "jsonb") TO "service_role";


--
-- Name: FUNCTION "jsonb_unnest_recursive_with_jsonpath"("obj" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."jsonb_unnest_recursive_with_jsonpath"("obj" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."jsonb_unnest_recursive_with_jsonpath"("obj" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."jsonb_unnest_recursive_with_jsonpath"("obj" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."jsonb_unnest_recursive_with_jsonpath"("obj" "jsonb") TO "service_role";


--
-- Name: FUNCTION "lowercase_first_letter"("text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."lowercase_first_letter"("text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."lowercase_first_letter"("text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."lowercase_first_letter"("text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."lowercase_first_letter"("text") TO "service_role";


--
-- Name: FUNCTION "name_literal"("ast" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."name_literal"("ast" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."name_literal"("ast" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."name_literal"("ast" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."name_literal"("ast" "jsonb") TO "service_role";


--
-- Name: FUNCTION "order_by_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."order_by_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]) TO "postgres";
GRANT ALL ON FUNCTION "graphql"."order_by_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]) TO "anon";
GRANT ALL ON FUNCTION "graphql"."order_by_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]) TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."order_by_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]) TO "service_role";


--
-- Name: FUNCTION "order_by_enum_to_clause"("order_by_enum_val" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."order_by_enum_to_clause"("order_by_enum_val" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."order_by_enum_to_clause"("order_by_enum_val" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."order_by_enum_to_clause"("order_by_enum_val" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."order_by_enum_to_clause"("order_by_enum_val" "text") TO "service_role";


--
-- Name: FUNCTION "parse"("text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."parse"("text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."parse"("text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."parse"("text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."parse"("text") TO "service_role";


--
-- Name: FUNCTION "prepared_statement_create_clause"("statement_name" "text", "variable_definitions" "jsonb", "query_" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."prepared_statement_create_clause"("statement_name" "text", "variable_definitions" "jsonb", "query_" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_create_clause"("statement_name" "text", "variable_definitions" "jsonb", "query_" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_create_clause"("statement_name" "text", "variable_definitions" "jsonb", "query_" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_create_clause"("statement_name" "text", "variable_definitions" "jsonb", "query_" "text") TO "service_role";


--
-- Name: FUNCTION "prepared_statement_execute_clause"("statement_name" "text", "variable_definitions" "jsonb", "variables" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."prepared_statement_execute_clause"("statement_name" "text", "variable_definitions" "jsonb", "variables" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_execute_clause"("statement_name" "text", "variable_definitions" "jsonb", "variables" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_execute_clause"("statement_name" "text", "variable_definitions" "jsonb", "variables" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_execute_clause"("statement_name" "text", "variable_definitions" "jsonb", "variables" "jsonb") TO "service_role";


--
-- Name: FUNCTION "prepared_statement_exists"("statement_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."prepared_statement_exists"("statement_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_exists"("statement_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_exists"("statement_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."prepared_statement_exists"("statement_name" "text") TO "service_role";


--
-- Name: FUNCTION "primary_key_clause"("entity" "regclass", "alias_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."primary_key_clause"("entity" "regclass", "alias_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."primary_key_clause"("entity" "regclass", "alias_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."primary_key_clause"("entity" "regclass", "alias_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."primary_key_clause"("entity" "regclass", "alias_name" "text") TO "service_role";


--
-- Name: FUNCTION "primary_key_columns"("entity" "regclass"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."primary_key_columns"("entity" "regclass") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."primary_key_columns"("entity" "regclass") TO "anon";
GRANT ALL ON FUNCTION "graphql"."primary_key_columns"("entity" "regclass") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."primary_key_columns"("entity" "regclass") TO "service_role";


--
-- Name: FUNCTION "primary_key_types"("entity" "regclass"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."primary_key_types"("entity" "regclass") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."primary_key_types"("entity" "regclass") TO "anon";
GRANT ALL ON FUNCTION "graphql"."primary_key_types"("entity" "regclass") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."primary_key_types"("entity" "regclass") TO "service_role";


--
-- Name: FUNCTION "rebuild_fields"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."rebuild_fields"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."rebuild_fields"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."rebuild_fields"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."rebuild_fields"() TO "service_role";


--
-- Name: FUNCTION "rebuild_on_ddl"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."rebuild_on_ddl"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_ddl"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_ddl"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_ddl"() TO "service_role";


--
-- Name: FUNCTION "rebuild_on_drop"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."rebuild_on_drop"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_drop"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_drop"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."rebuild_on_drop"() TO "service_role";


--
-- Name: FUNCTION "rebuild_schema"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."rebuild_schema"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."rebuild_schema"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."rebuild_schema"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."rebuild_schema"() TO "service_role";


--
-- Name: FUNCTION "rebuild_types"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."rebuild_types"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."rebuild_types"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."rebuild_types"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."rebuild_types"() TO "service_role";


--
-- Name: FUNCTION "reverse"("column_orders" "graphql"."column_order_w_type"[]); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."reverse"("column_orders" "graphql"."column_order_w_type"[]) TO "postgres";
GRANT ALL ON FUNCTION "graphql"."reverse"("column_orders" "graphql"."column_order_w_type"[]) TO "anon";
GRANT ALL ON FUNCTION "graphql"."reverse"("column_orders" "graphql"."column_order_w_type"[]) TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."reverse"("column_orders" "graphql"."column_order_w_type"[]) TO "service_role";


--
-- Name: FUNCTION "set_field_name"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."set_field_name"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."set_field_name"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."set_field_name"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."set_field_name"() TO "service_role";


--
-- Name: FUNCTION "set_type_name"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."set_type_name"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."set_type_name"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."set_type_name"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."set_type_name"() TO "service_role";


--
-- Name: FUNCTION "slug"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."slug"() TO "postgres";
GRANT ALL ON FUNCTION "graphql"."slug"() TO "anon";
GRANT ALL ON FUNCTION "graphql"."slug"() TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."slug"() TO "service_role";


--
-- Name: FUNCTION "sql_type_to_graphql_type"("regtype"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."sql_type_to_graphql_type"("regtype") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."sql_type_to_graphql_type"("regtype") TO "anon";
GRANT ALL ON FUNCTION "graphql"."sql_type_to_graphql_type"("regtype") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."sql_type_to_graphql_type"("regtype") TO "service_role";


--
-- Name: FUNCTION "text_to_comparison_op"("text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."text_to_comparison_op"("text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."text_to_comparison_op"("text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."text_to_comparison_op"("text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."text_to_comparison_op"("text") TO "service_role";


--
-- Name: FUNCTION "to_camel_case"("text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."to_camel_case"("text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."to_camel_case"("text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."to_camel_case"("text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."to_camel_case"("text") TO "service_role";


--
-- Name: FUNCTION "to_column_orders"("order_by_arg" "jsonb", "entity" "regclass", "variables" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."to_column_orders"("order_by_arg" "jsonb", "entity" "regclass", "variables" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."to_column_orders"("order_by_arg" "jsonb", "entity" "regclass", "variables" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."to_column_orders"("order_by_arg" "jsonb", "entity" "regclass", "variables" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."to_column_orders"("order_by_arg" "jsonb", "entity" "regclass", "variables" "jsonb") TO "service_role";


--
-- Name: FUNCTION "to_cursor_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."to_cursor_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]) TO "postgres";
GRANT ALL ON FUNCTION "graphql"."to_cursor_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]) TO "anon";
GRANT ALL ON FUNCTION "graphql"."to_cursor_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]) TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."to_cursor_clause"("alias_name" "text", "column_orders" "graphql"."column_order_w_type"[]) TO "service_role";


--
-- Name: FUNCTION "to_function_name"("regproc"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."to_function_name"("regproc") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."to_function_name"("regproc") TO "anon";
GRANT ALL ON FUNCTION "graphql"."to_function_name"("regproc") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."to_function_name"("regproc") TO "service_role";


--
-- Name: FUNCTION "to_regclass"("schema_" "text", "name_" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."to_regclass"("schema_" "text", "name_" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."to_regclass"("schema_" "text", "name_" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."to_regclass"("schema_" "text", "name_" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."to_regclass"("schema_" "text", "name_" "text") TO "service_role";


--
-- Name: FUNCTION "to_table_name"("regclass"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."to_table_name"("regclass") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."to_table_name"("regclass") TO "anon";
GRANT ALL ON FUNCTION "graphql"."to_table_name"("regclass") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."to_table_name"("regclass") TO "service_role";


--
-- Name: FUNCTION "to_type_name"("regtype"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."to_type_name"("regtype") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."to_type_name"("regtype") TO "anon";
GRANT ALL ON FUNCTION "graphql"."to_type_name"("regtype") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."to_type_name"("regtype") TO "service_role";


--
-- Name: FUNCTION "type_id"("graphql"."meta_kind"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."type_id"("graphql"."meta_kind") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."type_id"("graphql"."meta_kind") TO "anon";
GRANT ALL ON FUNCTION "graphql"."type_id"("graphql"."meta_kind") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."type_id"("graphql"."meta_kind") TO "service_role";


--
-- Name: FUNCTION "type_id"("regtype"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."type_id"("regtype") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."type_id"("regtype") TO "anon";
GRANT ALL ON FUNCTION "graphql"."type_id"("regtype") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."type_id"("regtype") TO "service_role";


--
-- Name: FUNCTION "type_id"("type_name" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."type_id"("type_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."type_id"("type_name" "text") TO "anon";
GRANT ALL ON FUNCTION "graphql"."type_id"("type_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."type_id"("type_name" "text") TO "service_role";


--
-- Name: TABLE "_type"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON TABLE "graphql"."_type" TO "postgres";
GRANT ALL ON TABLE "graphql"."_type" TO "anon";
GRANT ALL ON TABLE "graphql"."_type" TO "authenticated";
GRANT ALL ON TABLE "graphql"."_type" TO "service_role";


--
-- Name: FUNCTION "type_name"("rec" "graphql"."_type"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."type_name"("rec" "graphql"."_type") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."type_name"("rec" "graphql"."_type") TO "anon";
GRANT ALL ON FUNCTION "graphql"."type_name"("rec" "graphql"."_type") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."type_name"("rec" "graphql"."_type") TO "service_role";


--
-- Name: FUNCTION "type_name"("type_id" integer); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."type_name"("type_id" integer) TO "postgres";
GRANT ALL ON FUNCTION "graphql"."type_name"("type_id" integer) TO "anon";
GRANT ALL ON FUNCTION "graphql"."type_name"("type_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."type_name"("type_id" integer) TO "service_role";


--
-- Name: FUNCTION "type_name"("regclass", "graphql"."meta_kind"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."type_name"("regclass", "graphql"."meta_kind") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."type_name"("regclass", "graphql"."meta_kind") TO "anon";
GRANT ALL ON FUNCTION "graphql"."type_name"("regclass", "graphql"."meta_kind") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."type_name"("regclass", "graphql"."meta_kind") TO "service_role";


--
-- Name: FUNCTION "value_literal"("ast" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."value_literal"("ast" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."value_literal"("ast" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."value_literal"("ast" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."value_literal"("ast" "jsonb") TO "service_role";


--
-- Name: FUNCTION "value_literal_is_null"("ast" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."value_literal_is_null"("ast" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."value_literal_is_null"("ast" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."value_literal_is_null"("ast" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."value_literal_is_null"("ast" "jsonb") TO "service_role";


--
-- Name: FUNCTION "variable_definitions_sort"("variable_definitions" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."variable_definitions_sort"("variable_definitions" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."variable_definitions_sort"("variable_definitions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."variable_definitions_sort"("variable_definitions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."variable_definitions_sort"("variable_definitions" "jsonb") TO "service_role";


--
-- Name: FUNCTION "where_clause"("filter_arg" "jsonb", "entity" "regclass", "alias_name" "text", "variables" "jsonb", "variable_definitions" "jsonb"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."where_clause"("filter_arg" "jsonb", "entity" "regclass", "alias_name" "text", "variables" "jsonb", "variable_definitions" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."where_clause"("filter_arg" "jsonb", "entity" "regclass", "alias_name" "text", "variables" "jsonb", "variable_definitions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql"."where_clause"("filter_arg" "jsonb", "entity" "regclass", "alias_name" "text", "variables" "jsonb", "variable_definitions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."where_clause"("filter_arg" "jsonb", "entity" "regclass", "alias_name" "text", "variables" "jsonb", "variable_definitions" "jsonb") TO "service_role";


--
-- Name: FUNCTION "graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb"); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "service_role";


--
-- Name: FUNCTION "http_collect_response"("request_id" bigint, "async" boolean); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "supabase_functions_admin";
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "postgres";
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "anon";
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "service_role";


--
-- Name: FUNCTION "http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "supabase_functions_admin";
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "postgres";
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "anon";
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "authenticated";
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "service_role";


--
-- Name: FUNCTION "http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "supabase_functions_admin";
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "postgres";
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "anon";
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "authenticated";
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "service_role";


--
-- Name: FUNCTION "graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb"); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "service_role";


--
-- Name: FUNCTION "handle_new_user"(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "postgres";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";


--
-- Name: FUNCTION "update_vote_counts"(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "public"."update_vote_counts"() TO "postgres";
GRANT ALL ON FUNCTION "public"."update_vote_counts"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_vote_counts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_vote_counts"() TO "service_role";


--
-- Name: FUNCTION "first"("anyelement"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "graphql"."first"("anyelement") TO "postgres";
GRANT ALL ON FUNCTION "graphql"."first"("anyelement") TO "anon";
GRANT ALL ON FUNCTION "graphql"."first"("anyelement") TO "authenticated";
GRANT ALL ON FUNCTION "graphql"."first"("anyelement") TO "service_role";


--
-- Name: TABLE "pg_stat_statements"; Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "dashboard_user";


--
-- Name: TABLE "pg_stat_statements_info"; Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "dashboard_user";


--
-- Name: SEQUENCE "_field_id_seq"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "graphql"."_field_id_seq" TO "postgres";
GRANT ALL ON SEQUENCE "graphql"."_field_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "graphql"."_field_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "graphql"."_field_id_seq" TO "service_role";


--
-- Name: SEQUENCE "_type_id_seq"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "graphql"."_type_id_seq" TO "postgres";
GRANT ALL ON SEQUENCE "graphql"."_type_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "graphql"."_type_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "graphql"."_type_id_seq" TO "service_role";


--
-- Name: TABLE "entity"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON TABLE "graphql"."entity" TO "postgres";
GRANT ALL ON TABLE "graphql"."entity" TO "anon";
GRANT ALL ON TABLE "graphql"."entity" TO "authenticated";
GRANT ALL ON TABLE "graphql"."entity" TO "service_role";


--
-- Name: TABLE "entity_column"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON TABLE "graphql"."entity_column" TO "postgres";
GRANT ALL ON TABLE "graphql"."entity_column" TO "anon";
GRANT ALL ON TABLE "graphql"."entity_column" TO "authenticated";
GRANT ALL ON TABLE "graphql"."entity_column" TO "service_role";


--
-- Name: TABLE "entity_unique_columns"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON TABLE "graphql"."entity_unique_columns" TO "postgres";
GRANT ALL ON TABLE "graphql"."entity_unique_columns" TO "anon";
GRANT ALL ON TABLE "graphql"."entity_unique_columns" TO "authenticated";
GRANT ALL ON TABLE "graphql"."entity_unique_columns" TO "service_role";


--
-- Name: TABLE "type"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

REVOKE SELECT ON TABLE "graphql"."type" FROM "postgres";
REVOKE SELECT ON TABLE "graphql"."type" FROM "anon";
REVOKE SELECT ON TABLE "graphql"."type" FROM "authenticated";
REVOKE SELECT ON TABLE "graphql"."type" FROM "service_role";
GRANT ALL ON TABLE "graphql"."type" TO "postgres";
GRANT ALL ON TABLE "graphql"."type" TO "anon";
GRANT ALL ON TABLE "graphql"."type" TO "authenticated";
GRANT ALL ON TABLE "graphql"."type" TO "service_role";


--
-- Name: TABLE "enum_value"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

REVOKE SELECT ON TABLE "graphql"."enum_value" FROM "postgres";
REVOKE SELECT ON TABLE "graphql"."enum_value" FROM "anon";
REVOKE SELECT ON TABLE "graphql"."enum_value" FROM "authenticated";
REVOKE SELECT ON TABLE "graphql"."enum_value" FROM "service_role";
GRANT ALL ON TABLE "graphql"."enum_value" TO "postgres";
GRANT ALL ON TABLE "graphql"."enum_value" TO "anon";
GRANT ALL ON TABLE "graphql"."enum_value" TO "authenticated";
GRANT ALL ON TABLE "graphql"."enum_value" TO "service_role";


--
-- Name: TABLE "field"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

REVOKE SELECT ON TABLE "graphql"."field" FROM "postgres";
REVOKE SELECT ON TABLE "graphql"."field" FROM "anon";
REVOKE SELECT ON TABLE "graphql"."field" FROM "authenticated";
REVOKE SELECT ON TABLE "graphql"."field" FROM "service_role";
GRANT ALL ON TABLE "graphql"."field" TO "postgres";
GRANT ALL ON TABLE "graphql"."field" TO "anon";
GRANT ALL ON TABLE "graphql"."field" TO "authenticated";
GRANT ALL ON TABLE "graphql"."field" TO "service_role";


--
-- Name: TABLE "relationship"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON TABLE "graphql"."relationship" TO "postgres";
GRANT ALL ON TABLE "graphql"."relationship" TO "anon";
GRANT ALL ON TABLE "graphql"."relationship" TO "authenticated";
GRANT ALL ON TABLE "graphql"."relationship" TO "service_role";


--
-- Name: TABLE "schema_version"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON TABLE "graphql"."schema_version" TO "postgres";
GRANT ALL ON TABLE "graphql"."schema_version" TO "anon";
GRANT ALL ON TABLE "graphql"."schema_version" TO "authenticated";
GRANT ALL ON TABLE "graphql"."schema_version" TO "service_role";


--
-- Name: SEQUENCE "seq_schema_version"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "postgres";
GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "anon";
GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "authenticated";
GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "service_role";


--
-- Name: TABLE "Comment"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE "public"."Comment" TO "postgres";
GRANT ALL ON TABLE "public"."Comment" TO "anon";
GRANT ALL ON TABLE "public"."Comment" TO "authenticated";
GRANT ALL ON TABLE "public"."Comment" TO "service_role";


--
-- Name: SEQUENCE "Comment_id_seq"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "public"."Comment_id_seq" TO "postgres";
GRANT ALL ON SEQUENCE "public"."Comment_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Comment_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Comment_id_seq" TO "service_role";


--
-- Name: TABLE "Vote"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE "public"."Vote" TO "postgres";
GRANT ALL ON TABLE "public"."Vote" TO "anon";
GRANT ALL ON TABLE "public"."Vote" TO "authenticated";
GRANT ALL ON TABLE "public"."Vote" TO "service_role";


--
-- Name: SEQUENCE "DownVote_id_seq"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "public"."DownVote_id_seq" TO "postgres";
GRANT ALL ON SEQUENCE "public"."DownVote_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."DownVote_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."DownVote_id_seq" TO "service_role";


--
-- Name: TABLE "Post"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE "public"."Post" TO "postgres";
GRANT ALL ON TABLE "public"."Post" TO "anon";
GRANT ALL ON TABLE "public"."Post" TO "authenticated";
GRANT ALL ON TABLE "public"."Post" TO "service_role";


--
-- Name: SEQUENCE "Post_id_seq"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "public"."Post_id_seq" TO "postgres";
GRANT ALL ON SEQUENCE "public"."Post_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Post_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Post_id_seq" TO "service_role";


--
-- Name: TABLE "Profile"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE "public"."Profile" TO "postgres";
GRANT ALL ON TABLE "public"."Profile" TO "anon";
GRANT ALL ON TABLE "public"."Profile" TO "authenticated";
GRANT ALL ON TABLE "public"."Profile" TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- PostgreSQL database dump complete
--

