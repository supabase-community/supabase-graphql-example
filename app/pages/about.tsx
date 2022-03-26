import React from "react";
import type { NextPage } from "next";
import Head from "next/head";
import Link from "next/link";

import { useQuery } from "urql";

import {
  LightningBoltIcon,
  CogIcon,
  DatabaseIcon,
  ShieldCheckIcon,
  CodeIcon,
  TemplateIcon,
} from "@heroicons/react/outline";

import { gql } from "../gql";
import { Container } from "../lib/container";
import { FeedItem } from "../lib/feed-item";
import { noopUUID } from "../lib/noop-uuid";

const About: NextPage = () => {
  const features = [
    {
      name: "Supabase",
      description:
        "Supabase is an open source Firebase alternative. It provides all the backend services you need to build a product. You can use it completely, or just the services you require.",
      icon: LightningBoltIcon,
      href: "https://www.supabase.com",
    },
    {
      name: "Supabase Auth",
      description:
        "Supabase Auth provides user management with row level security",
      icon: ShieldCheckIcon,
      href: "https://supabase.com/auth",
    },
    {
      name: "PG GraphQL",
      description: "Adds GraphQL support to your PostgreSQL database.",
      icon: DatabaseIcon,
      href: "https://supabase.github.io/pg_graphql/",
    },
    {
      name: "GraphQL Codegen",
      description:
        "Generate code from your GraphQL schema and operations with a simple CLI. Code with type safety and autocomplete.",
      icon: CodeIcon,
      href: "https://www.graphql-code-generator.com",
    },
    {
      name: "GraphiQL",
      description:
        "GraphiQL from GraphQL Yoga is an in-browser IDE for writing, validating, and testing GraphQL queries.",
      icon: TemplateIcon,
      href: "https://www.graphql-yoga.com/docs/features/graphiql",
    },
    {
      name: "urql",
      description:
        "urql is a highly customizable and versatile GraphQL client.",
      icon: CogIcon,
      href: "https://formidable.com/open-source/urql/",
    },
  ];

  return (
    <Container>
      <Head>
        <title>supanews | About</title>
        <meta name="description" content="What is hot?" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <div className="relative bg-white py-4 sm:py-8 lg:py-12">
        <div className="mx-auto max-w-md px-4 text-center sm:max-w-3xl sm:px-6 lg:px-8 lg:max-w-7xl">
          <h2 className="text-base font-semibold tracking-wider text-green-600 uppercase">
            Deploy faster
          </h2>
          <p className="mt-2 text-3xl font-extrabold text-gray-900 tracking-tight sm:text-4xl">
            Everything you need to deploy a GraphQL app
          </p>
          <p className="mt-5 max-w-prose mx-auto text-xl text-gray-500">
            Built GraphQL powered apps with tools from Supabase and The Guild
            faster and easier.
          </p>
          <div className="mt-12">
            <div className="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
              {features.map((feature) => (
                <div key={feature.name} className="pt-6">
                  <div className="flow-root bg-gray-50 rounded-lg px-6 pb-8">
                    <Link href={feature.href}>
                      <a>
                        <div className="-mt-6">
                          <div>
                            <span className="inline-flex items-center justify-center p-3 bg-gradient-to-r from-teal-500 to-green-600 rounded-md shadow-lg">
                              <feature.icon
                                className="h-6 w-6 text-white"
                                aria-hidden="true"
                              />
                            </span>
                          </div>
                          <h3 className="mt-8 text-lg font-medium text-gray-900 tracking-tight">
                            {feature.name}
                          </h3>
                          <p className="mt-5 text-base text-gray-500">
                            {feature.description}
                          </p>
                        </div>
                      </a>
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </Container>
  );
};

export default About;
