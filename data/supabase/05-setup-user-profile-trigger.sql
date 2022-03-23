CREATE OR REPLACE FUNCTION public.update_vote_counts ()
	RETURNS TRIGGER
	AS $$
BEGIN
	WITH u AS (
		SELECT
			v. "postId",
			coalesce(count(*),
				0) AS total
		FROM
			public. "Vote" v
		WHERE
			v.direction = 'UP'
		GROUP BY
			v. "postId"
),
d AS (
	SELECT
		v. "postId",
		coalesce(count(*),
			0) AS total
	FROM
		public. "Vote" v
	WHERE
		v.direction = 'DOWN'
	GROUP BY
		v. "postId"
),
t AS (
	SELECT
		p.id,
		coalesce(u.total,
			0) AS "upVoteTotal",
		coalesce(d.total,
			0) AS "downVoteTotal",
		coalesce(u.total,
			0) - coalesce(d.total,
			0) AS "voteTotal"
	FROM
		public. "Post" p
	LEFT JOIN u ON p.id = u. "postId"
	LEFT JOIN d ON p.id = d. "postId"
),
r AS (
	SELECT
		*,
		DENSE_RANK() OVER (ORDER BY t. "voteTotal" DESC) AS "voteRank"
	FROM
		t
)
UPDATE
	public. "Post"
SET
	"upVoteTotal" = r. "upVoteTotal",
	"downVoteTotal" = r. "downVoteTotal",
	"voteTotal" = r. "voteTotal",
	"voteRank" = r. "voteRank"
FROM
	r
WHERE
	r.id = public. "Post".id;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_vote_created AFTER INSERT ON public."Vote" FOR EACH ROW EXECUTE FUNCTION public.update_vote_counts();

CREATE  TRIGGER on_vote_deleted AFTER DELETE ON public."Vote" FOR EACH ROW EXECUTE FUNCTION public.update_vote_counts();
