'use client';

import { useSelectedLayoutSegment } from 'next/navigation';
import { DOCS_SEGMENT } from '@/lib/docs/routes';

/**
 * Its children on the docs pages only, decided as SiteShell decides `isDocs`: the home page has
 * Floppeek's own section and requester, and the banner would be a third announcement there.
 * Each route is prerendered with or without it, so the header is sized in the served HTML.
 */
export function DocsOnly({ children }: { children: React.ReactNode }) {
  return useSelectedLayoutSegment() === DOCS_SEGMENT ? children : null;
}
