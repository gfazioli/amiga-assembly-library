# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Documentation website for the **Amiga Assembly Library** — a Commodore Amiga shared library written in Motorola 68020 assembly language. The site is built with **Next.js 16 + Mantine 9 + Nextra 4** and deployed on Vercel.

The Amiga library itself is not part of this repo — this repo contains only the documentation site. The library docs cover 50+ functions organized into modules: Exec, DOS, Graphics, Libraries, Math, Intuition & GadTools, REI Interface, and C Interface.

### Upstream Template
This site is built from the **next-app-nextra-template** at `/Users/giovambattistafazioli/Lavoro/GitHub/Mantine Extensions/next-app-nextra-template`. The template provides the base infrastructure (Next.js + Mantine + Nextra integration, tooling, API routes, theme system, Storybook setup). Project-specific additions on top of the template include the M68kHighlighter, Amiga Mode toggle, content in `content/`, and custom branding/config.

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
- **UI**: Mantine 9 (primary color: orange, monospace font: "Topaz a1200")
- **Docs**: Nextra 4 — content directory mapped to `/docs` route
- **Language**: TypeScript 6 (strict mode)
- **Package Manager**: Yarn 4 (nodeLinker: node-modules)
- **Node**: 24.11.0 (see `.nvmrc`)
- **Formatter**: oxfmt (not Prettier) — config in `.oxfmtrc.json`
- **Linters**: oxlint (JS/TS), stylelint (CSS/SCSS)
- **Testing**: Jest 30 + Testing Library (jsdom environment)
- **PostCSS**: postcss-import, postcss-preset-mantine, postcss-simple-vars (Mantine breakpoints)

## Architecture

### Content Layer (`content/`)
MDX files organized by Amiga library module (exec, dos, graphics, libraries, math, intui-gadtools, rei). Navigation structure defined via `_meta.ts` files. Nextra processes this directory and serves it under `/docs`.

### App Layer (`app/`)
- `layout.tsx` — Root layout: MantineProvider wrapping Nextra Layout. CSS import order matters (Mantine core → extension styles → theme overrides).
- `page.tsx` — Landing page (Welcome + Content components)
- `api/search/route.ts` — Server-side search using pagefind (builds index from `.next/server/app`, served from `public/_pagefind`)
- `api/version/route.ts` — Returns `package.json` version

### Components (`components/`)
Each component lives in its own directory. Key custom components:
- **M68kHighlighter** — Client-side enhancer that detects 68k assembly code blocks (post-Shiki) and applies Motorola 68020 syntax coloring (instructions, directives, registers, labels, macros). Uses heuristic scoring to distinguish 68k ASM from C code.
- **Welcome / AmigaModeToggle** — Landing page with retro Amiga mode toggle
- **ColorSchemeControl** — Light/dark theme switcher integrated with Nextra

### Configuration (`config/index.ts`)
Central config object with metadata (SEO/OG), Nextra layout settings, GitHub API URLs, and pagefind search parameters. Referenced as `@/config`.

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
- **Environment variables**: `.env.local` may contain Upstash Redis/Vector and OpenAI keys (see `.env.local.example`).
