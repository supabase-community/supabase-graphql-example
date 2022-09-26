import { serialize } from 'cookie';

export async function get() {
	console.log(`bye!`);
	return {
		status: 302,
		headers: {
			'Set-Cookie': serialize('supa_id', '', {
				path: '/',
				expires: new Date(0)
			}),
			Location: '/'
		},
		body: {
			message: 'Successfully logout'
		}
	};
}
