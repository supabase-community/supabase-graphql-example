import adapter from '@sveltejs/adapter-auto';
import { sveltePreprocessSvg } from '@svitejs/svelte-preprocess-svg';
import autoprefixer from 'autoprefixer';
import preprocess from 'svelte-preprocess';
import tailwindcss from 'tailwindcss';
import Icons from 'unplugin-icons/vite';
import watchAndRun from '@kitql/vite-plugin-watch-and-run';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://github.com/sveltejs/svelte-preprocess
	// for more information about preprocessors
	preprocess: [
		preprocess({
			postcss: {
				plugins: []
			}
		}),
		sveltePreprocessSvg({})
	],

	kit: {
		adapter: adapter(),
		vite: {
			css: {
				postcss: {
					plugins: [
						tailwindcss(),
						autoprefixer // need to run after tailwindcss
					]
				}
			},
			plugins: [
				watchAndRun([
					{
						watch: '**/*.(gql|graphql)',
						run: 'cd ../.. && yarn codegen:sveltekit'
					}
				]),
				Icons({
					compiler: 'svelte',
					scale: 1.2
				})
			]
		}
	}
};

export default config;
