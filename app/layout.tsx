import '@mantine/core/styles.css';
// !! The order of these imports is important !!
import '@mantine/code-highlight/styles.css';
import '@mantine/spotlight/styles.css';
import '@gfazioli/mantine-text-animate/styles.css';
// Mantine theme overrides (page background, Topaz, Amiga Mode)
import '@/theme/global.css';

import type { Viewport } from 'next';
import { Analytics } from '@vercel/analytics/react';
import { Box, ColorSchemeScript, mantineHtmlProps, MantineProvider } from '@mantine/core';
// !! End of important imports !!

import { MantineFooter } from '@/components/MantineFooter/MantineFooter';
import { Banner } from '@/components/shell/Banner/Banner';
import { DocsSearch } from '@/components/shell/DocsSearch/DocsSearch';
import { SiteShell } from '@/components/shell/SiteShell/SiteShell';
import config from '@/config';
import { AMIGA_MODE_SCRIPT } from '@/lib/amiga-mode';
import { getDocs } from '@/lib/docs/content';
import { SIDEBAR_COLLAPSED_SCRIPT } from '@/lib/docs/sidebar';
import { getTopNav } from '@/lib/docs/top-nav';
import pack from '../package.json';
import { theme } from '../theme';

export const metadata = config.metadata;

// The mobile browser's bar, in the colours the Nextra site gave it.
export const viewport: Viewport = {
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: 'rgb(250,250,250)' },
    { media: '(prefers-color-scheme: dark)', color: 'rgb(17,17,17)' },
  ],
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const { tree } = await getDocs();
  const { head } = config;

  return (
    <html lang="en" dir="ltr" {...mantineHtmlProps}>
      <head>
        <ColorSchemeScript
          nonce={head.mantine.nonce}
          defaultColorScheme={head.mantine.defaultColorScheme}
        />
        <link rel="shortcut icon" href="/favicon.svg" />
        <script dangerouslySetInnerHTML={{ __html: SIDEBAR_COLLAPSED_SCRIPT }} />
        <script dangerouslySetInnerHTML={{ __html: AMIGA_MODE_SCRIPT }} />
      </head>
      <body>
        {/* Off screen until a keyboard reaches it: past the header and the sidebar in one press */}
        <a href="#main-content" className="skip-link">
          Skip to content
        </a>
        <MantineProvider theme={theme} defaultColorScheme={head.mantine.defaultColorScheme}>
          <SiteShell
            tree={tree}
            nav={getTopNav()}
            docsFooter={<MantineFooter />}
            siteFooter={<MantineFooter />}
            banner={
              <Banner storageKey={`amiga-asm-lib-${pack.version}`}>
                {/* One line, cut with an ellipsis: phones get the short form whole */}
                <Box component="span" visibleFrom="md">
                  Amiga Assembly Library v41.21 — Motorola 68020 shared library for Commodore Amiga
                </Box>
                <Box component="span" hiddenFrom="md">
                  Amiga Assembly Library v41.21
                </Box>
              </Banner>
            }
          >
            {children}
          </SiteShell>
          <DocsSearch />
        </MantineProvider>
        <Analytics />
      </body>
    </html>
  );
}
