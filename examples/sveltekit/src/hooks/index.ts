import type { RequestEvent } from '@sveltejs/kit/types/internal';
import { sequence } from '@sveltejs/kit/hooks';
import { handleAuthCookie } from './handleAuthCookie';

export const handle = sequence(handleAuthCookie);

export function getSession(event: RequestEvent) {
	// Give all locals to the session
	return event.locals;
}
