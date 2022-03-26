import React from "react";
import { LightningBoltIcon } from "@heroicons/react/solid";

export function Loading() {
  return (
    <div className="grid place-items-center h-80">
      <LightningBoltIcon className="animate-bounce w-12 h-12 text-green-400" />
    </div>
  );
}
