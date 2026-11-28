import classes from './AmigaWindow.module.css';

export interface AmigaWindowProps {
  /** The text in the title bar */
  title: string;
  /** A caption under the window */
  caption?: React.ReactNode;
  /** The screen: the site's dark one (default), or Workbench blue with white type */
  tone?: 'screen' | 'workbench';
  /** The window itself, chrome and screen without the caption (to measure it) */
  windowRef?: React.Ref<HTMLDivElement>;
  children: React.ReactNode;
}

/**
 * A window in the manner of the Amiga's: a title bar with a close gadget, a striped drag bar and
 * a depth gadget, around a screen that stays dark in both colour schemes. Drawn in CSS, from
 * borders and gradients: no artwork of the system's is used. The chrome is decoration, hidden
 * from assistive tech; the content and the caption are not.
 */
export function AmigaWindow({
  title,
  caption,
  tone = 'screen',
  windowRef,
  children,
}: AmigaWindowProps) {
  return (
    <figure className={classes.root} data-tone={tone}>
      <div ref={windowRef} className={classes.window}>
        <div className={classes.titleBar} aria-hidden>
          <span className={classes.close} />
          <span className={classes.title}>{title}</span>
          <span className={classes.drag} />
          <span className={classes.depth} />
        </div>
        <div className={classes.screen}>{children}</div>
      </div>
      {caption && <figcaption className={classes.caption}>{caption}</figcaption>}
    </figure>
  );
}
