import { WithUrqlProps } from "next-urql";
import type { AppProps } from "next/app";
import { FC, useEffect, useState } from "react";
import { Footer } from "../lib/footer";
import { Navigation } from "../lib/navigation";
import { createSupabaseClient, SupabaseProvider } from "../lib/supabase";
import "../styles/globals.css";

type PagePropsWithMaybeUrql = WithUrqlProps | Record<any, any>;
type MyAppProps = Omit<AppProps<PagePropsWithMaybeUrql>, "pageProps"> & {
  pageProps: PagePropsWithMaybeUrql;
};

const MyApp: FC<MyAppProps> = (props) => {
  const { Component, pageProps } = props;
  const [client] = useState(createSupabaseClient);

  const resetUrqlClient = pageProps.resetUrqlClient;

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

export default MyApp;
