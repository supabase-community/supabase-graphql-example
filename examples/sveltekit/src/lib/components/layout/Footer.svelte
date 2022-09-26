<script lang="ts">
	import Icons from './Icons.svelte';

	const navigation = {
		main: [{ name: '🤔 How did we build this app?', href: '/about' }],
		social: [
			{
				name: 'Twitter',
				href: 'https://twitter.com/supabase',
				icon: 'Twitter'
			},
			{
				name: 'GitHub',
				href: 'https://github.com/supabase-community/supabase-graphql-example',
				icon: 'GitHub'
			}
		]
	};
</script>

<footer class="bg-white">
	<div class="max-w-7xl mx-auto py-4 px-4 overflow-hidden sm:px-6 lg:px-8">
		<div class="bg-white">
			<div class="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8">
				<div class="grid grid-cols-2 gap-8 md:grid-cols-2 lg:grid-cols-2">
					<div class="col-span-1 flex justify-center md:col-span-2 lg:col-span-1">
						<a href="https://www.supabase.com">
							<img class="h-12" src="/supabase-logo-wordmark--light.svg" alt="Supabase" />
						</a>
					</div>
					<div class="col-span-1 flex justify-center md:col-span-2 lg:col-span-1">
						<a href="https://www.the-guild.dev">
							<img class="h-12" src="/the-guild-full-dark.svg" alt="The Guild" />
						</a>
					</div>
				</div>
			</div>
		</div>
		<nav class="-mx-5 -my-2 flex flex-wrap justify-center" aria-label="Footer">
			{#each navigation.main as item}
				<div class="px-5 py-2">
					<a href={item.href} class="text-base text-gray-500 hover:text-gray-900">
						{item.name}
					</a>
				</div>
			{/each}
		</nav>
		<div class="mt-8 flex justify-center space-x-6">
			{#each navigation.social as item}
				<a href={item.href} class="text-gray-400 hover:text-gray-500">
					<span class="sr-only">{item.name}</span>
					<Icons name={item.icon} class="h-6 w-6" />
				</a>
			{/each}
		</div>
	</div>
</footer>
