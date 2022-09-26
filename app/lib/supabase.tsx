import React from "react";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { Auth } from "@supabase/ui";

const SupabaseClientContext = React.createContext<SupabaseClient | null>(null);

export function SupabaseProvider(props: { children: React.ReactNode }) {
  const [client] = React.useState(() =>
    createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL ?? "http://127.0.0.1:6969",
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "noop"
    )
  );

  return (
    <SupabaseClientContext.Provider value={client}>
      <Auth.UserContextProvider supabaseClient={client}>
        {props.children}
      </Auth.UserContextProvider>
    </SupabaseClientContext.Provider>
  );
}

export function useSupabaseClient(): SupabaseClient {
  const client = React.useContext(SupabaseClientContext);
  if (client === null) {
    throw new Error(
      "Supabase client not provided via context.\n" +
        "Did you forget to wrap your component tree with SupabaseProvider?"
    );
  }
  return client;
}
