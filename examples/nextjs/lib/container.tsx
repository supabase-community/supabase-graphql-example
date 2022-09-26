import React from "react";

export function Container(props: { children: React.ReactNode }) {
  return <main className="px-0 py-2">{props.children}</main>;
}
