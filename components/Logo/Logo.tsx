/**
 * The site's mark: a 68020 seen from above, on a 16-unit grid of square pixels (the favicon is
 * the same drawing, public/favicon.svg). Our own, and not a mark of the platform's. It takes the
 * primary colour unless the parent sets another; decorative, since the name stands beside it.
 */
export function Logo({ size = 32 }: { size?: number }) {
  return (
    <svg
      aria-hidden
      width={size}
      height={size}
      viewBox="0 0 16 16"
      shapeRendering="crispEdges"
      fill="var(--mantine-primary-color-filled)"
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* The package, the die, and two pins a side */}
      <path
        fillRule="evenodd"
        d="M3 3h10v10H3zM5 5v6h6V5zM7 7h2v2H7zM5 1h2v2H5zM9 1h2v2H9zM5 13h2v2H5zM9 13h2v2H9zM1 5h2v2H1zM1 9h2v2H1zM13 5h2v2h-2zM13 9h2v2h-2z"
      />
    </svg>
  );
}
