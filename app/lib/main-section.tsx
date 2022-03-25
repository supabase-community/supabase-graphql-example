import React from "react";

export function MainSection(props: { children: React.ReactNode }) {
  return (
    <main className="min-h-screen px-4 py-0 flex-1 flex flex-column max-w-screen-md mx-auto">
      {props.children}
    </main>
  );
}
