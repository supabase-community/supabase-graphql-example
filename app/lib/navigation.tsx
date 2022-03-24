import { Auth } from "@supabase/ui";
import Link from "next/link";
import React from "react";

export function Navigation() {
  const user = Auth.useUser();
  return (
    <div>
      SupaNews{" "}
      {user.user === null ? (
        <Link href="/login">login</Link>
      ) : (
        <>
          <Link href="/account">account</Link>
          <Link href="/logout">logout</Link>
        </>
      )}
    </div>
  );
}
