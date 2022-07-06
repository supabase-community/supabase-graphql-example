<script context="module" lang="ts">
	import Loading from '$lib/components/layout/Loading.svelte';
	import Button from '$lib/components/supabase/ui/Button.svelte';
	import { KQL_ProfileRouteQuery, KQL_UpdateProfile } from '$lib/graphql/_kitql/graphqlStores';

	export async function load({ fetch, url, params, session, stuff }) {
		if (!session.user) {
			return {
				status: 302,
				redirect: '/'
			};
		}

		await KQL_ProfileRouteQuery.queryLoad({ fetch, variables: { profileId: session.user.id } });
		return {};
	}
</script>

<script lang="ts">
	$: profile = $KQL_ProfileRouteQuery.data?.profileCollection?.edges?.[0].node;

	$: errorState = extractExpectedGraphQLErrors($KQL_UpdateProfile.errors);
	function extractExpectedGraphQLErrors(errors: any[]): null | string {
		if (!errors || errors.length === 0) {
			return null;
		}

		for (const error of errors) {
			if (error.includes('usernamelength')) {
				return 'Username must have a minimum length of 3 characters.';
			}
			if (error.includes('Profile_username_key')) {
				return 'The name is already taken.';
			}
		}

		return null;
	}

	async function submit(e) {
		const formData: any = new FormData(e.target);
		const jsonData = Object.fromEntries(formData.entries());
		KQL_UpdateProfile.mutate({
			variables: {
				userId: profile.id,
				newUsername: jsonData.username,
				newWebsite: jsonData.website,
				newBio: jsonData.bio
			}
		});
	}
</script>

<svelte:head>
	<title>supanews | Account</title>
</svelte:head>

{#if profile}
	<section class="container px-5 py-24 mx-auto max-w-md">
		<h1 class="font-semibold text-xl tracking-tight mb-5">Account</h1>

		<form on:submit|preventDefault={submit}>
			<div class="mb-4">
				<label for="username" class="block mb-2"> Name </label>
				<input
					id="username"
					name="username"
					type="text"
					bind:value={profile.username}
					class="placeholder-gray-300 focus:ring-primary focus:border-primary block w-full sm:text-sm border-gray-300 rounded-md"
				/>
			</div>

			<div class="mb-4">
				<label for="website" class="block mb-2"> Website </label>
				<input
					id="website"
					name="website"
					type="text"
					bind:value={profile.website}
					class="placeholder-gray-300 focus:ring-primary focus:border-primary block w-full sm:text-sm border-gray-300 rounded-md"
				/>
			</div>

			<div class="mb-4">
				<label for="bio" class="block mb-2"> Bio </label>
				<textarea
					id="bio"
					name="bio"
					class="placeholder-gray-300 focus:ring-primary focus:border-primary block w-full sm:text-sm border-gray-300 rounded-md"
					bind:value={profile.bio}
				/>
			</div>

			<div>
				<Button type="submit" isLoading={$KQL_UpdateProfile.isFetching}>Update</Button>
			</div>
		</form>

		{#if errorState}
			<p class="mt-2 text-sm text-red-600">{errorState}</p>
		{/if}
	</section>
{:else}
	<Loading />
{/if}
