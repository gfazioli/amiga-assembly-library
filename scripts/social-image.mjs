/**
 * Renders public/social.png, the Open Graph and Twitter card (1200 × 630), in the site's look:
 * the night-blue screen, the copper bars, Topaz, and a Workbench window with a real call in the
 * 68k highlighting. Run it after a design change, then optimise the PNG (ImageOptim):
 *
 *   node --no-warnings scripts/social-image.mjs
 *
 * It draws with Satori, the renderer behind next/og, so it needs no browser. The code in the
 * window goes through lib/mdx/m68k.ts, the highlighter the docs use (Node 24 runs its TypeScript
 * as is), so the card cannot drift from the site's colours. Topaz is set only at multiples of
 * 16px, where its pixels stay square.
 */
import { readFile, writeFile } from 'node:fs/promises';
import { createElement as h } from 'react';
import { ImageResponse } from 'next/dist/compiled/@vercel/og/index.node.js';
import { highlightM68k } from '../lib/mdx/m68k.ts';

const ROOT = new URL('..', import.meta.url);
const OUT = new URL('public/social.png', ROOT);

// theme.ts and theme/global.css
const SCREEN = '#060a14';
const SCREEN_TEXT = '#e6e9f2';
const DIMMED = '#9aa5be';
const WIN_INK = '#0a0d14';
const ORANGE = { 3: '#ffbb66', 4: '#ffa53d', 5: '#ff8f1a', 7: '#d16500' };
const COPPER = `linear-gradient(90deg, transparent, ${ORANGE[7]} 14%, ${ORANGE[4]} 38%, #ffe08a 50%, ${ORANGE[4]} 62%, ${ORANGE[7]} 86%, transparent)`;

const CODE = `; RevertMem: "ABCD" -> "CDAB"
move.l  _AssemblyBase,a6
lea     test,a0
lea     4(a0),a1
moveq   #TYPEF_WORD,d0
jsr     _LVORevertMem(a6)`;

const unescape = (text) =>
  text.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');

/** One line of highlightM68k's markup as Satori spans, in the dark scheme's colours. */
function codeLine(html, key) {
  const spans = [];
  const token = /<span style="--shiki-light:[^;]+;--shiki-dark:([^"]+)">([^<]*)<\/span>/g;
  let last = 0;
  for (const match of html.matchAll(token)) {
    if (match.index > last) {
      spans.push({ text: html.slice(last, match.index), color: SCREEN_TEXT });
    }
    spans.push({ text: match[2], color: match[1] });
    last = match.index + match[0].length;
  }
  if (last < html.length) {
    spans.push({ text: html.slice(last), color: SCREEN_TEXT });
  }
  return h(
    'div',
    { key, style: { display: 'flex', whiteSpace: 'pre', height: 40 } },
    spans.map((span, index) =>
      h('span', { key: index, style: { color: span.color } }, unescape(span.text))
    )
  );
}

const lines = highlightM68k(CODE)
  .split('\n')
  .map((line) => line.replace(/^<span class="line">|<\/span>$/g, ''));

/** The Amiga checkmark, as components/AmigaCheckmark draws it. */
const CHECKMARK_PATHS = [
  ['m33.568 16h-5l4.216-6h5zm6 0h-5l4.216-6h5z', '#f36c00'],
  ['m29.351 22h-5l4.217-6h5zm6 0h-5l4.217-6h5z', '#ff9000'],
  ['m25.135 28h-5l4.216-6h5zm6 0h-5l4.216-6h5z', '#ffa100'],
  ['m12.143 36 2.857 4-4 1-3.667-5zm6 0 2.857 4-4 1-3.667-5z', '#237f2d'],
  ['m18.143 36h-4.81l-3.666-5h4.904z', '#008390'],
  ['m20.919 34h-5l4.216-6h5zm6 0h-5l4.216-6h5z', '#fdc200'],
  ['m16 41h-5l4.919-7h5zm6 0h-5l4.919-7h5z', '#feda0f'],
  ['m37.784 10h-5l4.216-6h5zm6 0h-5l4.216-6h5z', '#dc4100'],
  ['m12.143 36h-4.81l-3.666-5h4.904z', '#008390'],
  ['m8.571 31h-4.904l-3.667-5h5zm6 0h-4.904l-3.667-5h5z', '#0075c0'],
];

const checkmark = h(
  'svg',
  { width: 44, height: 44, viewBox: '0 0 48 48' },
  CHECKMARK_PATHS.map(([d, fill], index) => h('path', { key: index, d, fill }))
);

const copperBar = (position) =>
  h('div', {
    style: { position: 'absolute', left: 0, right: 0, [position]: 0, height: 4, backgroundImage: COPPER },
  });

const codeWindow = h(
  'div',
  {
    style: {
      display: 'flex',
      flexDirection: 'column',
      width: 560,
      border: `4px solid ${WIN_INK}`,
      backgroundColor: SCREEN,
      boxShadow: `0 0 0 2px #36425f, 12px 12px 0 ${WIN_INK}`,
    },
  },
  // The title bar: an orange strip with the file's name, like a Workbench drawer's
  h(
    'div',
    {
      style: {
        display: 'flex',
        alignItems: 'center',
        height: 48,
        padding: '0 16px',
        backgroundColor: ORANGE[5],
        color: WIN_INK,
        fontSize: 32,
        borderBottom: `4px solid ${WIN_INK}`,
      },
    },
    'RevertMem.asm'
  ),
  h(
    'div',
    { style: { display: 'flex', flexDirection: 'column', padding: '24px 24px', fontSize: 32 } },
    lines.map((line, index) => codeLine(line, index))
  )
);

const card = h(
  'div',
  {
    style: {
      position: 'relative',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      width: '100%',
      height: '100%',
      padding: '0 64px',
      backgroundColor: SCREEN,
      backgroundImage: 'radial-gradient(circle at 20% 0%, #131a2d 0%, transparent 60%)',
      color: SCREEN_TEXT,
      fontFamily: 'Topaz',
    },
  },
  copperBar('top'),
  h(
    'div',
    { style: { display: 'flex', flexDirection: 'column', width: 480 } },
    h(
      'div',
      { style: { display: 'flex', alignItems: 'center', gap: 12, fontSize: 32 } },
      checkmark,
      'AMIGA'
    ),
    h(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          marginTop: 16,
          fontSize: 96,
          lineHeight: 1,
          color: ORANGE[4],
        },
      },
      h('span', null, 'Assembly'),
      h('span', null, 'Library')
    ),
    h(
      'div',
      { style: { display: 'flex', flexDirection: 'column', marginTop: 32, fontSize: 32, lineHeight: 1.25 } },
      h('span', null, 'Motorola 68020 shared'),
      h('span', null, 'library for Commodore Amiga')
    ),
    h(
      'div',
      { style: { display: 'flex', marginTop: 32, fontSize: 32, color: ORANGE[3] } },
      'v41.21 - Public Domain'
    ),
    h(
      'div',
      { style: { display: 'flex', marginTop: 48, fontSize: 16, color: DIMMED } },
      'amiga-assembly-library.vercel.app'
    )
  ),
  codeWindow,
  copperBar('bottom')
);

const topaz = await readFile(new URL('public/fonts/Topaz_a1200_v1.0.ttf', ROOT));
const image = new ImageResponse(card, {
  width: 1200,
  height: 630,
  fonts: [{ name: 'Topaz', data: topaz, weight: 400, style: 'normal' }],
});
await writeFile(OUT, Buffer.from(await image.arrayBuffer()));
console.log(`wrote ${OUT.pathname}`);
