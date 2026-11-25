import config from '@/config';
import { render, screen, userEvent, within } from '@/test-utils';
import type { DocsNode, TopNavEntry } from '@/lib/docs/types';
import { SiteShell } from './SiteShell';

const mockSegment = jest.fn<string | null, []>(() => 'docs');

jest.mock('next/navigation', () => ({
  usePathname: () => '/docs',
  useSelectedLayoutSegment: () => mockSegment(),
  useRouter: () => ({ push: jest.fn() }),
}));

// The placement of the sidebar toggle, switched per test
const sidebarConfig = config.docs.sidebar as { toggle: 'header' | 'sidebar' };

const tree: DocsNode[] = [{ kind: 'page', key: 'index', title: 'Introduction', route: '/docs' }];

// A same-page link, as a site's "Support → Sponsor" pointing at its footer's sponsors section
const nav: TopNavEntry[] = [
  {
    key: 'support',
    title: 'Support',
    items: [{ key: 'sponsor', title: 'Sponsor', href: '#sponsors', newWindow: false }],
  },
];

function renderShell() {
  render(
    <SiteShell
      tree={tree}
      nav={nav}
      docsFooter={<footer>Docs footer</footer>}
      siteFooter={<footer>Site footer</footer>}
    >
      <p>Page</p>
    </SiteShell>
  );
  return document.querySelector<HTMLElement>('.mantine-AppShell-navbar')!;
}

beforeEach(() => {
  mockSegment.mockReturnValue('docs');
  sidebarConfig.toggle = 'header';
  window.localStorage.clear();
});

describe('SiteShell', () => {
  it('opens on a skip link to the main landmark', () => {
    renderShell();
    const focusable = document.querySelectorAll('a[href], button');
    expect(focusable[0]).toHaveAttribute('href', '#main-content');
    expect(document.querySelector('main')).toHaveAttribute('id', 'main-content');
  });

  it('closes the phone navbar when a link in it is followed, even to the same page', async () => {
    const navbar = renderShell();
    expect(navbar).toHaveAttribute('data-mobile-collapsed');

    await userEvent.click(screen.getByRole('button', { name: 'Open navigation' }));
    expect(navbar).not.toHaveAttribute('data-mobile-collapsed');

    // A menu group is a button: it opens in place and keeps the navbar open
    await userEvent.click(within(navbar).getByRole('button', { name: /Support/ }));
    expect(navbar).not.toHaveAttribute('data-mobile-collapsed');

    // `hidden`: jsdom never ends Collapse's transition, so the group stays display: none here
    await userEvent.click(within(navbar).getByRole('link', { name: 'Sponsor', hidden: true }));
    expect(navbar).toHaveAttribute('data-mobile-collapsed');
  });

  it('renders a missing /docs page (the 404) as a page outside the docs', () => {
    // At /docs/missing the router renders the not-found segment, not the docs one
    mockSegment.mockReturnValue('/_not-found');
    const navbar = renderShell();

    expect(navbar).toHaveAttribute('data-desktop-collapsed');
    expect(screen.getByText('Site footer')).toBeInTheDocument();
    expect(screen.queryByText('Docs footer')).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /the sidebar/ })).not.toBeInTheDocument();
  });

  it('keeps the sidebar toggle in the header by default', () => {
    const navbar = renderShell();
    const toggle = screen.getByRole('button', { name: 'Hide the sidebar' });
    expect(navbar).not.toContainElement(toggle);
  });

  it('puts the sidebar toggle at the foot of the sidebar, and back in the header once collapsed', async () => {
    sidebarConfig.toggle = 'sidebar';
    const navbar = renderShell();

    const hide = screen.getByRole('button', { name: 'Hide the sidebar' });
    expect(navbar).toContainElement(hide);

    await userEvent.click(hide);
    expect(navbar).toHaveAttribute('data-desktop-collapsed');
    const show = screen.getByRole('button', { name: 'Show the sidebar' });
    expect(navbar).not.toContainElement(show);
  });
});
