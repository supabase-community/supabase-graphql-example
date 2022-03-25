ALTER TABLE "Post"
ADD CONSTRAINT post_title_length check (char_length(title) > 0);

ALTER TABLE "Post"
ADD CONSTRAINT post_url_length check (char_length(url) > 0);
