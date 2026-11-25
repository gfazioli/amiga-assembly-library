import { highlightM68k } from '@/lib/mdx/m68k';
import { render, screen } from '@/test-utils';
import { Welcome } from './Welcome';

describe('Welcome component', () => {
  beforeEach(() => {
    render(
      <Welcome
        codeHtml={highlightM68k('    jsr     _LVORevertMem(a6)')}
        functionCount={60}
        moduleCount={7}
      />
    );
  });

  it('names the library in the one h1', () => {
    expect(screen.getAllByRole('heading', { level: 1 })).toHaveLength(1);
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('Amiga Assembly Library');
  });

  it('says what the library is, with the count it was given', () => {
    expect(screen.getByText(/Motorola 68020 assembly language/)).toHaveTextContent(
      'It adds 60 functions'
    );
  });

  it('links to the docs, the archive and the repository', () => {
    expect(screen.getByRole('link', { name: 'Get Started' })).toHaveAttribute(
      'href',
      '/docs/getting-started'
    );
    expect(screen.getByRole('link', { name: 'Download' })).toHaveAttribute('href', '/download.zip');
    expect(screen.getByRole('link', { name: 'GitHub' })).toHaveAttribute(
      'href',
      'https://github.com/gfazioli/amiga-assembly-library'
    );
  });

  it('shows the highlighted code and the Amiga Mode switch', () => {
    expect(screen.getByText('_LVORevertMem')).toBeInTheDocument();
    expect(screen.getByRole('switch', { name: /Amiga Mode/ })).not.toBeChecked();
  });
});
