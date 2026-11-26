/**
 * Turns a Markdown image that points at a file next to the page, `![alt](./photo.png)`, into an
 * import of that file, so the bundler serves it (with its size, for `next/image`) the way Nextra's
 * `remarkStaticImage` did. Without it the URL stays `./photo.png`, which the browser resolves
 * against the page's own route and nobody serves.
 *
 * Only relative paths to an image file are touched, with or without a `./` (`photo.png`,
 * `images/photo.png`): `https://…`, `//cdn…` and `/public/…` URLs stay as they
 * are. The image becomes `<img src={importedImage} alt="…" />`, which `components/docs/MdxElements`
 * renders with `next/image`. A bare path is imported as `./path`: a bare import specifier would
 * name a package.
 *
 * It is a plain module, with no dependency, because Turbopack loads remark plugins by path.
 */
const IMAGE_FILE = /\.(png|jpe?g|gif|webp|avif|svg)$/i;
// Relative to the page: `./a.png`, `../a.png`, `a.png`, `images/a.png`. Not `https://…`, `//cdn…`,
// `data:…` (anything with a scheme), `/public/a.png` (absolute) or `#…`.
const isRelativeImage = (url) => IMAGE_FILE.test(url) && !/^([a-z][a-z0-9+.-]*:|\/|#)/i.test(url);

const toSpecifier = (url) => (url.startsWith('.') ? url : `./${url}`);

const identifier = (name) => ({ type: 'Identifier', name });

export default function remarkStaticImages() {
  return (tree) => {
    const imports = [];

    const walk = (node) => {
      if (!Array.isArray(node.children)) {
        return;
      }
      node.children = node.children.map((child) => {
        if (child.type === 'image' && isRelativeImage(child.url)) {
          const name = `__staticImage${imports.length}`;
          imports.push({ name, url: toSpecifier(child.url) });
          return {
            type: 'mdxJsxTextElement',
            name: 'img',
            children: [],
            attributes: [
              {
                type: 'mdxJsxAttribute',
                name: 'src',
                value: {
                  type: 'mdxJsxAttributeValueExpression',
                  value: name,
                  data: {
                    estree: {
                      type: 'Program',
                      sourceType: 'module',
                      body: [{ type: 'ExpressionStatement', expression: identifier(name) }],
                    },
                  },
                },
              },
              { type: 'mdxJsxAttribute', name: 'alt', value: child.alt ?? '' },
              ...(child.title
                ? [{ type: 'mdxJsxAttribute', name: 'title', value: child.title }]
                : []),
            ],
          };
        }
        walk(child);
        return child;
      });
    };
    walk(tree);

    tree.children.unshift(
      ...imports.map(({ name, url }) => ({
        type: 'mdxjsEsm',
        value: `import ${name} from ${JSON.stringify(url)}`,
        data: {
          estree: {
            type: 'Program',
            sourceType: 'module',
            body: [
              {
                type: 'ImportDeclaration',
                specifiers: [{ type: 'ImportDefaultSpecifier', local: identifier(name) }],
                source: { type: 'Literal', value: url, raw: JSON.stringify(url) },
                attributes: [],
              },
            ],
          },
        },
      }))
    );
  };
}
