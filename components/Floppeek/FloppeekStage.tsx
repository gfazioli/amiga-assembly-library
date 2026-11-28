'use client';

import { useEffect, useRef } from 'react';
import { AmigaWindow } from '@/components/AmigaWindow/AmigaWindow';
import { WORK_DISK_ROWS } from './floppeek';
import { moving, timeouts } from './motion';
import classes from './Floppeek.module.css';

const ZOOM_BOXES = 6;
const PREVIEW_ID = 'floppeek-preview';

/**
 * Floppeek's trick, shown: a disk's Finder icon, the Space key, and the preview Space opens.
 *
 * The served HTML is the finished picture (the window open, every row there), which is also what
 * a reader without JavaScript or with reduced motion keeps. With motion, a stage below the fold
 * waits hidden (its space kept) and opens the first time it comes into view: the key goes down,
 * zoom boxes step from the disk to the window, the listing prints row by row. The key is a real
 * button: a click, Enter or Space closes and opens the preview, as Quick Look does.
 *
 * The state lives on the DOM (`data-state`, `data-anim`), set here only, as the animations need
 * it removed and set again within one frame to replay.
 */
export function FloppeekStage() {
  const stageRef = useRef<HTMLElement>(null);
  const diskRef = useRef<SVGSVGElement>(null);
  const keyRef = useRef<HTMLButtonElement>(null);
  const windowRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const stage = stageRef.current;
    const disk = diskRef.current;
    const key = keyRef.current;
    if (!stage || !disk || !key) {
      return undefined;
    }
    const boxes = Array.from(stage.querySelectorAll<HTMLElement>(`.${classes.zoom} i`));
    const timers = timeouts();
    let animTimer: ReturnType<typeof setTimeout> | undefined;

    // Six outlines between the disk's box and the window's, in the stage's coordinates,
    // measured at play time
    const placeZoom = () => {
      const win = windowRef.current;
      if (!win) {
        return;
      }
      const s = stage.getBoundingClientRect();
      const a = disk.getBoundingClientRect();
      const b = win.getBoundingClientRect();
      boxes.forEach((box, i) => {
        const t = i / (boxes.length - 1);
        const mix = (p: 'left' | 'top' | 'width' | 'height') => a[p] + (b[p] - a[p]) * t;
        box.style.left = `${mix('left') - s.left}px`;
        box.style.top = `${mix('top') - s.top}px`;
        box.style.width = `${mix('width')}px`;
        box.style.height = `${mix('height')}px`;
      });
    };

    const play = (name: 'opening' | 'closing', ms: number) => {
      timers.cancel(animTimer);
      stage.removeAttribute('data-anim');
      if (!moving()) {
        return;
      }
      placeZoom();
      void stage.offsetWidth; // restart the animations
      stage.dataset.anim = name;
      animTimer = timers.later(() => stage.removeAttribute('data-anim'), ms);
    };

    const setOpen = (open: boolean) => {
      stage.dataset.state = open ? 'open' : 'closed';
      key.setAttribute('aria-expanded', String(open));
      play(open ? 'opening' : 'closing', open ? 1400 : 500);
    };

    const pressKey = () => {
      key.setAttribute('data-down', '');
      timers.later(() => key.removeAttribute('data-down'), 120);
    };

    const onClick = () => {
      pressKey();
      setOpen(stage.dataset.state !== 'open');
    };
    key.addEventListener('click', onClick);

    // The first opening waits for the stage to come into view, unless it is already there (a
    // visit to /#floppeek) or the reader prefers no motion
    let observer: IntersectionObserver | undefined;
    if (
      moving() &&
      'IntersectionObserver' in window &&
      stage.getBoundingClientRect().top >= window.innerHeight * 0.85
    ) {
      stage.dataset.state = 'armed';
      key.setAttribute('aria-expanded', 'false');
      observer = new IntersectionObserver(
        (entries) => {
          if (entries[0]?.isIntersecting) {
            observer?.disconnect();
            pressKey();
            setOpen(true);
          }
        },
        { threshold: 0.35 }
      );
      observer.observe(stage);
    }

    return () => {
      key.removeEventListener('click', onClick);
      observer?.disconnect();
      timers.clear();
    };
  }, []);

  return (
    <figure ref={stageRef} className={classes.stage} data-state="open">
      <div className={classes.desk}>
        {/* The Finder icon Floppeek draws for a disk, redrawn: 64 units shown at 128px */}
        <svg
          ref={diskRef}
          className={classes.disk}
          viewBox="0 0 64 64"
          shapeRendering="crispEdges"
          role="img"
          aria-label="The Finder icon of Work Disk.adf: a floppy with Work Disk on its label"
        >
          <rect width="64" height="64" rx="4" fill="#fff" />
          <path d="M2 2h56l4 4v56H2z" fill="#000022" />
          <path d="M3 3h54.5L61 6.5V61H3z" fill="#0055aa" />
          <rect x="15" y="3" width="34" height="20" fill="#000022" />
          <rect x="16" y="3" width="32" height="19" fill="#cbd0da" />
          <rect x="36" y="6" width="6" height="13" fill="#000022" />
          <rect x="8" y="28" width="48" height="26" fill="#fff" />
          <rect x="8" y="28" width="48" height="4" fill="#ff8800" />
          <text x="32" y="46" textAnchor="middle" fill="#000022">
            Work Disk
          </text>
          <rect x="5" y="55" width="4" height="4" fill="#000022" />
        </svg>
        <div className={classes.how}>
          <span className={classes.file}>Work Disk.adf</span>
          <button
            ref={keyRef}
            type="button"
            className={classes.key}
            aria-expanded="true"
            aria-controls={PREVIEW_ID}
            aria-label="Space: close or open the preview"
          >
            <span className={classes.keyCap} aria-hidden>
              Space
            </span>
          </button>
          <span className={classes.hint}>Press it: the preview closes and opens.</span>
        </div>
      </div>

      <div className={classes.zoom} aria-hidden>
        {Array.from({ length: ZOOM_BOXES }, (_, i) => (
          <i key={i} style={{ '--i': i } as React.CSSProperties} />
        ))}
      </div>

      <div className={classes.winBox} id={PREVIEW_ID}>
        <AmigaWindow
          windowRef={windowRef}
          title="Work Disk"
          tone="workbench"
          caption="What Space shows for Work Disk.adf: every drawer and file, with its size, protection bits and date."
        >
          <div
            role="img"
            aria-label="Floppeek's preview of Work Disk.adf: 880K, FFS, double density, 132 of 1760 blocks used. Five drawers, C, Docs, Libs, S and Tools, and nine files, each with its size, protection bits, date and comment."
          >
            <div className={classes.list} aria-hidden>
              {WORK_DISK_ROWS.map((row, i) => (
                <span
                  // The rows never change or move: their place is their identity
                  // eslint-disable-next-line react/no-array-index-key
                  key={i}
                  className={row.orange ? `${classes.row} ${classes.orange}` : classes.row}
                  style={{ '--i': i } as React.CSSProperties}
                >
                  {row.text}
                  {row.date && <span className={classes.date}> {row.date}</span>}
                  {row.time && <span className={classes.time}> {row.time}</span>}
                </span>
              ))}
            </div>
          </div>
        </AmigaWindow>
      </div>
    </figure>
  );
}
