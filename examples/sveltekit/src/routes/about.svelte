<script lang="ts">
	import Icons from '$lib/components/layout/Icons.svelte';

	const features = [
		{
			name: 'PG GraphQL',
			description: 'Adds GraphQL support to your PostgreSQL database.',
			icon: 'DatabaseIcon',
			href: 'https://supabase.github.io/pg_graphql/'
		},
		{
			name: 'GraphQL Code Generator',
			description: 'Generate code from your GraphQL schema and operations with a simple CLI.',
			icon: 'CodeIcon',
			href: 'https://www.graphql-code-generator.com'
		},
		{
			name: 'GraphQL Config',
			description: 'One configuration for development environment with your GraphQL Schema.',
			icon: 'CogIcon',
			href: 'https://www.graphql-config.com'
		},
		{
			name: 'Supabase',
			description:
				'Supabase has all the backend services you need to build a product with GraphQL.',
			icon: 'LightningBoltIcon',
			href: 'https://www.supabase.com'
		},
		{
			name: 'Supabase Auth',
			description: 'Supabase Auth provides user management with row level security.',
			icon: 'ShieldCheckIcon',
			href: 'https://supabase.com/auth'
		},
		{
			name: 'Supabase UI',
			description: 'An open-source UI component library inspired by Tailwind and AntDesign.',
			icon: 'CollectionIcon',
			href: 'https://ui.supabase.io'
		},
		{
			name: 'Yoga GraphiQL',
			description:
				'Yoga GraphiQL is an in-browser IDE for writing, validating, and testing GraphQL queries.',
			icon: 'TemplateIcon',
			href: 'https://www.graphql-yoga.com/docs/features/graphiql'
		},
		{
			name: 'KitQL',
			description: 'A set of tools, helping you building efficient apps in a fast way.',
			icon: 'KitQL',
			href: 'https://github.com/jycouet/kitql'
		},
		{
			name: 'Tailwind CSS',
			description: 'A utility-first CSS framework to rapidly build modern websites.',
			icon: 'ColorSwatchIcon',
			href: 'https://tailwindcss.com'
		}
	];

	const faqs = [
		{
			id: 1,
			question: 'GraphQL Query and Mutation Operations',
			answer:
				'The data on this page is fetched from the GraphQL layer auto-generated via pg_graphql.'
		},
		{
			id: 2,
			question: 'Pagination',
			answer:
				'pg_graphql generates standardized pagination types and fields as defined by the GraphQL Cursor Connections Specification.'
		},
		{
			id: 3,
			question: 'GraphQL Code Generation',
			answer:
				'GraphQL Code Generator introspects your GraphQL schema and operations and generates the types for full backend to frontend type-safety.'
		},
		{
			id: 4,
			question: 'GraphQL Fragments',
			answer:
				'Components use GraphQL fragments to share logic between multiple queries and mutations.'
		},
		{
			id: 5,
			question: 'pg_graphql Postgres Extension',
			answer: 'pg_graphql generates a GraphQL API based on the Postgres schema.'
		},
		{
			id: 6,
			question: 'Total Counts',
			answer:
				"Use pg_graphql's totalCount comment-based GraphQL Directive to count of the rows that match the query's filters."
		},
		{
			id: 7,
			question: 'Schema Inflection',
			answer:
				"Use pg_graphql's inflect_names comment-based GraphQL Directive to convert from snake_case to PascalCase for type names, and snake_case to camelCase for field names to match Javascript conventions when generating your GraphQL schema."
		},
		{
			id: 8,
			question: 'Supabase Postgres',
			answer:
				'Every Supabase project is a dedicated PostgreSQL database, trusted by millions of developers. It provide some of the most common extensions with a one-click install.'
		},
		{
			id: 9,
			question: 'Supabase Auth',
			answer:
				'Authorization cannot get any easier. Every Supabase project comes with a complete User Management system that works without any additional tools.'
		},
		{
			id: 10,
			question: 'Postgres RLS',
			answer:
				'Row level security on the Postgres layer ensures that viewers can only access what they are allowed to access and can only create records when authenticated.'
		},
		{
			id: 11,
			question: 'Postgres Functions',
			answer:
				'Built-in support for SQL functions. These functions live inside your database, and they can be used with the Supabase API or invoked by a Postgres Trigger.'
		},
		{
			id: 12,
			question: 'Postgres Triggers',
			answer:
				'Execute any SQL code after inserting, updating, or deleting data. We recalculate the feed scores by invoking a function each time someone votes (or change their vote).'
		}
	];
</script>

<svelte:head>
	<title>supanews | About</title>
</svelte:head>

<div class="relative bg-white py-4 sm:py-8 lg:py-12">
	<div class="mx-auto max-w-md px-4 text-center sm:max-w-3xl sm:px-6 lg:px-8 lg:max-w-7xl">
		<h2 class="text-base font-semibold tracking-wider text-green-600 uppercase">
			GraphQL + Postgres + Tooling
		</h2>
		<p class="mt-2 text-3xl font-extrabold text-gray-900 tracking-tight sm:text-4xl">
			Everything you need to develop a GraphQL app
		</p>
		<p class="mt-5 max-w-prose mx-auto text-xl text-gray-500">
			Build your next GraphQL powered application like this one ... faster and easier with open
			source tools from{' '}
			<a class="text-gray-800" href="https://www.supabase.com"> Supabase </a>
			,{' '}
			<a class="text-gray-800" href="https://www.the-guild.dev"> The Guild </a>{' '}
			and more.
		</p>
		<div class="mt-12">
			<div class="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
				{#each features as feature}
					<div class="pt-6">
						<div class="flow-root bg-gray-50 rounded-lg px-6 pb-8">
							<a href={feature.href}>
								<div class="-mt-6">
									<div>
										<span
											class="inline-flex items-center justify-center p-3 bg-gradient-to-r from-teal-500 to-green-600 rounded-md shadow-lg"
										>
											<Icons name={feature.icon} class="h-6 w-6 text-white" />
										</span>
									</div>
									<h3 class="mt-8 text-lg font-medium text-gray-900 tracking-tight">
										{feature.name}
									</h3>
									<p class="mt-5 text-base text-gray-500">
										{feature.description}
									</p>
								</div>
							</a>
						</div>
					</div>
				{/each}
			</div>
		</div>
	</div>

	<div class="bg-white">
		<div class="max-w-7xl mx-auto py-16 px-4 sm:py-24 sm:px-6 lg:px-8">
			<h2 class="text-3xl font-extrabold text-gray-900 text-center">Technologies Used</h2>
			<div class="mt-12">
				<dl
					class="space-y-10 md:space-y-0 md:grid md:grid-cols-2 md:gap-x-8 md:gap-y-12 lg:grid-cols-3"
				>
					{#each faqs as faq}
						<div>
							<dt class="text-lg leading-6 font-medium text-gray-900">
								{faq.question}
							</dt>
							<dd class="mt-2 text-base text-gray-500">
								{faq.answer}
							</dd>
						</div>
					{/each}
				</dl>
			</div>
		</div>
	</div>
</div>
