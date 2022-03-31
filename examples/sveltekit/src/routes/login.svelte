<script lang="ts">
	import { page } from '$app/stores';
	import Icons from '$lib/components/layout/Icons.svelte';
	import Button from '$lib/components/supabase/ui/Button.svelte';

	let isLoading = false;
	let errorMessage = '';

	async function submit(e) {
		isLoading = true;
		const formData: any = new FormData(e.target);
		const jsonData = Object.fromEntries(formData.entries());
		let result = await fetch('/api/login', {
			method: 'POST',
			body: JSON.stringify({
				email: jsonData.email,
				password: jsonData.password
			})
		});
		const resultData = await result.json();

		if (resultData.error) {
			errorMessage = resultData.error_description;
		} else {
			const from = $page.url.searchParams.get('from') || '/';
			window.location.replace(from);
		}
		isLoading = false;
	}
</script>

<svelte:head>
	<title>supanews | Login</title>
</svelte:head>

<div class="m-width-md mx-auto">
	<h1 class="font-semibold text-xl tracking-tight mb-5">Login</h1>

	<form class="flex flex-col gap-5" on:submit|preventDefault={submit}>
		<div>
			<label for="email" class="block text-sm font-medium text-gray-700">Email</label>
			<div class="mt-1 relative rounded-md shadow-sm">
				<div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
					<Icons name="MailIcon" class="h-5 w-5 text-gray-400" />
				</div>
				<input
					type="email"
					name="email"
					id="email"
					class="placeholder-gray-300 focus:ring-primary focus:border-primary block w-full pl-10 sm:text-sm border-gray-300 rounded-md"
					placeholder="you@example.com"
				/>
			</div>
		</div>

		<div>
			<label for="password" class="block text-sm font-medium text-gray-700">Password</label>
			<div class="mt-1 relative rounded-md shadow-sm">
				<div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
					<Icons name="PasswordIcon" class="h-5 w-5 text-gray-400" />
				</div>
				<input
					type="password"
					name="password"
					id="password"
					class="placeholder-gray-300 focus:ring-primary focus:border-primary block w-full pl-10 sm:text-sm border-gray-300 rounded-md"
					placeholder="***************"
				/>
			</div>
		</div>

		<div>
			<Button type="submit" {isLoading}>Sign in</Button>
		</div>

		{#if errorMessage}
			<p class="mt-2 text-sm text-red-600">{errorMessage}</p>
		{/if}
	</form>
</div>
