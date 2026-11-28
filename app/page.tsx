import { Content, type LibraryModule } from '@/components/Content/Content';
import { MODULES } from '@/components/Content/modules';
import { FloppeekRequester } from '@/components/Floppeek/FloppeekRequester';
import { FloppeekSection } from '@/components/Floppeek/FloppeekSection';
import { Welcome } from '@/components/Welcome/Welcome';
import { getDocs } from '@/lib/docs/content';
import type { DocsFolderNode } from '@/lib/docs/types';
import { highlightM68k } from '@/lib/mdx/m68k';

/**
 * The code in the hero's window: the opening sequence of the Getting Started page, then the call
 * of the RevertMem page's example. Both are in the docs word for word, so the home page shows
 * nothing the library does not do.
 */
const HERO_CODE = `; Open assembly.library v41+
    move.l  4.w,a6
    lea     AssemblyName(pc),a1
    moveq   #41,d0
    jsr     _LVOOpenLibrary(a6)
    move.l  d0,_AssemblyBase
    beq     .NoLibrary

; Reverse two words: "ABCD" -> "CDAB"
    move.l  _AssemblyBase,a6
    lea     test,a0
    lea     4(a0),a1
    moveq   #TYPEF_WORD,d0
    jsr     _LVORevertMem(a6)`;

/** The function pages of a module's folder: every page but its overview, in sidebar order. */
function functionNames(folder: DocsFolderNode | undefined): string[] {
  return (folder?.children ?? []).flatMap((node) =>
    node.kind === 'page' && node.route !== folder?.route && typeof node.title === 'string'
      ? [node.title]
      : []
  );
}

export default async function HomePage() {
  // The counts and the names on the home page are read from content/, so they cannot drift from
  // the docs: a new function page shows up here on the next build.
  const { tree } = await getDocs();
  const folders = new Map(
    tree.flatMap((node) => (node.kind === 'folder' ? [[node.route, node] as const] : []))
  );
  const modules: LibraryModule[] = MODULES.map((module) => ({
    ...module,
    functions: module.reference ? [] : functionNames(folders.get(module.href)),
  }));
  const functionCount = modules.reduce((total, module) => total + module.functions.length, 0);
  const moduleCount = modules.filter((module) => !module.reference).length;

  // The <main> landmark comes from the site shell (AppShell.Main), on this page as on the docs.
  // Floppeek, the author's Mac app for Amiga disks, comes last, and its requester right after
  // the hero, so the Tab order reaches it after the hero's controls.
  return (
    <>
      <Welcome
        codeHtml={highlightM68k(HERO_CODE)}
        functionCount={functionCount}
        moduleCount={moduleCount}
      />
      <FloppeekRequester />
      <Content modules={modules} />
      <FloppeekSection />
    </>
  );
}
