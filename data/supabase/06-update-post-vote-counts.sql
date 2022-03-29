CREATE OR REPLACE FUNCTION public.update_vote_counts()
RETURNS trigger as $$
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
$$ language plpgsql security definer;

CREATE TRIGGER on_vote_created AFTER INSERT ON public."Vote" FOR EACH ROW EXECUTE FUNCTION public.update_vote_counts();
CREATE TRIGGER on_vote_deleted AFTER DELETE ON public."Vote" FOR EACH ROW EXECUTE FUNCTION public.update_vote_counts();

