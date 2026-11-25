import { highlightM68k } from './m68k';

/** The tokens of one highlighted line, as [text, light colour] pairs. */
function tokens(html: string) {
  return [
    ...html.matchAll(/<span style="--shiki-light:([^;]+);--shiki-dark:[^"]+">([^<]*)<\/span>/g),
  ].map(([, light, text]) => [text, light]);
}

describe('highlightM68k', () => {
  it('gives every line its own .line span, as Shiki does', () => {
    const html = highlightM68k('\tmoveq #0,d0\n\n\trts');
    expect(html.split('\n')).toHaveLength(3);
    expect(html.split('\n')[1]).toBe('<span class="line"></span>');
  });

  it('colours instructions with a size suffix, registers and immediates', () => {
    expect(tokens(highlightM68k('\tmove.l\t#$10,d0'))).toEqual([
      ['move.l', '#cf222e'],
      ['#$10', '#005cc5'],
      ['d0', '#005cc5'],
    ]);
  });

  it('colours the registers after a comma and inside address modes', () => {
    const registers = (line: string) =>
      tokens(highlightM68k(line))
        .filter(([, light]) => light === '#005cc5')
        .map(([text]) => text);

    expect(registers('\tmove.l\td0,a1')).toEqual(['d0', 'a1']);
    expect(registers('\tmove.l\t(a0)+,-(sp)')).toEqual(['a0', 'sp']);
    expect(registers('\tjsr\t_LVOAllocMem(a6)')).toEqual(['a6']);
    expect(registers('\tmove.w\t-4(a5),d1')).toEqual(['a5', 'd1']);
    expect(registers('\tmovem.l\td2-d4/a3-a6,-(sp)')).toEqual(['d2', 'd4', 'a3', 'a6', 'sp']);
    expect(registers('\tjmp\t([a0,d0.w*4])')).toEqual(['a0', 'd0.w']);
  });

  it('reads a symbolic immediate whole, not as a hex number', () => {
    expect(tokens(highlightM68k('\tmove.l\t#fib_SIZEOF,d0'))).toEqual([
      ['move.l', '#cf222e'],
      ['#fib_SIZEOF', '#005cc5'],
      ['d0', '#005cc5'],
    ]);
  });

  it('colours directives, macros and LVO offsets', () => {
    expect(tokens(highlightM68k('\tCALLEXEC _LVOAllocMem'))).toEqual([
      ['CALLEXEC', '#7d5f00'],
      ['_LVOAllocMem', '#7d5f00'],
    ]);
    expect(tokens(highlightM68k('\tXDEF\t_RevertMem'))[0]).toEqual(['XDEF', '#6f42c1']);
  });

  it('keeps a semicolon inside a string out of the comment', () => {
    expect(tokens(highlightM68k("\tdc.b\t'a;b',0\t; text"))).toEqual([
      ['dc.b', '#6f42c1'],
      ["'a;b'", '#032f62'],
      ['; text', '#6a737d'],
    ]);
  });

  it('treats a line starting with * as a comment', () => {
    expect(tokens(highlightM68k('* RevertMem -- free it all'))).toEqual([
      ['* RevertMem -- free it all', '#6a737d'],
    ]);
  });

  it('escapes HTML in the source', () => {
    const html = highlightM68k('\tdc.b\t"<a&b>"');
    expect(html).toContain('&lt;a&amp;b&gt;');
    expect(html).not.toContain('<a&b>');
  });
});
