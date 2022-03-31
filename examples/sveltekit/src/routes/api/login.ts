import { supaConnect } from '$lib/components/supabase/helper';
import { serialize } from 'cookie';
import * as jwt from 'jsonwebtoken';

export async function post({ request }) {
	const data = await request.json();
	const result = await supaConnect(data.email, data.password);

	if (result.user) {
		var token = jwt.sign(result.user, 'HELLO_YOU');
		return {
			status: result.status,
			headers: {
				'Set-Cookie': serialize('supa_id', token, {
					path: '/',
					httpOnly: true,
					sameSite: 'strict',
					secure: process.env.NODE_ENV === 'production',
					maxAge: result.expires_in
				})
			},
			body: {
				message: 'Successfully login'
			}
		};
	}

	return {
		status: result.status,
		body: result
	};
}
