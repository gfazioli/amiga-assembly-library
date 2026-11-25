/**
 * Amiga Mode: the whole site in the Topaz font, while `AMIGA_MODE_ATTRIBUTE` is on `<html>`
 * (the CSS rule is in `theme/global.css`). The choice is kept in localStorage under
 * `AMIGA_MODE_KEY`, as the JSON booleans `true` / `false` that Mantine's `useLocalStorage` writes.
 *
 * `AMIGA_MODE_SCRIPT` runs in `<head>` before the first paint and sets the attribute when the
 * stored value is `true`, so a reader in Amiga Mode never sees the modern fonts flash first.
 */
export const AMIGA_MODE_KEY = 'amiga-mode';

export const AMIGA_MODE_ATTRIBUTE = 'data-amiga-mode';

export const AMIGA_MODE_SCRIPT = `try{if(localStorage.getItem(${JSON.stringify(
  AMIGA_MODE_KEY
)})==='true')document.documentElement.setAttribute(${JSON.stringify(
  AMIGA_MODE_ATTRIBUTE
)},'')}catch(e){}`;
