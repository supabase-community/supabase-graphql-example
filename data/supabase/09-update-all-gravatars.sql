WITH a AS (
	SELECT
		id,
		'https://www.gravatar.com/avatar/' || md5(email) || '?d=mp' AS "avatarUrl",
		email
	FROM
		auth.users
)
UPDATE
	public. "Profile"
SET
	"avatarUrl" = a. "avatarUrl"
FROM
	a
WHERE
	a.id = public. "Profile".id
