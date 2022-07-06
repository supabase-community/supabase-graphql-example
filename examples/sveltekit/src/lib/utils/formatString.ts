export function addS(value: number | null, str: string) {
	return `${value !== null ? value : '?'} ${str}${value > 1 ? 's' : ''}`;
}
