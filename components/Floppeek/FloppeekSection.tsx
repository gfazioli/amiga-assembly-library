import { IconArrowUpRight } from '@tabler/icons-react';
import { Button, Container } from '@mantine/core';
import { BrewCommand } from './BrewCommand';
import { FLOPPEEK_SECTION_ID, FLOPPEEK_URL, FLOPPEEK_VERSION } from './floppeek';
import { FloppeekStage } from './FloppeekStage';
import classes from './Floppeek.module.css';

const FACTS = [
  ['Icons', 'In the Finder, each .adf becomes a floppy with the volume name on its label.'],
  ['Disks', 'OFS and FFS, double and high density, game and demo disks too.'],
  ['Free', 'Open source under the MIT licence, for macOS 15 or later.'],
] as const;

/**
 * Floppeek, the author's Quick Look app for Amiga disk images, as the last section of the home
 * page: after the library's own, so it pushes none of them down. The pitch on the left, the
 * demonstration on the right (FloppeekStage); on a phone the demonstration comes between the
 * pitch and the small print.
 */
export function FloppeekSection() {
  return (
    <section id={FLOPPEEK_SECTION_ID} className={classes.section} aria-labelledby="floppeek-title">
      <Container size="lg" className={classes.columns}>
        <div className={classes.head}>
          <div className={classes.brand}>
            {/* The h2 beside it names the product */}
            <img
              className={classes.icon}
              src="/floppeek/icon-256.png"
              alt=""
              width={64}
              height={64}
              loading="lazy"
            />
            <div>
              <p className={classes.eyebrow}>On your Mac</p>
              <h2 id="floppeek-title" className={classes.name}>
                Floppeek
              </h2>
            </div>
          </div>
          <p className={classes.tag}>Quick Look for Amiga disk images</p>
          <p className={classes.intro}>
            Select an .adf in the Finder and press Space: a Workbench-style window lists every
            drawer and file on the disk, the way AmigaDOS List prints them, in Topaz.
          </p>
        </div>

        <div className={classes.more}>
          <dl className={classes.facts}>
            {FACTS.map(([term, text]) => (
              <div key={term} className={classes.fact}>
                <dt>{term}</dt>
                <dd>{text}</dd>
              </div>
            ))}
          </dl>
          <div className={classes.actions}>
            <Button
              component="a"
              href={FLOPPEEK_URL}
              target="_blank"
              rel="noopener noreferrer"
              size="md"
              rightSection={<IconArrowUpRight size={18} aria-hidden />}
            >
              Get Floppeek
            </Button>
            <span className={classes.meta}>Version {FLOPPEEK_VERSION} · a DMG, or Homebrew:</span>
          </div>
          <BrewCommand />
        </div>

        <FloppeekStage />
      </Container>
    </section>
  );
}
