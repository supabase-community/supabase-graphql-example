import React from "react";
import type { NextPage } from "next";
import { Auth } from "@supabase/ui";
import { useSupabaseClient } from "../lib/supabase";
import { useRouter } from "next/router";

const LogOut: NextPage = () => {
  const supabaseClient = useSupabaseClient();
  const router = useRouter();

  React.useEffect(() => {
    supabaseClient.auth.signOut().then(() => router.replace("/"));
  }, []);
  return null;
};

export default LogOut;
