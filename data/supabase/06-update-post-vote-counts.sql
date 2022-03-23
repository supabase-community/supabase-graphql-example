CREATE OR REPLACE FUNCTION public.update_vote_counts()
RETURNS trigger as $$
BEGIN

WITH r AS (
SELECT
	"postId",
	count(1) "voteTotal",
	count(1) FILTER (WHERE direction = 'UP') "upVoteTotal",
	count(1) FILTER (WHERE direction = 'DOWN') "downVoteTotal",
	coalesce(sum(
			CASE WHEN direction = 'UP' THEN
				1
			WHEN direction = 'DOWN' THEN
				- 1
			ELSE
				0
			END), 0) "voteDelta",
	abs(sum(
		CASE WHEN direction = 'UP' THEN
			1
		WHEN direction = 'DOWN' THEN
			- 1
		ELSE
			0
		END) - 1 / (DATE_PART('hour', now() - max("createdAt")) + 2) ^ 1.8) AS "score",
	dense_rank() OVER (ORDER BY sum( CASE WHEN direction = 'UP' THEN
			1
		WHEN direction = 'DOWN' THEN
			- 1
		ELSE
			0
		END) - 1 / (DATE_PART('hour', now() - max("createdAt")) + 2) ^ 1.8 DESC) "voteRank"
FROM
	"Vote"
GROUP BY
	"postId"
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

