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
          url: '/social.jpeg',
          width: 1200,
          height: 630,
          alt: 'Amiga Assembly Library — Commodore Amiga with Workbench',
        },
      ],
    },
    other: {
      'msapplication-TileColor': '#fff',
    },
    twitter: {
      card: 'summary_large_image',
      site: 'https://amiga-assembly-library.vercel.app/',
      images: ['/social.jpeg'],
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
    },
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
    coffee: 'https://donate.stripe.com/fZu4gy4Tn3b1dgudGx0co00',
  },

  /**
   * GitHub API configuration
   */
  gitHub: {
    repo: 'gfazioli/amiga-assembly-library',
    apiUrl: 'https://api.github.com',
    releasesUrl: 'https://api.github.com/repos/gfazioli/amiga-assembly-library/releases',
  },

  /**
   * Release notes configuration
   */
  releaseNotes: {
    url: 'https://github.com/gfazioli/amiga-assembly-library/releases',
    maxReleases: 10,
  },

  /**
   * Search configuration (for pagefind)
   * @see /app/api/search/route.ts
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
