<script lang="ts">
	import { page } from '$app/stores';
	// import { Auth } from "@supabase/ui";

	import Icons from './Icons.svelte';

	export let user = null;

	let routes = [
		{ name: 'feed', href: '/' },
		{ name: 'new', href: '/newest' },
		{ name: 'comments', href: '/comments' },
		{ name: 'submit', href: '/submit' },
		{ name: 'about', href: '/about' }
	];

	function getClassFromRoute(activeRoute: string, href: string) {
		return '/' + activeRoute === href ? 'text-black' : 'text-gray-400';
	}
</script>

<header class="text-gray-600 body-font max-w-screen-md mx-auto">
	<div class="container mx-auto flex flex-wrap p-5 flex-col md:flex-row items-center">
		<a href="/" class="flex title-font font-medium items-center text-gray-900 mb-4 md:mb-0">
			<Icons name="SupabaseIcon" />
			<span class="ml-3 text-xl">supanews</span>
		</a>
		<nav
			class="md:mr-auto md:ml-4 md:py-1 md:pl-4 md:border-l md:border-gray-400	flex flex-wrap items-center text-base justify-center"
		>
			{#each routes as { name, href }}
				<a {href} class={`mr-5 hover:text-gray-900 ${getClassFromRoute($page.routeId, href)}`}
					>{name}</a
				>
			{/each}
		</nav>

		{#if user === null}
			<a
				href="/login"
				class="inline-flex items-center mt-4 md:mt-0 md:mr-5 text-gray-400 hover:text-gray-900"
			>
				login
			</a>
		{:else}
			<a
				href="/account"
				class="inline-flex items-center mt-4 md:mt-0 md:mr-5 hover:text-gray-900
              {getClassFromRoute($page.routeId, '/account')}"
			>
				account
			</a>
			<a
				href="/api/logout"
				class="inline-flex items-center mt-4 md:mt-0 text-gray-400 hover:text-gray-900"
			>
				logout
			</a>
		{/if}
	</div>
</header>
