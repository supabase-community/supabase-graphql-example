<script>
	import Container from '$lib/Container.svelte';
	import Footer from '$lib/Footer.svelte';
	import Loading from '$lib/Loading.svelte';
	import MainSection from '$lib/MainSection.svelte';
	import Navigation from '$lib/Navigation.svelte';
	import '../app.css';
</script>

<svelte:head>
	<title>supanews</title>
</svelte:head>

<Navigation />
<MainSection>
	<slot />
</MainSection>
<Footer />
