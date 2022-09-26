const config = {
	content: ['./src/**/*.{html,js,svelte,ts}'],

	theme: {
		extend: {
			colors: {
				primary: '#24B47E'
			}
		}
	},

	plugins: [require('@tailwindcss/forms')]
};

module.exports = config;
