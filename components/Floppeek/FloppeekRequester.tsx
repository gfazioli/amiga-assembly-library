'use client';

import { useEffect, useRef } from 'react';
import { useLocalStorage } from '@mantine/hooks';
import { FLOPPEEK_SECTION_ID, FLOPPEEK_STORAGE_KEY } from './floppeek';
import classes from './Floppeek.module.css';

const ZOOM = [0.12, 0.34, 0.56, 0.78, 1];

function moving() {
  return window.matchMedia('(prefers-reduced-motion: no-preference)').matches;
}

/**
 * A System Request in the corner of the home page, announcing Floppeek once the hero has gone by:
 * "Show me" takes the reader to its section, Cancel (or the close gadget, or Esc) puts it away.
 * Not a dialog: no backdrop, focus never moved to it. Every way out writes the banner's key, so
 * neither it nor the docs pages' banner comes back until the next announcement; it also leaves
 * by itself once the section is on screen, and never shows if the reader got there first.
 */
export function FloppeekRequester() {
  const rootRef = useRef<HTMLElement>(null);
  const [dismissed, setDismissed] = useLocalStorage<boolean>({
    key: FLOPPEEK_STORAGE_KEY,
    defaultValue: false,
    getInitialValueInEffect: true,
  });
  // The storage is read in an effect: until then nothing may show
  const dismissedRef = useRef(dismissed);
  dismissedRef.current = dismissed;
  const leaveRef = useRef<(restoreFocus: boolean) => void>(() => {});

  useEffect(() => {
    const root = rootRef.current;
    const section = document.getElementById(FLOPPEEK_SECTION_ID);
    if (!root || !section) {
      return undefined;
    }
    let shown = false;
    let done = false;
    const timers = new Set<ReturnType<typeof setTimeout>>();
    const later = (fn: () => void, ms: number) => {
      const timer = setTimeout(() => {
        timers.delete(timer);
        fn();
      }, ms);
      timers.add(timer);
    };

    const show = () => {
      if (shown || done || dismissedRef.current || window.innerHeight < 520) {
        return;
      }
      shown = true;
      root.hidden = false;
      if (moving()) {
        root.dataset.anim = 'in';
      }
    };

    const leave = (restoreFocus: boolean) => {
      const hadFocus = root.contains(document.activeElement);
      done = true;
      setDismissed(true);
      if (!shown || root.hidden) {
        return;
      }
      if (moving()) {
        root.dataset.anim = 'out';
        later(() => {
          root.hidden = true;
          root.removeAttribute('data-anim');
        }, 420);
      } else {
        root.hidden = true;
      }
      if (restoreFocus && hadFocus) {
        document.getElementById('modules-title')?.focus({ preventScroll: true });
      }
    };
    leaveRef.current = leave;

    // In: once the reader has scrolled 60% of a viewport, and a beat after, so it does not cut
    // into a fling
    const onScroll = () => {
      if (window.scrollY >= window.innerHeight * 0.6) {
        window.removeEventListener('scroll', onScroll);
        later(show, 400);
      }
    };
    window.addEventListener('scroll', onScroll, { passive: true });

    // Out: the section it points to is on screen
    let observer: IntersectionObserver | undefined;
    if ('IntersectionObserver' in window) {
      observer = new IntersectionObserver(
        (entries) => {
          if (entries[0]?.isIntersecting && !done && !dismissedRef.current) {
            leave(false);
          }
        },
        { threshold: 0.25 }
      );
      observer.observe(section);
    }

    // Esc, unless a modal (Spotlight) has it or something else took the key
    const onKey = (event: KeyboardEvent) => {
      if (
        event.key === 'Escape' &&
        shown &&
        !root.hidden &&
        !event.defaultPrevented &&
        !document.querySelector('[role="dialog"][aria-modal="true"]')
      ) {
        leave(true);
      }
    };
    document.addEventListener('keydown', onKey);

    return () => {
      window.removeEventListener('scroll', onScroll);
      document.removeEventListener('keydown', onKey);
      observer?.disconnect();
      timers.forEach(clearTimeout);
    };
  }, [setDismissed]);

  return (
    <aside
      ref={rootRef}
      className={classes.requester}
      role="region"
      aria-label="Announcement"
      hidden
    >
      <div className={classes.rqZoom} aria-hidden>
        {ZOOM.map((t, i) => (
          <i key={t} style={{ '--i': i, '--t': t } as React.CSSProperties} />
        ))}
      </div>
      <div className={classes.rqWindow}>
        <div className={classes.rqBar}>
          <button
            type="button"
            className={classes.rqClose}
            aria-label="Dismiss the announcement"
            onClick={() => leaveRef.current(true)}
          />
          <span className={classes.rqTitle} aria-hidden>
            System Request
          </span>
          <span className={classes.rqDrag} aria-hidden />
          <span className={classes.rqDepth} aria-hidden />
        </div>
        <div className={classes.rqCopper} aria-hidden />
        <div className={classes.rqBody}>
          <img
            className={classes.rqIcon}
            src="/floppeek/icon-256.png"
            alt=""
            width={64}
            height={64}
            loading="eager"
            fetchPriority="low"
          />
          <div>
            <p className={classes.rqHead}>New: Floppeek</p>
            <p className={classes.rqText}>
              Quick Look for Amiga disk images on the Mac. Press Space on an .adf in the Finder.
            </p>
          </div>
          {/* The Amiga's requester layout: the affirmative gadget on the left, Cancel on the right */}
          <div className={classes.rqGadgets}>
            <a
              className={`${classes.rqGadget} ${classes.rqGo}`}
              href={`#${FLOPPEEK_SECTION_ID}`}
              onClick={() => leaveRef.current(false)}
            >
              Show me
            </a>
            <button
              type="button"
              className={classes.rqGadget}
              onClick={() => leaveRef.current(true)}
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </aside>
  );
}
