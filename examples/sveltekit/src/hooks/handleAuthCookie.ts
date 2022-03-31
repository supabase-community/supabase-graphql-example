import { kitQLClient } from '$lib/graphql/kitQLClient';
import type { RequestEvent } from '@sveltejs/kit/types/internal';
import { parse } from 'cookie';
import * as jwt from 'jsonwebtoken';

export async function handleAuthCookie({ event, resolve }: { event: RequestEvent; resolve: any }) {
	const cookies = parse(event.request.headers.get('cookie') || '');
	if (cookies.supa_id) {
		var userInfo: any = jwt.verify(cookies.supa_id, 'HELLO_YOU');

		event.locals = {
			user: userInfo.user,
			access_token: userInfo.access_token
		};
	} else {
		event.locals = { user: null };
	}

	const response = await resolve(event);

	return response;
}
