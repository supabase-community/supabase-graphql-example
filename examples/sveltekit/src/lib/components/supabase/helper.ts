export async function supaConnect(email: string, password: string) {
	const reqToken = `${import.meta.env.VITE_PUBLIC_SUPABASE_URL}/auth/v1/token?grant_type=password`;
	try {
		const res = await fetch(reqToken, {
			method: 'POST',
			headers: {
				'content-type': 'application/json',
				apikey: `${import.meta.env.VITE_PUBLIC_SUPABASE_ANON_KEY}`
			},
			body: JSON.stringify({ email, password })
		});

		return await res.json();
	} catch (error) {}
	return { error: 'Sorry!' };
}
