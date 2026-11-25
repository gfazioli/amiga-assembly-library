import { IconArrowRight, IconBrandGithub, IconDownload } from '@tabler/icons-react';
import { Button, Container } from '@mantine/core';
import { AmigaCheckmark } from '@/components/AmigaCheckmark/AmigaCheckmark';
import { AmigaWindow } from '@/components/AmigaWindow/AmigaWindow';
import { Link } from '@/components/Link/Link';
import config from '@/config';
import { AmigaModeSwitch } from './AmigaModeSwitch';
import classes from './Welcome.module.css';

export interface WelcomeProps {
  /** The hero's code, highlighted at build time (`highlightM68k`): the inner HTML of `<code>` */
  codeHtml: string;
  /** How many functions and modules the docs hold, counted from `content/` */
  functionCount: number;
  moduleCount: number;
}

/**
 * The home page's opening: the name in the pixel font, what the library is, where to go next,
 * and a window showing a call in 68k. Rendered on the server; only the Amiga Mode switch runs in
 * the browser.
 */
export function Welcome({ codeHtml, functionCount, moduleCount }: WelcomeProps) {
  const facts = [
    { value: String(functionCount), label: 'functions documented' },
    { value: String(moduleCount), label: 'modules' },
    { value: '68020', label: 'or any later 680x0' },
    { value: '3.0+', label: 'KickStart (V39)' },
  ];

  return (
    <section className={classes.hero}>
      <Container size="lg" className={classes.inner}>
        <p className={classes.kicker}>
          <span>assembly.library 41.21</span>
          <span>Public Domain</span>
        </p>

        <h1 className={classes.title}>
          <span className={classes.platform}>
            <AmigaCheckmark size={40} />
            Amiga
          </span>{' '}
          <span className={classes.name}>Assembly Library</span>
        </h1>

        <div className={classes.columns}>
          <div className={classes.pitch}>
            <p className={classes.lede}>
              A shared library for Commodore Amiga, written in Motorola 68020 assembly language. It
              adds {functionCount} functions for memory and lists, files, graphics, strings, number
              conversion and user interfaces, callable from assembly and from C.
            </p>

            <div className={classes.actions}>
              <Button
                component={Link}
                href="/docs/getting-started"
                size="md"
                rightSection={<IconArrowRight size={18} />}
              >
                Get Started
              </Button>
              <Button
                component="a"
                href="/download.zip"
                size="md"
                variant="default"
                leftSection={<IconDownload size={18} />}
              >
                Download
              </Button>
              <Button
                component="a"
                href={`https://github.com/${config.gitHub.repo}`}
                size="md"
                variant="subtle"
                color="gray"
                leftSection={<IconBrandGithub size={18} />}
              >
                GitHub
              </Button>
            </div>

            <AmigaModeSwitch />
          </div>

          <AmigaWindow
            title="RevertMem.asm"
            caption={
              <>
                Opening the library and calling{' '}
                <Link href="/docs/exec/revert-mem" className={classes.captionLink}>
                  RevertMem()
                </Link>
                : the base in A6, the arguments in registers.
              </>
            }
          >
            <pre className={classes.code}>
              <code dangerouslySetInnerHTML={{ __html: codeHtml }} />
            </pre>
          </AmigaWindow>
        </div>

        <dl className={classes.facts}>
          {facts.map((fact) => (
            <div key={fact.label} className={classes.fact}>
              <dt className={classes.factLabel}>{fact.label}</dt>
              <dd className={classes.factValue}>{fact.value}</dd>
            </div>
          ))}
        </dl>
      </Container>
    </section>
  );
}
