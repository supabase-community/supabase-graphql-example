import React from "react";
import type { NextPage } from "next";
import { Auth } from "@supabase/ui";
import { useSupabaseClient } from "../lib/supabase";

const LogIn: NextPage = () => {
  const { user } = Auth.useUser();
  const supabaseClient = useSupabaseClient();

  return user ? (
    <pre>
      <code>{JSON.stringify(user, null, 2)}</code>
      <button
        onClick={() => {
          supabaseClient.auth.signOut();
        }}
      >
        Log out
      </button>
    </pre>
  ) : (
    <Auth supabaseClient={supabaseClient} providers={["github"]} />
  );
};

export default LogIn;
