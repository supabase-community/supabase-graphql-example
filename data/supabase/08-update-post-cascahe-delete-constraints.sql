ALTER TABLE ONLY public."Comment"
    DROP CONSTRAINT "Comment_postId_fkey";

ALTER TABLE ONLY public."Comment"
    ADD CONSTRAINT "Comment_postId_fkey" FOREIGN KEY ("postId") REFERENCES public."Post"(id) ON DELETE CASCADE;

ALTER TABLE ONLY public."Vote"
    DROP CONSTRAINT "DownVote_postId_fkey";

ALTER TABLE ONLY public."Vote"
    ADD CONSTRAINT "Vote_postId_fkey" FOREIGN KEY ("postId") REFERENCES public."Post"(id) ON DELETE CASCADE;

