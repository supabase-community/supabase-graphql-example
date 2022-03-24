import React from "react";
import type { NextPage } from "next";
import { Auth } from "@supabase/ui";
import { useSupabaseClient } from "../lib/supabase";
import { useRouter } from "next/router";

const LogIn: NextPage = () => {
  const { user } = Auth.useUser();
  const supabaseClient = useSupabaseClient();
  const router = useRouter();

  React.useEffect(() => {
    if (user !== null) {
      router.replace("/account");
    }
  }, []);

  if (user) {
    return null;
  }

  return <Auth supabaseClient={supabaseClient} providers={["github"]} />;
};

export default LogIn;
