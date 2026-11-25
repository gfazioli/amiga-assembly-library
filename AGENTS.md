# Agent instructions

This file provides guidance to coding agents working in this repository.

## Project Overview

Documentation website for the **Amiga Assembly Library** — a Commodore Amiga shared library written in Motorola 68020 assembly language. The site is built with **Next.js 16 + Mantine 9** on our own docs engine (`@next/mdx`, no docs framework) and deployed on Vercel.

The Amiga library itself is not part of this repo — this repo contains only the documentation site. The library docs cover 50+ functions organized into modules: Exec, DOS, Graphics, Libraries, Math, Intuition & GadTools, REI Interface, and C Interface.

### Upstream Template
The docs engine comes from **next-app-mantine-docs-template** at `/Users/giovambattistafazioli/Lavoro/GitHub/Mantine Extensions/next-app-mantine-docs-template`: `lib/docs/`, `lib/mdx/`, `components/docs/`, `components/shell/` (no `DocsFooter`), `components/Link/`, `components/MantineNavBar/`, `components/ColorSchemeControl/`, `app/docs/[[...slug]]/`, `app/not-found.tsx`, `mdx-components.tsx`, `next.config.mjs`, the search and version API routes, `scripts/pagefind-site.mjs`. The site moved here from Nextra (the earlier upstream was next-app-nextra-template) in November 2026.

Site-specific on top of the engine: the 68k highlighter (`lib/mdx/m68k.ts`), Amiga Mode, the home page (`Welcome`, `Content`), the site footer (`MantineFooter`, on docs pages too), `app/sitemap.ts`, the navbar branding, the Nextra-like banner, and the `content/`. Copied engine files were changed only where noted in their comments or here: the docs page sets `description` only when a page has one (Next.js turns an explicit `undefined` into `null`, which dropped the site description), and the template's hard-coded blue became the primary colour (TOC, highlighted code lines) or the Nextra banner's near-black.

## Commands

```bash
yarn dev              # Start Next.js dev server (Turbopack)
yarn build            # Production build + pagefind search index
yarn test             # Full suite: typegen → oxfmt → oxlint → stylelint → typecheck → jest
yarn jest             # Run Jest tests only
yarn jest --watch     # Jest in watch mode
yarn oxlint           # Lint JS/TS (excludes public/_pagefind)
yarn stylelint        # Lint CSS
yarn format:test      # Check formatting with oxfmt
yarn format:write     # Auto-fix formatting with oxfmt
yarn typecheck        # TypeScript type checking (tsc --noEmit)
yarn storybook        # Storybook dev server on port 6006
yarn analyze          # Next.js bundle analyzer
```

## Tech Stack

- **Framework**: Next.js 16 with Turbopack (SVG inline loader configured for <4KB)
- **UI**: Mantine 9 (primary color: orange; monospace: the system stack, with "Topaz a1200" asked for by name in Amiga Mode and the home page's terminal)
- **Docs**: `@next/mdx` with remark-gfm, frontmatter and rehype-slug; Shiki at build time, shown by Mantine's `CodeHighlight`; Pagefind search in Mantine's `Spotlight`
- **Language**: TypeScript 6 (strict mode)
- **Package Manager**: Yarn 4 (nodeLinker: node-modules)
- **Node**: 24.11.0 (see `.nvmrc`)
- **Formatter**: oxfmt (not Prettier) — config in `.oxfmtrc.json`
- **Linters**: oxlint (JS/TS), stylelint (CSS/SCSS)
- **Testing**: Jest 30 + Testing Library (jsdom environment)
- **PostCSS**: postcss-import, postcss-preset-mantine, postcss-simple-vars (Mantine breakpoints)

## Architecture

### Content Layer (`content/`)
MDX files organized by Amiga library module (exec, dos, graphics, libraries, math, intui-gadtools, rei), served under `/docs`. Navigation order and labels come from the `_meta.ts` files, read by `lib/docs/`. Docs components (`Callout`, `Steps`, `Cards`, `Tabs`, `FileTree`) are imported from `@/components/docs` with Nextra's props.

### App Layer (`app/`)
- `layout.tsx` — Root layout: `SiteShell` (header, sidebar, TOC, footer, banner) and `DocsSearch`. CSS import order matters (Mantine core → extension styles → theme overrides). Two pre-paint scripts in `<head>`: the collapsed sidebar and Amiga Mode.
- `page.tsx` — Landing page (Welcome + Content components)
- `docs/[[...slug]]/page.tsx` — Every docs page, prerendered; any other `/docs` path is a 404
- `_meta.tsx` — The header links (Documentation, Community, About, Support)
- `api/search/route.server.ts` — Server-side search using pagefind (builds index from `.next/server/app`, served from `public/_pagefind`)
- `api/version/route.server.ts` — Returns `package.json` version
- `sitemap.ts` — Home plus every page under `content/`

API routes are named `route.server.ts`: the server build lists `server.ts` among the page extensions (see `next.config.mjs`).

### Components (`components/`)
Each component lives in its own directory. Key custom pieces:
- **68k highlighting** (`lib/mdx/m68k.ts`) — Build-time highlighting of the ` ```asm ` blocks (Shiki's `asm` is x86). It emits Shiki's markup with light and dark colours on every token, so the browser runs nothing. Tested in `lib/mdx/m68k.test.ts`.
- **Welcome / AmigaModeToggle** — Landing page and the header keycap; both switch Amiga Mode through `useAmigaMode` (`components/AmigaModeToggle/use-amiga-mode.ts`), and `lib/amiga-mode.ts` holds the key, the attribute and the pre-paint script.
- **MantineFooter** — The site footer with the sponsors wall (`#sponsors`), on every page.

### Configuration (`config/index.ts`)
Central config object with metadata (SEO/OG), the docs layout settings (`docs`), shared links, GitHub API URLs, and pagefind search parameters. Referenced as `@/config`.

### Test Utilities (`test-utils/`)
Custom `render()` wrapper that provides MantineProvider with the project theme. Use this instead of raw Testing Library render.

### Path Alias
`@/*` maps to the project root (configured in `tsconfig.json`).

### Storybook
Stories go in `components/**/*.(stories|story).tsx`. Storybook preview wraps all stories in MantineProvider with theme and color scheme support.

## Important Patterns

- **CSS import order in layout.tsx is critical**: Mantine core styles must come first, then extension styles, then theme overrides. This is marked with `// !! The order of these imports is important !!`.
- **oxfmt, not Prettier**: This project uses `oxfmt` for formatting. The import order is auto-sorted by oxfmt per `.oxfmtrc.json` rules.
- **Pagefind search**: The search index is built post-`next build` and output to `public/_pagefind`. The search API route patches `global.window` and `global.document` for server-side pagefind compatibility.
- **No smart typography**: Nextra turned `--` and straight quotes into typographic ones; this engine shows the text as written. Adding `remark-smartypants` would change the anchors of the headings that contain `--`, which deep links already use.
- **Long code blocks open collapsed**: more than 30 lines (`components/docs/CodeBlock/CodeBlock.tsx`), with Mantine's expand button.
- **Environment variables**: none are required; `ANALYZE=true` runs the bundle analyzer.
