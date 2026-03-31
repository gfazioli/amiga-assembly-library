import { render, screen } from '@/test-utils';
import { Welcome } from './Welcome';

describe('Welcome component', () => {
  it('renders the title and description', () => {
    render(<Welcome />);
    expect(screen.getByText('Amiga')).toBeDefined();
    expect(screen.getByText('View on GitHub')).toBeDefined();
    expect(screen.getByText('Get Started')).toBeDefined();
    expect(screen.getByText(/Motorola 68020/)).toBeDefined();
  });
});
