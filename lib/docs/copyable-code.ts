/** SGR sequences (colours, bold): what an `ansi` block holds besides the text a reader copies. */
// oxlint-disable-next-line no-control-regex
const ANSI_SGR = /\u001b\[[0-9;]*m/g;

/** The text the copy button puts on the clipboard: an `ansi` block without its escape codes. */
export function copyableCode(code: string, language: string | undefined): string {
  return language === 'ansi' ? code.replace(ANSI_SGR, '') : code;
}
