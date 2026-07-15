declare module 'lwc' {
    export function createElement(
        name: string,
        options: {
            is: any;
        }
    ): HTMLElement;
}