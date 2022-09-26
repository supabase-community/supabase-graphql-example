import React from "react";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { Auth } from "@supabase/ui";

let clientSingleton: SupabaseClient;

export function createSupabaseClient() {
  if (clientSingleton) {
    return clientSingleton;
  }

  const client = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

  if (typeof window !== "undefined") {
    clientSingleton = client;
  }
  return client;
}

const SupabaseClientContext = React.createContext<SupabaseClient | null>(null);

export function SupabaseProvider(props: {
  children: React.ReactNode;
  client: SupabaseClient;
}) {
  const { client } = props;

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
