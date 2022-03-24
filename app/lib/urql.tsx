import React from "react";
import { createClient, Provider } from "urql";
import { useSupabaseClient } from "./supabase";

export function UrqlProvider(props: { children: React.ReactElement }) {
  const supabaseClient = useSupabaseClient();

  function getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      apikey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    };
    const authorization = supabaseClient.auth.session()?.access_token;

    if (authorization) {
      headers["authorization"] = `Bearer ${authorization}`;
    }

    return headers;
  }

  const [client] = React.useState(() =>
    createClient({
      url: `${process.env.NEXT_PUBLIC_SUPABASE_URL!}/rest/v1/rpc/graphql`,
      fetchOptions: {
        headers: getHeaders(),
      },
    })
  );
  return <Provider value={client}>{props.children}</Provider>;
}
