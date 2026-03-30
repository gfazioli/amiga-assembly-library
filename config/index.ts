export default {
  /**
   * Nextra metadata configuration
   * @see https://nextra.vercel.app/docs/metadata
   */
  metadata: {
    title: {
      default: 'Amiga Assembly Library',
      template: '%s | Amiga Assembly Library',
    },
    description:
      'Documentation for the Amiga Assembly Library v41.21 — A Motorola 68020 shared library for Commodore Amiga (KickStart 3.0+). Public Domain Software.',
    metadataBase: new URL('https://gfazioli.github.io/amiga-68020-library/'),
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
      // https://github.com/vercel/next.js/discussions/50189#discussioncomment-10826632
      url: './',
      siteName: 'Amiga Assembly Library',
      locale: 'en_US',
      type: 'website',
    },
    other: {
      'msapplication-TileColor': '#fff',
    },
    twitter: {
      site: 'https://gfazioli.github.io/amiga-68020-library/',
    },
    alternates: {
      // https://github.com/vercel/next.js/discussions/50189#discussioncomment-10826632
      canonical: './',
    },
  },
  /**
   * Nextra Layout component configuration
   */
  nextraLayout: {
    sidebar: {
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
