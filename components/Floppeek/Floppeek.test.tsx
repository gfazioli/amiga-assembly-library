import userEvent from '@testing-library/user-event';
import { Banner } from '@/components/shell/Banner/Banner';
import { render, screen } from '@/test-utils';
import {
  FLOPPEEK_BANNER_KEY,
  FLOPPEEK_BREW,
  FLOPPEEK_STORAGE_KEY,
  FLOPPEEK_URL,
  WORK_DISK_ROWS,
} from './floppeek';
import { FloppeekSection } from './FloppeekSection';

describe('Floppeek', () => {
  beforeEach(() => window.localStorage.clear());

  // The requester reads and writes the banner's key itself: if the engine's Banner ever
  // stores it under another name, the two stop silencing each other
  it('writes, on closing the banner, the key the requester reads', async () => {
    render(<Banner storageKey={FLOPPEEK_BANNER_KEY}>New: Floppeek</Banner>);
    await userEvent.click(screen.getByRole('button', { name: 'Dismiss the announcement' }));
    expect(window.localStorage.getItem(FLOPPEEK_STORAGE_KEY)).toBe('true');
  });

  it('serves the section whole: the window open and every row of the listing', () => {
    render(<FloppeekSection />);
    expect(screen.getByRole('heading', { level: 2, name: 'Floppeek' })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /Get Floppeek/ })).toHaveAttribute(
      'href',
      FLOPPEEK_URL
    );
    expect(screen.getByText(FLOPPEEK_BREW)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /Space/ })).toHaveAttribute('aria-expanded', 'true');
    const stage = document.querySelector('figure[data-state]');
    expect(stage).toHaveAttribute('data-state', 'open');
    expect(stage?.querySelectorAll('[style*="--i"]').length).toBe(WORK_DISK_ROWS.length + 6);
  });
});
