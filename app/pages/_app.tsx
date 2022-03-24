import "../styles/globals.css";
import type { AppProps } from "next/app";
import { UrqlProvider } from "../lib/urql";
import { SupabaseProvider } from "../lib/supabase";
import { Navigation } from "../lib/navigation";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <SupabaseProvider>
      <UrqlProvider>
        <Navigation />
        <Component {...pageProps} />
      </UrqlProvider>
    </SupabaseProvider>
  );
}

export default MyApp;
