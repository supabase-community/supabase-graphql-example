import React from "react";
import type { NextPage } from "next";
import Head from "next/head";
import Link from "next/link";

import { useQuery } from "urql";

import {
  CodeIcon,
  CogIcon,
  CollectionIcon,
  ColorSwatchIcon,
  DatabaseIcon,
  GlobeAltIcon,
  LightningBoltIcon,
  ShieldCheckIcon,
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
        "Supabase has all the backend services you need to build a product with GraphQL.",
      icon: LightningBoltIcon,
      href: "https://www.supabase.com",
    },
    {
      name: "Supabase Auth",
      description:
        "Supabase Auth provides user management with row level security.",
      icon: ShieldCheckIcon,
      href: "https://supabase.com/auth",
    },
    {
      name: "Supabase UI",
      description:
        "An open-source UI component library inspired by Tailwind and AntDesign.",
      icon: CollectionIcon,
      href: "https://ui.supabase.io",
    },
    {
      name: "Tailwind CSS",
      description: "A utility-first CSS framework.",
      icon: ColorSwatchIcon,
      href: "https://tailwindcss.com",
    },
    {
      name: "PG GraphQL",
      description: "Adds GraphQL support to your PostgreSQL database.",
      icon: DatabaseIcon,
      href: "https://supabase.github.io/pg_graphql/",
    },
    {
      name: "GraphQL Code Generator",
      description:
        "Generate code from your GraphQL schema and operations with a simple CLI.",
      icon: CodeIcon,
      href: "https://www.graphql-code-generator.com",
    },
    {
      name: "GraphQL Config",
      description:
        "One configuration for development environment with your GraphQL Schema.",
      icon: CogIcon,
      href: "https://www.graphql-config.com",
    },
    {
      name: "GraphiQL",
      description:
        "GraphiQL is an in-browser IDE for writing, validating, and testing GraphQL queries.",
      icon: TemplateIcon,
      href: "https://www.graphql-yoga.com/docs/features/graphiql",
    },
    {
      name: "urql",
      description:
        "urql is a highly customizable and versatile GraphQL client.",
      icon: GlobeAltIcon,
      href: "https://formidable.com/open-source/urql/",
    },
  ];

  const faqs = [
    {
      id: 1,
      question: "GraphQL Queries and Mutations",
      answer:
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cupiditate laboriosam fugiat.",
    },
    {
      id: 2,
      question: "Pagination",
      answer:
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cupiditate laboriosam fugiat.",
    },
    {
      id: 3,
      question: "GraphQL Code Generation",
      answer:
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cupiditate laboriosam fugiat.",
    },
    {
      id: 4,
      question: "Supabase Postgres",
      answer:
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cupiditate laboriosam fugiat.",
    },
    {
      id: 4,
      question: "Supabase Auth",
      answer:
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cupiditate laboriosam fugiat.",
    },
    {
      id: 4,
      question: "Postgres Triggers",
      answer:
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cupiditate laboriosam fugiat.",
    },
    {
      id: 5,
      question: "Postgres Functions",
      answer:
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cupiditate laboriosam fugiat.",
    },
    {
      id: 5,
      question: "pg_graphql Postgres Extension",
      answer:
        "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cupiditate laboriosam fugiat.",
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
            GraphQL + Postgres + Tooling
          </h2>
          <p className="mt-2 text-3xl font-extrabold text-gray-900 tracking-tight sm:text-4xl">
            Everything you need to develop a GraphQL app
          </p>
          <p className="mt-5 max-w-prose mx-auto text-xl text-gray-500">
            Build your next GraphQL powered application like this one ... faster
            and easier with open source tools from Supabase, The Guild and more.
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

        <div className="bg-white">
          <div className="max-w-7xl mx-auto py-16 px-4 sm:py-24 sm:px-6 lg:px-8">
            <h2 className="text-3xl font-extrabold text-gray-900 text-center">
              Technologies Used
            </h2>
            <div className="mt-12">
              <dl className="space-y-10 md:space-y-0 md:grid md:grid-cols-2 md:gap-x-8 md:gap-y-12 lg:grid-cols-3">
                {faqs.map((faq) => (
                  <div key={faq.id}>
                    <dt className="text-lg leading-6 font-medium text-gray-900">
                      {faq.question}
                    </dt>
                    <dd className="mt-2 text-base text-gray-500">
                      {faq.answer}
                    </dd>
                  </div>
                ))}
              </dl>
            </div>
          </div>
        </div>
      </div>
    </Container>
  );
};

export default About;
