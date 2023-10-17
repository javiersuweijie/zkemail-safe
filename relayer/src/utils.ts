export type Result<T> = [T, null] | [null, Error];
export type MaybeError = Error | null; 
export async function sleep(seconds: number) {
    return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}