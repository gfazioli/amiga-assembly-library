/**
 * Floppeek, the author's Quick Look app for Amiga disk images, announced on this site: the
 * section at the foot of the home page, the requester that points to it, and the banner on the
 * docs pages. A new announcement is a new version here: the storage key follows, so the
 * readers who dismissed the last one see the next.
 */
export const FLOPPEEK_VERSION = '0.1.0';
export const FLOPPEEK_URL = 'https://gfazioli.github.io/floppeek/';
export const FLOPPEEK_BREW = 'brew install --cask gfazioli/tap/floppeek';

/** The banner's key: leaving the requester or the banner leaves both. */
export const FLOPPEEK_BANNER_KEY = `floppeek-${FLOPPEEK_VERSION}`;
/** What `Banner` stores it under (`banner:` + its storage key), read by the requester. */
export const FLOPPEEK_STORAGE_KEY = `banner:${FLOPPEEK_BANNER_KEY}`;

/** The section's anchor: the requester's "Show me" goes there. */
export const FLOPPEEK_SECTION_ID = 'floppeek';

export interface ListingRow {
  /** Directories, the summary and the totals are orange in Floppeek's preview */
  orange: boolean;
  /** Name (18 characters), size (right-aligned in 6), a space, the protection bits */
  text: string;
  date?: string;
  time?: string;
}

/**
 * Floppeek's preview of Work Disk.adf, the demo disk its own site shows
 * (docs/screenshots/preview-work-disk.png there), row by row, character for character.
 */
export const WORK_DISK_ROWS: ListingRow[] = [
  { orange: true, text: '880K · FFS · DD · 132 of 1760 blocks used (8%)' },
  { orange: true, text: 'C                    Dir ----rwed', date: '12-Mar-91', time: '10:14:00' },
  { orange: false, text: '  Copy              1932 ----rwed', date: '12-Mar-91', time: '10:15:04' },
  { orange: false, text: '  Dir               1260 ----rwed', date: '12-Mar-91', time: '10:15:00' },
  { orange: false, text: '  List              2084 ----rwed', date: '12-Mar-91', time: '10:15:02' },
  { orange: true, text: 'Docs                 Dir ----rwed', date: '24-Dec-93', time: '17:58:00' },
  { orange: false, text: '  ReadMe              68 ----rw--', date: '24-Dec-93', time: '18:00:00' },
  { orange: true, text: 'Libs                 Dir ----rwed', date: '12-Mar-91', time: '10:16:00' },
  { orange: false, text: '  disk.library     21740 ----rwed', date: '12-Mar-91', time: '10:16:30' },
  { orange: false, text: 'ReadMe                68 ----rw--', date: '24-Dec-93', time: '18:00:00' },
  { orange: false, text: ': Read me first' },
  { orange: true, text: 'S                    Dir ----rwed', date: '04-Nov-92', time: '21:39:00' },
  { orange: false, text: '  Startup-Sequence    67 ----rwed', date: '04-Nov-92', time: '21:40:12' },
  { orange: true, text: 'Tools                Dir ----rwed', date: '18-Jul-93', time: '16:00:00' },
  { orange: false, text: '  Calculator        8840 ----rwed', date: '02-Feb-93', time: '09:30:10' },
  { orange: false, text: '  Notepad          19312 ----rwed', date: '18-Jul-93', time: '16:02:44' },
  { orange: false, text: '  : Small text editor' },
  { orange: false, text: '' },
  { orange: true, text: '9 files - 5 directories - 132 blocks used' },
];
