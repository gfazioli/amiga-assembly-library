import { highlightM68k } from '@/lib/mdx/m68k';
import { Welcome } from './Welcome';

export default {
  title: 'Welcome',
};

export const Usage = () => (
  <Welcome
    codeHtml={highlightM68k('    moveq   #TYPEF_WORD,d0\n    jsr     _LVORevertMem(a6)')}
    functionCount={60}
    moduleCount={7}
  />
);
