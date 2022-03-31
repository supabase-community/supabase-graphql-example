<script lang="ts">
	import Footer from '$lib/components/layout/Footer.svelte';
	import MainSection from '$lib/components/layout/MainSection.svelte';
	import Navigation from '$lib/components/layout/Navigation.svelte';
	import { KQL__Init } from '$lib/graphql/_kitql/graphqlStores';
	import '../app.css';

	KQL__Init();
</script>

<svelte:head>
	<title>supanews</title>
</svelte:head>

<Navigation />
<MainSection>
	<slot />
</MainSection>
<Footer />
