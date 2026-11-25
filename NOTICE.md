# Notices

## What the licence covers

The MIT licence in [LICENCE](LICENCE) covers the source code of this website. The Amiga library itself is public domain, as the [README](README.md) says.

## Trademarks

Amiga, AmigaOS and Commodore are trademarks of their respective owners, and so is the Amiga checkmark logo on the home page. They appear here only to name the platform the library is written for. This is an independent project, not affiliated with or endorsed by them. Neither the MIT licence nor the library's public-domain status covers these marks.

## Third-party fonts

### Topaz

The site's pixel font (the display type, and everything in Amiga Mode) is **Topaz a600a1200a4000**, served from [`public/fonts/`](public/fonts) as `Topaz_a1200_v1.0.ttf` and as a WOFF2 conversion of it. A short version of this section sits beside the files, in [`public/fonts/README.txt`](public/fonts/README.txt), and the footer of every page credits the author.

**What it is.** A TrueType recreation of Topaz, the Amiga's system font as Kickstart 2.x and later drew it, from the pack *Multi Platform Amiga Fonts* (v1.0, 22 December 2009) by TrueSchool Ascii. The `.ttf` here is the author's file, byte for byte: its git blob, `2f7ec445aecb7f777fbdf25a7939414232765d0c`, is the one of [`ttf/Topaz_a1200_v1.0.ttf`](https://github.com/rewtnull/amigafonts/blob/master/ttf/Topaz_a1200_v1.0.ttf) in the author's repository.

**Who made it.** dMG of TrueSchool and Divine Stylers (Marcus Hoffrén, [`rewtnull`](https://github.com/rewtnull) on GitHub), who vectorized the bitmaps by hand and calculated the metrics ([README](https://github.com/rewtnull/amigafonts/blob/master/README), section 11).

**Copyright**, as the font's own name table states it and the licence asks to keep:

```text
Topaz is Copyright © AmigaInc. Truetype version is Copyright © 2009 by dMG of Trueschool and Divine Stylers.
```

**Licence.** The GNU GPL with the font exception ([GPL-FE](https://www.gnu.org/licenses/gpl-faq.html#FontException)): the README's section 14 releases the fonts under it, and names no version of the GPL. It got there in three steps:

| When | Terms | Source |
| --- | --- | --- |
| 2009 | Creative Commons BY-NC-SA 3.0, with an addition: keep the distribution structure intact, do not rename the fonts, and give full credit to the author when embedding them on a homepage or showing them in public | The font's name table (licence URL and licence description), unchanged since |
| 6 February 2013 | The same, and the GPL-FE as an alternative, so the fonts could be bundled with other software | The README as first committed |
| 17 January 2020 | The GPL-FE alone: "Dropped the CC license in favour of GPL-FE" | Commit [`d429875`](https://github.com/rewtnull/amigafonts/commit/d42987535d94ebbfb51e64fee76f9974c6ae145a) |

The font file was never rebuilt, so its metadata still names the 2009 terms. The author's repository is the later and the explicit statement, and it is the one this site relies on.

**Web embedding** is allowed, and meant: section 10 of the README, *Website embedding*, gives the `@font-face` rule to use, and the font's embedding flags (`OS/2.fsType` 8) permit editable embedding. The font exception is what keeps a page that uses the font out of the GPL; the font files themselves stay under it.

**What this site does about it.** It serves the author's file under its own name, credits him here, beside the files and in the footer, and keeps this notice of the licence with the font. The WOFF2 is a container conversion of the same font, with its name table and outlines as they were, under the same licence. `'Topaz a1200'` in the stylesheet is only the handle the CSS calls the font by; nothing in the files is renamed. This also meets the 2009 addition, for anyone who reads the file's metadata rather than the repository. The non-commercial clause of 2009 no longer binds, the CC licence having been dropped; the site sells nothing in any case, though it does link to sponsorship and donations.

**What is not settled.** The licence is dMG's to give for his TrueType work only. The letterforms are the Amiga's own system font, which he attributes to Amiga Inc., and neither his pack nor this site holds a licence from whoever owns those rights today. Recreations of Topaz have circulated openly for decades, and Debian packages another one, [Topaz Unicode](https://gitlab.com/Screwtapello/topaz-unicode) ([package](https://tracker.debian.org/pkg/fonts-topaz-unicode)), whose author offers it under the ISC licence on the view that bitmap fonts cannot practically be copyrighted. That is a widely shared reading and long tolerance, not a grant. If the font ever has to go, the stylesheet names it in one place (`--aal-font-pixel` and the `@font-face` rule in `theme/global.css`), and the nearest replacement with a clear licence is [Workbench](https://fonts.google.com/specimen/Workbench) by Jens Kutílek ([source](https://github.com/jenskutilek/homecomputer-fonts)), under the SIL Open Font License 1.1.

## Third-party code

This project started from [Mantine's Next.js template](https://github.com/mantinedev/next-app-template), released under the MIT licence. Parts of that template remain in the source, so its notice is reproduced here, as that licence requires:

```text
MIT License

Copyright (c) 2022 Vitaly Rtischev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
