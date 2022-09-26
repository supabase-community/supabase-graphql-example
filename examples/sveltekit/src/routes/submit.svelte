<script context="module" lang="ts">
	export async function load({ fetch, url, params, session, stuff }) {
		const profileId = session.user ? session.user.id : noopUUID;
		if (!session.user) {
			return {
				status: 302,
				redirect: '/login?from=submit'
			};
		}

		return { props: { profileId } };
	}
</script>

<script lang="ts">
	import { goto } from '$app/navigation';

	import Button from '$lib/components/supabase/ui/Button.svelte';
	import { KQL_CreatePostMutation } from '$lib/graphql/_kitql/graphqlStores';
	import { noopUUID } from '$lib/utils/noop-uuid';

	export let profileId: string;

	$: errorState = $KQL_CreatePostMutation.errors;

	async function submit(e) {
		const formData: any = new FormData(e.target);
		const jsonData = Object.fromEntries(formData.entries());
		KQL_CreatePostMutation.mutate({
			variables: {
				input: {
					title: jsonData.title,
					url: jsonData.url,
					profileId
				}
			}
		});
		await goto('/newest');
	}
</script>

<svelte:head>
	<title>supanews | Submit New Item</title>
</svelte:head>

<section class="container px-5 py-24 mx-auto max-w-md">
	<h1 class="font-semibold text-xl tracking-tight mb-5">Submit</h1>

	<form on:submit|preventDefault={submit}>
		<div class="mb-4">
			<label for="title" class="block mb-2"> Title </label>
			<input
				id="title"
				name="title"
				type="text"
				class="placeholder-gray-300 focus:ring-primary focus:border-primary block w-full sm:text-sm border-gray-300 rounded-md"
			/>
		</div>

		<div class="mb-4">
			<label for="website" class="block mb-2"> URL </label>
			<input
				id="url"
				name="url"
				type="text"
				class="placeholder-gray-300 focus:ring-primary focus:border-primary block w-full sm:text-sm border-gray-300 rounded-md"
			/>
		</div>

		<div>
			<Button type="submit" isLoading={$KQL_CreatePostMutation.isFetching}>Submit</Button>
		</div>
	</form>

	{#if errorState}
		<p class="mt-2 text-sm text-red-600">{errorState}</p>
	{/if}
</section>
