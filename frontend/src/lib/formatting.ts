type JsonObject = { [key: string]: any };

function snakeToCamel(s: string): string {
	return s.replace(/(_\w)/g, (m) => m[1].toUpperCase());
}

export function convertKeys(obj: any): any {
	if (Array.isArray(obj)) {
		return obj.map((v) => convertKeys(v));
	} else if (obj !== null && obj.constructor === Object) {
		return Object.keys(obj).reduce((result: JsonObject, key: string) => {
			result[snakeToCamel(key)] = convertKeys(obj[key]);
			return result;
		}, {});
	}
	return obj;
}
