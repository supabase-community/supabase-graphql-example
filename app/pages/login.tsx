import React from "react";
import type { NextPage } from "next";
import { Auth } from "@supabase/ui";
import { useSupabaseClient } from "../lib/supabase";
import { useRouter } from "next/router";
import { Container } from "../lib/container";
import { MainSection } from "../lib/main-section";

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

  return (
    <Container>
      <MainSection>
        <div className="m-width-md mx-auto">
          <h1 className="font-semibold text-xl tracking-tight mb-5">Login</h1>

          <Auth supabaseClient={supabaseClient} providers={["github"]} />
        </div>
      </MainSection>
    </Container>
  );
};

export default LogIn;
