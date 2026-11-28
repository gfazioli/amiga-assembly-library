import { IconArrowRight } from '@tabler/icons-react';
import { Container } from '@mantine/core';
import { Link } from '@/components/Link/Link';
import type { ModuleDefinition } from './modules';
import classes from './Content.module.css';

export interface LibraryModule extends ModuleDefinition {
  /** The module's functions, as its docs folder lists them */
  functions: string[];
}

/** How many function names a card shows before "and N more" */
const NAMES_SHOWN = 3;

/**
 * Three steps from the archive to the first call. Each line of code is the docs' own
 * (Getting Started; the RevertMem example), and each step links to where it is explained.
 */
const STEPS = [
  {
    title: 'Install',
    text: 'Put assembly.library in LIBS: and the include files on your include path.',
    code: 'copy assembly.library LIBS:',
    href: '/docs/getting-started#installation',
    link: 'Installation',
  },
  {
    title: 'Open',
    text: 'One OpenLibrary() call, version 41 or higher. The system libraries it uses come opened with it.',
    code: 'jsr     _LVOOpenLibrary(a6)',
    href: '/docs/getting-started#opening-the-library-from-assembly',
    link: 'From assembly or C',
  },
  {
    title: 'Call',
    text: 'The library base in A6, the arguments in the registers each function page lists.',
    code: 'jsr     _LVORevertMem(a6)',
    href: '/docs/exec/revert-mem',
    link: 'A function page',
  },
];

function ModuleCard({ module }: { module: LibraryModule }) {
  const shown = module.functions.slice(0, NAMES_SHOWN);
  const more = module.functions.length - shown.length;

  return (
    <li className={classes.cardItem}>
      <Link href={module.href} className={classes.card}>
        <span className={classes.cardHead}>
          <span className={classes.cardCode} aria-hidden>
            {module.code}
          </span>
          <span className={classes.cardCount}>
            {module.reference ? 'Guide' : `${module.functions.length} functions`}
          </span>
        </span>
        <h3 className={classes.cardTitle}>{module.title}</h3>
        <p className={classes.cardText}>{module.description}</p>
        {shown.length > 0 && (
          <p className={classes.cardNames}>
            {shown.join(' · ')}
            {more > 0 && ` · +${more}`}
          </p>
        )}
      </Link>
    </li>
  );
}

/** The home page below the hero: the modules, then the way in. */
export function Content({ modules }: { modules: LibraryModule[] }) {
  return (
    <>
      <section className={classes.section} aria-labelledby="modules-title">
        <Container size="lg">
          <header className={classes.header}>
            <p className={classes.eyebrow}>Reference</p>
            {/* tabIndex: where focus goes when the Floppeek requester is put away */}
            <h2 id="modules-title" className={classes.title} tabIndex={-1}>
              Library modules
            </h2>
            <p className={classes.intro}>
              One library, organized by the part of the system each group of functions extends.
            </p>
          </header>

          <ul className={classes.grid}>
            {modules.map((module) => (
              <ModuleCard key={module.href} module={module} />
            ))}
          </ul>
        </Container>
      </section>

      <section className={classes.section} aria-labelledby="steps-title">
        <Container size="lg">
          <header className={classes.header}>
            <p className={classes.eyebrow}>Getting started</p>
            <h2 id="steps-title" className={classes.title}>
              From the archive to the first call
            </h2>
          </header>

          <ol className={classes.steps}>
            {STEPS.map((step, index) => (
              <li key={step.title} className={classes.step}>
                <span className={classes.stepNumber} aria-hidden>
                  {index + 1}
                </span>
                <h3 className={classes.stepTitle}>{step.title}</h3>
                <p className={classes.stepText}>{step.text}</p>
                <code className={classes.stepCode}>{step.code}</code>
                <Link href={step.href} className={classes.stepLink}>
                  {step.link}
                  <IconArrowRight size={16} aria-hidden />
                </Link>
              </li>
            ))}
          </ol>
        </Container>
      </section>
    </>
  );
}
