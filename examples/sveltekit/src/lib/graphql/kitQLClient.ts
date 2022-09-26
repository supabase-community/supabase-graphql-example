import { KitQLClient } from '@kitql/client';

export type AppHeaders = {
	authorization?: `Bearer ${string}`;
	apikey?: string;
};

export const kitQLClient = new KitQLClient<AppHeaders>({
	url: `${import.meta.env.VITE_PUBLIC_SUPABASE_URL}/graphql/v1`,
	credentials: 'omit',
	headersContentType: 'application/json',
	headers: {
		apikey: `${import.meta.env.VITE_PUBLIC_SUPABASE_ANON_KEY}`
	},
	logType: ['server', 'client', 'operationAndvariables']
	// endpointNetworkDelayMs: 2000 // Simulation slow network
});
