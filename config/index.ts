export default {
  /**
   * Site metadata, merged into every page's own
   * @see https://nextjs.org/docs/app/api-reference/functions/generate-metadata
   */
  metadata: {
    title: {
      default: 'Amiga Assembly Library',
      template: '%s | Amiga Assembly Library',
    },
    description:
      'Documentation for the Amiga Assembly Library v41.21 — A Motorola 68020 shared library for Commodore Amiga (KickStart 3.0+). Public Domain Software.',
    metadataBase: new URL('https://amiga-assembly-library.vercel.app/'),
    keywords: [
      'Amiga',
      'Assembly',
      'Motorola 68020',
      '68k',
      'Commodore',
      'KickStart 3.0',
      'assembly.library',
      'AmigaOS',
      'retro computing',
      '680x0',
    ],
    generator: 'Next.js',
    applicationName: 'Amiga Assembly Library',
    appleWebApp: {
      title: 'Amiga Assembly Library',
    },
    openGraph: {
      url: './',
      siteName: 'Amiga Assembly Library',
      locale: 'en_US',
      type: 'website',
      images: [
        {
          // Rendered by scripts/social-image.mjs
          url: '/social.png',
          width: 1200,
          height: 630,
          alt: 'Amiga Assembly Library: a Motorola 68020 shared library for Commodore Amiga, with a RevertMem call in a Workbench window',
        },
      ],
    },
    other: {
      'msapplication-TileColor': '#fff',
    },
    twitter: {
      card: 'summary_large_image',
      images: ['/social.png'],
    },
    alternates: {
      // https://github.com/vercel/next.js/discussions/50189#discussioncomment-10826632
      canonical: './',
    },
  },
  /**
   * Docs layout
   */
  docs: {
    /**
     * Base of each page's "Edit this page on GitHub" link: the page's path under `content/` is
     * appended. Empty: the link is hidden, as it was on the Nextra site.
     */
    editUrlBase: '',
    sidebar: {
      /** Folders deeper than this open only when they hold the current page */
      defaultMenuCollapseLevel: 1,
      /**
       * Where the button that hides the sidebar on desktop sits (⌘B / Ctrl+B works either way):
       * `header`, left of the logo, or `sidebar`, at its foot beside the colour scheme, as on the
       * Nextra sites; a collapsed sidebar is then brought back from the header.
       */
      toggle: 'header' as 'header' | 'sidebar',
    },
    /**
     * The colour-scheme switch at the foot of the sidebar. A site drawn for one scheme sets
     * `false` (and forces it on `MantineProvider`): no switch is offered, so no visitor is left
     * on a scheme nothing is drawn for. The header's own controls belong to the site's
     * `MantineNavBar`.
     */
    colorSchemeControl: true as boolean,
  },
  /**
   * Main Layout head configuration
   */
  head: {
    mantine: {
      defaultColorScheme: 'dark',
      nonce: '8IBTHwOdqNKAWeKl7plt8g==',
    },
  },
  /**
   * Links shared by the header, the sidebar and the footer
   */
  links: {
    discord: 'https://discord.gg/rdWu5yFCR6',
    /** The Discord link's tooltip and accessible name, in the header and the sidebar */
    discordLabel: 'Undolog Discord',
    /** The GitHub icon in the header and at the foot of the sidebar: a page every visitor can open */
    github: 'https://github.com/gfazioli/amiga-assembly-library',
    coffee: 'https://donate.stripe.com/fZu4gy4Tn3b1dgudGx0co00',
  },

  /**
   * The GitHub repository, linked from the header and the sidebar
   */
  gitHub: {
    repo: 'gfazioli/amiga-assembly-library',
  },

  /**
   * Search configuration (for pagefind)
   * @see /app/api/search/route.server.ts
   */
  search: {
    queryKeyword: 'q',
    minQueryLength: 3,
    limitKeyword: 'limit',
    defaultMaxResults: 5,
    excerptLengthKeyword: 'excerptLength',
    defaultExcerptLength: 30,
    defaultLanguage: 'en',
  },
} as const;
