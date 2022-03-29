import { AuthChangeEvent } from "@supabase/supabase-js";
import { withUrqlClient, WithUrqlProps } from "next-urql";
import type { AppProps } from "next/app";
import { FC, useEffect, useState } from "react";
import { Footer } from "../lib/footer";
import { Navigation } from "../lib/navigation";
import { createSupabaseClient, SupabaseProvider } from "../lib/supabase";
import { getUrqlConfig } from "../lib/urql";
import "../styles/globals.css";

const MyApp: FC<AppProps & WithUrqlProps> = (props) => {
  const { Component, pageProps, resetUrqlClient } = props;
  const [client] = useState(createSupabaseClient);

  useEffect(() => {
    if (!resetUrqlClient) return;

    const { data } = client.auth.onAuthStateChange((event, session) => {
      if (event === "SIGNED_IN" || event === "SIGNED_OUT") {
        resetUrqlClient?.();
      }
    });

    return data?.unsubscribe;
  }, [client, resetUrqlClient]);

  return (
    <SupabaseProvider client={client}>
      <Navigation />
      <Component {...pageProps} />
      <Footer />
    </SupabaseProvider>
  );
};

export default withUrqlClient(getUrqlConfig(), { ssr: true })(MyApp);
