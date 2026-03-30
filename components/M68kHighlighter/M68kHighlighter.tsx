'use client';

import { useEffect } from 'react';

/**
 * Client-side enhancer for Motorola 68020 assembly syntax highlighting.
 * Runs after Shiki renders and applies 68k-specific coloring to code blocks
 * that contain 68k assembly instructions.
 */

const INSTRUCTIONS = new Set([
  'move', 'movea', 'moveq', 'movem', 'movep', 'lea', 'pea', 'clr', 'exg', 'swap',
  'ext', 'extb', 'link', 'unlk',
  'add', 'adda', 'addi', 'addq', 'addx', 'sub', 'suba', 'subi', 'subq', 'subx',
  'neg', 'negx', 'mulu', 'muls', 'divu', 'divs', 'divsl', 'divul',
  'and', 'andi', 'or', 'ori', 'eor', 'eori', 'not',
  'lsl', 'lsr', 'asl', 'asr', 'rol', 'ror', 'roxl', 'roxr',
  'btst', 'bset', 'bclr', 'bchg', 'tst', 'cmp', 'cmpa', 'cmpi', 'cmpm',
  'bra', 'bsr', 'bcc', 'bcs', 'beq', 'bne', 'bgt', 'bge', 'blt', 'ble',
  'bhi', 'bls', 'bpl', 'bmi', 'bvc', 'bvs',
  'dbf', 'dbra', 'dbcc', 'dbcs', 'dbeq', 'dbne', 'dbgt', 'dbge', 'dblt', 'dble',
  'dbhi', 'dbls', 'dbpl', 'dbmi', 'dbvc', 'dbvs',
  'jmp', 'jsr', 'rts', 'rte', 'rtr', 'nop', 'trap', 'trapv', 'reset', 'stop',
  'chk', 'chk2', 'tas',
  'scc', 'scs', 'seq', 'sne', 'sgt', 'sge', 'slt', 'sle', 'shi', 'sls',
  'spl', 'smi', 'svc', 'svs', 'sf', 'st',
  'pack', 'unpk', 'cas', 'cas2', 'cmp2', 'movec', 'moves', 'rtd',
  'bfchg', 'bfclr', 'bfexts', 'bfextu', 'bfffo', 'bfins', 'bfset', 'bftst',
]);

const DIRECTIVES = new Set([
  'section', 'end', 'include', 'incdir', 'incbin', 'output', 'opt', 'cnop',
  'even', 'align', 'org', 'offset', 'set', 'equ', 'equr', 'reg',
  'xdef', 'xref', 'public', 'extern',
  'macro', 'endm', 'rept', 'endr',
  'ifc', 'ifnc', 'ifd', 'ifnd', 'ifeq', 'ifne', 'ifgt', 'ifge', 'iflt', 'ifle',
  'endc', 'elseif', 'fail', 'far', 'near', 'code', 'data', 'bss',
  'dc', 'ds', 'dcb', 'blk',
]);

const REGISTER_RE = /^(d[0-7]|a[0-7]|sp|pc|sr|ccr|usp|vbr|sfc|dfc)$/i;

const C = {
  instruction: '#f97583',
  directive: '#b392f0',
  register: '#79b8ff',
  label: '#ffab70',
  comment: '#6a737d',
  string: '#9ecbff',
  number: '#79b8ff',
  macro: '#e3b341',
};

function esc(t: string) {
  return t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function isM68kBlock(text: string): boolean {
  // Detect 68k asm by checking for common patterns
  const lines = text.split('\n').slice(0, 30);
  let score = 0;
  for (const line of lines) {
    if (/\b(move[aqm]?|lea|jsr|rts|bsr|dbf|tst)\.[bwls]?\b/i.test(line)) score++;
    if (/\b[da][0-7]\b/i.test(line)) score++;
    if (/^\*{3,}/.test(line)) score++;
    if (/_LVO\w+/.test(line)) score++;
  }
  return score >= 3;
}

function colorLine(text: string): string {
  // Full-line comment with *
  if (/^\*/.test(text)) {
    return `<span style="color:${C.comment}">${esc(text)}</span>`;
  }

  // Detect inline comment position
  let commentStart = -1;
  let inStr = false;
  let strCh = '';

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (inStr) {
      if (ch === strCh) inStr = false;
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

  let result = codePart.replace(
    /("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|\$[0-9a-fA-F]+|#-?\$?[0-9a-fA-F]+|\b[a-zA-Z_][a-zA-Z0-9_]*(?:\.[bwlsBWLS])?\b|\S+|\s+)/g,
    (tok) => {
      if (/^["']/.test(tok)) return `<span style="color:${C.string}">${esc(tok)}</span>`;
      if (/^\$[0-9a-fA-F]+$/.test(tok)) return `<span style="color:${C.number}">${esc(tok)}</span>`;
      if (/^#/.test(tok)) return `<span style="color:${C.number}">${esc(tok)}</span>`;

      if (/^[a-zA-Z_]/.test(tok)) {
        const base = tok.replace(/\.[bwlsBWLS]$/, '').toLowerCase();

        if (INSTRUCTIONS.has(base)) return `<span style="color:${C.instruction}">${esc(tok)}</span>`;
        if (DIRECTIVES.has(base)) return `<span style="color:${C.directive}">${esc(tok)}</span>`;
        if (REGISTER_RE.test(tok)) return `<span style="color:${C.register}">${esc(tok)}</span>`;

        if (/^(CALLEXEC|CALLLIB|CALLGRAF|CALLINTUI|CALLDOS)$/i.test(tok) ||
            /^_LVO/i.test(tok) ||
            /^(MEMF_|RTF_|RTC_|NT_|LH_|MODE_|ASYSI_|REIT_|AREQ_|AGAT_|ASSEMBLYNAME|ASSEMBLY_VERSION|ASSEMBLY_MINIMUM)/i.test(tok)) {
          return `<span style="color:${C.macro}">${esc(tok)}</span>`;
        }
      }
      return esc(tok);
    }
  );

  if (commentPart) {
    result += `<span style="color:${C.comment}">${esc(commentPart)}</span>`;
  }

  return result;
}

function processBlock(pre: HTMLElement) {
  const code = pre.querySelector('code.nextra-code');
  if (!code) return;

  const fullText = code.textContent || '';
  if (!isM68kBlock(fullText)) return;

  // Get all line spans (direct children of code)
  const lineSpans = code.querySelectorAll(':scope > span');
  lineSpans.forEach((span) => {
    const text = span.textContent || '';
    if (!text) return;
    span.innerHTML = `<span>${colorLine(text)}</span>`;
  });

  pre.dataset.m68kDone = '1';
}

export function M68kHighlighter() {
  useEffect(() => {
    const process = () => {
      document.querySelectorAll<HTMLElement>('pre:not([data-m68k-done])').forEach(processBlock);
    };

    // Run on mount and after a short delay (for client-side hydration)
    process();
    const timer = setTimeout(process, 500);

    // Also observe DOM changes for navigation
    const observer = new MutationObserver(() => {
      setTimeout(process, 100);
    });
    observer.observe(document.body, { childList: true, subtree: true });

    return () => {
      clearTimeout(timer);
      observer.disconnect();
    };
  }, []);

  return null;
}
