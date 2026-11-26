import bundleAnalyzer from '@next/bundle-analyzer';
import { fileURLToPath } from 'node:url';
import createMDX from '@next/mdx';

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
});

/**
 * The docs engine: plain `@next/mdx`, the MDX loader Next.js itself maintains.
 *
 * Turbopack runs in Rust and cannot receive JavaScript functions, so every remark and rehype
 * plugin is named by a string (a package, or a path to a local module) with serializable options.
 *
 * - `remark-gfm`: tables, task lists, strikethrough, autolinks, as GitHub renders them.
 * - `remark-frontmatter` + `remark-mdx-frontmatter`: the YAML front matter of a page becomes its
 *   `frontmatter` export (`title`, `description`, …).
 * - `remark-heading-ids`: every heading's `id`, from the text as written, before smartypants
 *   changes it (`--` becomes an em dash there, and the anchor would follow).
 * - `remark-smartypants`: curly quotes, dashes and real ellipses in the text, as Nextra set them
 *   (code is left alone).
 * - `remark-static-images`: a relative image, `![](./photo.png)`, becomes an import of the file.
 * - `rehype-slug`: an `id` on every heading, for the table of contents and for deep links.
 * - `rehype-code-meta`: keeps the fence meta (`filename="…" copy {4}`) on the `<pre>`, where the
 *   code block reads it. MDX drops it otherwise. A local plugin is given by its absolute path:
 *   `@next/mdx` resolves plugin names from its own folder, where a relative path finds nothing.
 */
const withMDX = createMDX({
  extension: /\.mdx$/,
  options: {
    remarkPlugins: [
      'remark-gfm',
      fileURLToPath(new URL('./lib/mdx/remark-heading-ids.mjs', import.meta.url)),
      'remark-smartypants',
      fileURLToPath(new URL('./lib/mdx/remark-static-images.mjs', import.meta.url)),
      'remark-frontmatter',
      ['remark-mdx-frontmatter', { name: 'frontmatter' }],
    ],
    rehypePlugins: [
      'rehype-slug',
      fileURLToPath(new URL('./lib/mdx/rehype-code-meta.mjs', import.meta.url)),
    ],
  },
});

/**
 * Two deploy modes:
 * - default: a server build (Vercel, any Node host), with the API routes;
 * - NEXT_PUBLIC_STATIC_EXPORT=1: a fully static export (GitHub Pages), with an optional base path
 *   in NEXT_PUBLIC_BASE_PATH (for example "/next-app-mantine-docs-template").
 *
 * The API routes are named `route.server.ts`. A server build lists `server.ts` among the page
 * extensions, so they are routes; a static export does not, so Next.js sees `route.server` with
 * the `ts` extension, which is no route at all, and leaves them out of the export.
 */
const isStaticExport = process.env.NEXT_PUBLIC_STATIC_EXPORT === '1';
const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? '';

export default withMDX(
  withBundleAnalyzer({
    ...(isStaticExport
      ? {
          output: 'export',
          basePath,
          trailingSlash: true,
          images: { unoptimized: true },
        }
      : {}),
    pageExtensions: isStaticExport ? ['tsx', 'ts'] : ['tsx', 'ts', 'server.ts'],
    reactStrictMode: false,
    cleanDistDir: true,
    agentRules: false, // <-- Don't let `next dev` append its block to CLAUDE.md (since Next.js v16.3)
    experimental: {
      optimizePackageImports: ['@mantine/core', '@mantine/hooks'],
    },
    turbopack: {
      rules: {
        '*.svg': {
          loaders: ['turbopack-inline-svg-loader'],
          condition: {
            content: /^[\s\S]{0,4000}$/, // <-- Inline SVGs smaller than ~4Kb (since Next.js v16)
          },
          as: '*.js',
        },
      },
    },
  })
);
