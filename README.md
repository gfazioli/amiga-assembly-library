# Amiga Assembly Library

<div align="center">

  ![Version](https://img.shields.io/badge/version-41.21-fd7e14?style=for-the-badge)
  ![Platform](https://img.shields.io/badge/platform-Amiga-blue?style=for-the-badge)
  ![CPU](https://img.shields.io/badge/CPU-Motorola%2068020-green?style=for-the-badge)
  ![License](https://img.shields.io/badge/license-Public%20Domain-gray?style=for-the-badge)

---

[<kbd> <br/> If this project has been useful to you, please consider becoming a sponsor <br/> </kbd>](https://github.com/sponsors/gfazioli?o=esc)

</div>

## Overview

A shared library for **Commodore Amiga** written in **Motorola 68020 assembly language**. It provides 50+ high-level functions organized into specialized modules, callable from both Assembly and C programs. Compatible with **KickStart 3.0+** (AmigaOS V39 and above).

> [!note]
>
> [Documentation](https://gfazioli.github.io/amiga-assembly-library/) | [Download (ZIP)](/download.zip)

## Features

- Written in optimized 680x0 assembly (68020+)
- Public Domain Software — free to use and distribute
- Dual API: call from Assembly or C with full type safety
- Auto-opens 12+ system libraries via `AssemblyBase`
- Comprehensive documentation with original source code

## Modules

| Module | Description |
|--------|-------------|
| **Exec** | Memory management, linked lists, node operations (`AllocNewList`, `ReAllocVec`, `FreeList`...) |
| **DOS** | File I/O, disk info, checksums (`Load`, `Save`, `FileInfo`, `CheckFile`...) |
| **Graphics** | BitPlanes, RastPort, drawing, formatted text (`AddBitPlanes`, `AllocRastPort`, `DrawBox`...) |
| **Libraries** | String processing, IFF/AIFF support (`ChangeChar`, `FilterChars`, `UnPackerILBM`...) |
| **Math** | Decimal, hexadecimal, binary conversions (`StringDecToValue`, `ValueToStringHex`...) |
| **Intuition & GadTools** | UI gadgets, custom requesters (`AllocAsmRequest`, `FindAsmGadget`...) |
| **REI Interface** | Custom windowing system with event-driven messaging (`OpenREI`, `WaitREIMsg`...) |
| **C Interface** | Full C prototypes and SAS/C pragma declarations |

## System Requirements

- **CPU**: Motorola 68020 or higher (68030, 68040, 68060)
- **OS**: AmigaOS with KickStart 3.0 (V39) or later
- **Assembler**: HiSoft DevPac or compatible 68k assembler
- **C Compiler** (optional): SAS/C, DICE, or compatible Amiga C compiler

## Installation

1. Copy `assembly.library` to `LIBS:`
2. Copy include files to your include path
3. See the [Getting Started](https://gfazioli.github.io/amiga-assembly-library/docs/getting-started) guide for details

## Quick Example (C)

```c
#include <assembly/assemblybase.h>
#include <clib/assembly_protos.h>

struct AssemblyBase *AssemblyBase;

void main(int argc, char **argv)
{
    if (AssemblyBase = (struct AssemblyBase *)OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM))
    {
        /* All sub-libraries are now available:
         * AssemblyBase->ab_DosBase
         * AssemblyBase->ab_IntuiBase
         * AssemblyBase->ab_GfxBase
         * etc.
         */

        CloseLibrary((struct Library *)AssemblyBase);
    }
}
```

## Documentation Site

The documentation site is built with [Next.js](https://nextjs.org/) + [Mantine](https://mantine.dev/) + [Nextra](https://nextra.site/) and features:

- Complete API reference for all 50+ functions
- Original 68020 assembly source code with syntax highlighting
- C prototypes and include file reference
- Example programs with full source code

### Development

```sh
cd amiga-assembly-library
yarn install
yarn dev
```

| Command | Purpose |
|---------|---------|
| `yarn dev` | Start Next.js dev server |
| `yarn build` | Production build |
| `yarn test` | Full suite: typegen, prettier, lint, typecheck, jest |

## Sponsor

<div align="center">

[<kbd> <br/> If this project has been useful to you, please consider becoming a sponsor <br/> </kbd>](https://github.com/sponsors/gfazioli?o=esc)

</div>

Your support helps me:

- Keep the project actively maintained with timely bug fixes and updates
- Improve the documentation and add new content
- Expand test coverage and ensure long-term sustainability
- Prioritize community requests and feature additions

Open source thrives when those who benefit can give back — even a small monthly contribution makes a real difference.

[Become a sponsor](https://github.com/sponsors/gfazioli?o=esc) today and help me keep this project reliable, up-to-date, and growing for everyone.

---

[![Star History Chart](https://api.star-history.com/svg?repos=gfazioli/amiga-assembly-library&type=Timeline)](https://www.star-history.com/#gfazioli/amiga-assembly-library&Timeline)
