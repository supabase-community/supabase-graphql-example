import React from "react";

export function Loading() {
  return (
    <div className="grid place-items-center h-80">
      <svg
        className="animate-bounce w-12 h-12 text-green-400"
        viewBox="0 0 20 20"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          fill="currentColor"
          fillRule="evenodd"
          d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z"
          clipRule="evenodd"
        ></path>
      </svg>{" "}
    </div>
  );
}
