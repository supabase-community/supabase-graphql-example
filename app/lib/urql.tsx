import { NextUrqlClientConfig } from "next-urql";
import { createSupabaseClient } from "./supabase";

export function getUrqlConfig(): NextUrqlClientConfig {
  return (_ssrExchange, ctx) => {
    const supabaseClient = createSupabaseClient();

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

    return {
      url: `${process.env.NEXT_PUBLIC_SUPABASE_URL!}/graphql/v1`,
      fetchOptions: { headers: getHeaders() },
    };
  };
}
