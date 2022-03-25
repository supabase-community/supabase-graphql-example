import { Auth } from "@supabase/ui";
import Link from "next/link";
import React from "react";
import { ActiveLink } from "./active-link";
import { SupabaseIcon } from "./icons";

export function Navigation() {
  const user = Auth.useUser();
  return (
    <header className="text-gray-600 body-font max-w-screen-md mx-auto">
      <div className="container mx-auto flex flex-wrap p-5 flex-col md:flex-row items-center">
        <Link href="/">
          <a className="flex title-font font-medium items-center text-gray-900 mb-4 md:mb-0">
            <SupabaseIcon height={24} />
            <span className="ml-3 text-xl">supanews</span>
          </a>
        </Link>
        <nav className="md:mr-auto md:ml-4 md:py-1 md:pl-4 md:border-l md:border-gray-400	flex flex-wrap items-center text-base justify-center">
          <ActiveLink href="/" activeClassName="text-black">
            <a className="mr-5 hover:text-gray-900 text-gray-400">feed</a>
          </ActiveLink>
          <ActiveLink href="/newest" activeClassName="text-black">
            <a className="mr-5 hover:text-gray-900 text-gray-400">new</a>
          </ActiveLink>
          <ActiveLink href="/comments" activeClassName="text-black">
            <a className="mr-5 hover:text-gray-900 text-gray-400">comments</a>
          </ActiveLink>
          <ActiveLink href="/submit" activeClassName="text-black">
            <a className="mr-5 hover:text-gray-900 text-gray-400">submit</a>
          </ActiveLink>
        </nav>
        {user.user === null ? (
          <Link href="login">
            <button className="inline-flex items-center bg-gray-100 border-0 py-1 px-3 focus:outline-none hover:bg-gray-200 rounded text-base mt-4 md:mt-0">
              login
              <svg
                fill="none"
                stroke="currentColor"
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                className="w-4 h-4 ml-1"
                viewBox="0 0 24 24"
              >
                <path d="M5 12h14M12 5l7 7-7 7"></path>
              </svg>
            </button>
          </Link>
        ) : (
          <>
            <ActiveLink href="/account" activeClassName="text-black ">
              <a className="inline-flex items-center mt-4 md:mt-0 md:mr-5">
                account
              </a>
            </ActiveLink>
            <Link href="/logout">
              <a className="inline-flex items-center mt-4 md:mt-0">logout</a>
            </Link>
          </>
        )}
      </div>
    </header>
  );
}
