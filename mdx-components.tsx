import type { MDXComponents } from 'mdx/types';
import { mdxElements } from '@/components/docs/MdxElements/MdxElements';

/**
 * Required by `@next/mdx` in the App Router: the components every MDX page renders its HTML
 * with. See `components/docs/MdxElements` for the mapping to Mantine.
 */
export function useMDXComponents(components?: MDXComponents): MDXComponents {
  return { ...mdxElements, ...components };
}
