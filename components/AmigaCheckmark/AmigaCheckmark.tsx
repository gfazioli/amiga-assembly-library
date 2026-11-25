/**
 * The Amiga checkmark, the one mark of the platform this site shows (see NOTICE.md, Trademarks):
 * on the home page beside the name, and on the two controls that switch Amiga Mode. Decorative
 * wherever it stands, so hidden from assistive tech.
 */
export function AmigaCheckmark({ size = 20 }: { size?: number }) {
  return (
    <svg
      aria-hidden
      clipRule="evenodd"
      fillRule="evenodd"
      height={size}
      viewBox="0 0 48 48"
      width={size}
      xmlns="http://www.w3.org/2000/svg"
    >
      <path d="m33.568 16h-5l4.216-6h5zm6 0h-5l4.216-6h5z" fill="#f36c00" />
      <path d="m29.351 22h-5l4.217-6h5zm6 0h-5l4.217-6h5z" fill="#ff9000" />
      <path d="m25.135 28h-5l4.216-6h5zm6 0h-5l4.216-6h5z" fill="#ffa100" />
      <path d="m12.143 36 2.857 4-4 1-3.667-5zm6 0 2.857 4-4 1-3.667-5z" fill="#237f2d" />
      <path d="m18.143 36h-4.81l-3.666-5h4.904z" fill="#008390" />
      <path d="m20.919 34h-5l4.216-6h5zm6 0h-5l4.216-6h5z" fill="#fdc200" />
      <path d="m16 41h-5l4.919-7h5zm6 0h-5l4.919-7h5z" fill="#feda0f" />
      <path d="m37.784 10h-5l4.216-6h5zm6 0h-5l4.216-6h5z" fill="#dc4100" />
      <path d="m12.143 36h-4.81l-3.666-5h4.904z" fill="#008390" />
      <path d="m8.571 31h-4.904l-3.667-5h5zm6 0h-4.904l-3.667-5h5z" fill="#0075c0" />
    </svg>
  );
}
