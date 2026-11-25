/**
 * The library's modules as the home page presents them. `href` is the module's docs folder: the
 * page reads the functions of each from `content/` (app/page.tsx). `reference` marks the entry
 * that is a guide rather than a module, which has no function list.
 */
export interface ModuleDefinition {
  /** The short name on the card, in the pixel font */
  code: string;
  title: string;
  description: string;
  href: string;
  reference?: boolean;
}

export const MODULES: ModuleDefinition[] = [
  {
    code: 'EXEC',
    title: 'Exec',
    description: 'Memory blocks, linked lists and their nodes.',
    href: '/docs/exec',
  },
  {
    code: 'DOS',
    title: 'DOS',
    description: 'Loading and saving files, disk information, checksums, line input.',
    href: '/docs/dos',
  },
  {
    code: 'GFX',
    title: 'Graphics',
    description: 'BitPlanes, RastPorts, boxes and frames, formatted text.',
    href: '/docs/graphics',
  },
  {
    code: 'LIBS',
    title: 'Libraries',
    description: 'String processing, character filtering, IFF and AIFF chunks.',
    href: '/docs/libraries',
  },
  {
    code: 'MATH',
    title: 'Math',
    description: 'Decimal, hexadecimal and binary strings to values, and back.',
    href: '/docs/math',
  },
  {
    code: 'GUI',
    title: 'Intuition & GadTools',
    description: 'Requesters, gadgets by name, interface definitions.',
    href: '/docs/intui-gadtools',
  },
  {
    code: 'REI',
    title: 'REI Interface',
    description: 'A windowing system of its own, with event-driven messaging.',
    href: '/docs/rei',
  },
  {
    code: 'C',
    title: 'C Interface',
    description: 'Prototypes and pragmas for calling the library from SAS/C.',
    href: '/docs/c-interface',
    reference: true,
  },
];
