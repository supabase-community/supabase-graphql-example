<script context="module" lang="ts">
	export async function load({ fetch, url, params, session, stuff }) {
		if (session.user && url.pathname === '/login') {
			return {
				status: 302,
				redirect: '/'
			};
		}

		return {
			props: {
				user: session.user,
				access_token: session.access_token
			}
		};
	}
</script>

<script lang="ts">
	import Footer from '$lib/components/layout/Footer.svelte';
	import MainSection from '$lib/components/layout/MainSection.svelte';
	import Navigation from '$lib/components/layout/Navigation.svelte';
	import { kitQLClient } from '$lib/graphql/kitQLClient';
	import { KQL__Init } from '$lib/graphql/_kitql/graphqlStores';
	import { userStore } from '$lib/utils/userStore';
	import '../app.css';

	export let user;
	export let access_token;

	$userStore = user;

	KQL__Init();
	if (access_token) {
		let headers = kitQLClient.getHeaders();
		headers.authorization = `Bearer ${access_token}`;
		kitQLClient.setHeaders(headers);
	}
</script>

<Navigation />
<MainSection>
	<slot />
</MainSection>
<Footer />
