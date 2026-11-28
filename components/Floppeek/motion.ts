/** The reader allows motion: animations run, a stage below the fold waits to open in view. */
export function moving() {
  return window.matchMedia('(prefers-reduced-motion: no-preference)').matches;
}

/** Timeouts an effect can clear all at once when it is torn down. */
export function timeouts() {
  const pending = new Set<ReturnType<typeof setTimeout>>();
  return {
    later(fn: () => void, ms: number) {
      const timer = setTimeout(() => {
        pending.delete(timer);
        fn();
      }, ms);
      pending.add(timer);
      return timer;
    },
    cancel(timer: ReturnType<typeof setTimeout> | undefined) {
      if (timer !== undefined) {
        clearTimeout(timer);
        pending.delete(timer);
      }
    },
    clear() {
      pending.forEach(clearTimeout);
      pending.clear();
    },
  };
}
