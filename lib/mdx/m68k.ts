/**
 * Motorola 68020 assembly highlighting, at build time, for the `asm` code blocks.
 *
 * Shiki has no 68k grammar (its `asm` is x86), so `highlightCode` hands these blocks here. The
 * tokenizer and its word lists are the ones the Nextra site ran in the browser after the page
 * loaded (components/M68kHighlighter), with one fix noted in `colorLine`. The output now has
 * Shiki's shape, one `<span class="line">` per line and `--shiki-light` / `--shiki-dark` on every
 * token, so the code block's CSS picks the colour for the scheme and the browser runs nothing.
 */

const INSTRUCTIONS = new Set([
  'move',
  'movea',
  'moveq',
  'movem',
  'movep',
  'lea',
  'pea',
  'clr',
  'exg',
  'swap',
  'ext',
  'extb',
  'link',
  'unlk',
  'add',
  'adda',
  'addi',
  'addq',
  'addx',
  'sub',
  'suba',
  'subi',
  'subq',
  'subx',
  'neg',
  'negx',
  'mulu',
  'muls',
  'divu',
  'divs',
  'divsl',
  'divul',
  'and',
  'andi',
  'or',
  'ori',
  'eor',
  'eori',
  'not',
  'lsl',
  'lsr',
  'asl',
  'asr',
  'rol',
  'ror',
  'roxl',
  'roxr',
  'btst',
  'bset',
  'bclr',
  'bchg',
  'tst',
  'cmp',
  'cmpa',
  'cmpi',
  'cmpm',
  'bra',
  'bsr',
  'bcc',
  'bcs',
  'beq',
  'bne',
  'bgt',
  'bge',
  'blt',
  'ble',
  'bhi',
  'bls',
  'bpl',
  'bmi',
  'bvc',
  'bvs',
  'dbf',
  'dbra',
  'dbcc',
  'dbcs',
  'dbeq',
  'dbne',
  'dbgt',
  'dbge',
  'dblt',
  'dble',
  'dbhi',
  'dbls',
  'dbpl',
  'dbmi',
  'dbvc',
  'dbvs',
  'jmp',
  'jsr',
  'rts',
  'rte',
  'rtr',
  'nop',
  'trap',
  'trapv',
  'reset',
  'stop',
  'chk',
  'chk2',
  'tas',
  'scc',
  'scs',
  'seq',
  'sne',
  'sgt',
  'sge',
  'slt',
  'sle',
  'shi',
  'sls',
  'spl',
  'smi',
  'svc',
  'svs',
  'sf',
  'st',
  'pack',
  'unpk',
  'cas',
  'cas2',
  'cmp2',
  'movec',
  'moves',
  'rtd',
  'bfchg',
  'bfclr',
  'bfexts',
  'bfextu',
  'bfffo',
  'bfins',
  'bfset',
  'bftst',
]);

const DIRECTIVES = new Set([
  'section',
  'end',
  'include',
  'incdir',
  'incbin',
  'output',
  'opt',
  'cnop',
  'even',
  'align',
  'org',
  'offset',
  'set',
  'equ',
  'equr',
  'reg',
  'xdef',
  'xref',
  'public',
  'extern',
  'macro',
  'endm',
  'rept',
  'endr',
  'ifc',
  'ifnc',
  'ifd',
  'ifnd',
  'ifeq',
  'ifne',
  'ifgt',
  'ifge',
  'iflt',
  'ifle',
  'endc',
  'elseif',
  'fail',
  'far',
  'near',
  'code',
  'data',
  'bss',
  'dc',
  'ds',
  'dcb',
  'blk',
]);

const REGISTER_RE = /^(d[0-7]|a[0-7]|sp|pc|sr|ccr|usp|vbr|sfc|dfc)$/i;

/**
 * Token colours as [light, dark]. Dark is the Nextra site's palette (GitHub dark); light is its
 * GitHub light counterpart, which the browser enhancer never had (it drew the dark colours on the
 * light scheme too).
 */
const COLORS = {
  instruction: ['#d73a49', '#f97583'],
  directive: ['#6f42c1', '#b392f0'],
  register: ['#005cc5', '#79b8ff'],
  comment: ['#6a737d', '#6a737d'],
  string: ['#032f62', '#9ecbff'],
  number: ['#005cc5', '#79b8ff'],
  macro: ['#b08800', '#e3b341'],
} as const;

/** The fence languages that mean 68k assembly here. */
export const M68K_LANGUAGES = new Set(['asm', 'm68k']);

function esc(t: string) {
  return t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function token(kind: keyof typeof COLORS, text: string) {
  const [light, dark] = COLORS[kind];
  return `<span style="--shiki-light:${light};--shiki-dark:${dark}">${esc(text)}</span>`;
}

function colorLine(text: string): string {
  // Full-line comment with * or ;
  if (/^[*;]/.test(text)) {
    return token('comment', text);
  }

  // Detect inline comment position
  let commentStart = -1;
  let inStr = false;
  let strCh = '';

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (inStr) {
      if (ch === strCh) {
        inStr = false;
      }
      continue;
    }
    if (ch === '"' || ch === "'") {
      inStr = true;
      strCh = ch;
      continue;
    }
    if (ch === ';') {
      commentStart = i;
      break;
    }
    if (ch === '*' && i > 0 && /\s/.test(text[i - 1]) && /\S/.test(text.slice(0, i))) {
      commentStart = i;
      break;
    }
  }

  const codePart = commentStart >= 0 ? text.slice(0, commentStart) : text;
  const commentPart = commentStart >= 0 ? text.slice(commentStart) : '';

  // Operand punctuation is a token of its own, so what follows it is read too: the browser
  // enhancer's catch-all `\S+` swallowed `,d0`, `(a0)` and `-4(a5)` whole, and left every
  // register after a comma or inside an address mode uncoloured.
  let result = codePart.replace(
    /("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|\$[0-9a-fA-F]+|#-?\$?[0-9a-fA-F]+|\b[a-zA-Z_][a-zA-Z0-9_]*(?:\.[bwlsBWLS])?\b|[,()+-]|[^\s,()+-]+|\s+)/g,
    (tok) => {
      if (/^["']/.test(tok)) {
        return token('string', tok);
      }
      if (/^\$[0-9a-fA-F]+$/.test(tok)) {
        return token('number', tok);
      }
      if (tok.startsWith('#')) {
        return token('number', tok);
      }

      if (/^[a-zA-Z_]/.test(tok)) {
        const base = tok.replace(/\.[bwlsBWLS]$/, '').toLowerCase();

        if (INSTRUCTIONS.has(base)) {
          return token('instruction', tok);
        }
        if (DIRECTIVES.has(base)) {
          return token('directive', tok);
        }
        if (REGISTER_RE.test(tok)) {
          return token('register', tok);
        }

        if (
          /^(CALLEXEC|CALLLIB|CALLGRAF|CALLINTUI|CALLDOS)$/i.test(tok) ||
          /^_LVO/i.test(tok) ||
          /^(MEMF_|RTF_|RTC_|NT_|LH_|MODE_|ASYSI_|REIT_|AREQ_|AGAT_|ASSEMBLYNAME|ASSEMBLY_VERSION|ASSEMBLY_MINIMUM)/i.test(
            tok
          )
        ) {
          return token('macro', tok);
        }
      }
      return esc(tok);
    }
  );

  if (commentPart) {
    result += token('comment', commentPart);
  }

  return result;
}

/** The inner HTML of the `<code>` element for this 68k code, in Shiki's line structure. */
export function highlightM68k(code: string): string {
  return code
    .split('\n')
    .map((line) => `<span class="line">${colorLine(line)}</span>`)
    .join('\n');
}
