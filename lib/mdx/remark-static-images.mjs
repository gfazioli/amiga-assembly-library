/**
 * Turns a Markdown image that points at a file next to the page, `![alt](./photo.png)`, into an
 * import of that file, so the bundler serves it (with its size, for `next/image`) the way Nextra's
 * `remarkStaticImage` did. Without it the URL stays `./photo.png`, which the browser resolves
 * against the page's own route and nobody serves.
 *
 * Only relative paths to an image file are touched: `https://…` and `/public/…` URLs stay as they
 * are. The image becomes `<img src={importedImage} alt="…" />`, which `components/docs/MdxElements`
 * renders with `next/image`.
 *
 * It is a plain module, with no dependency, because Turbopack loads remark plugins by path.
 */
const RELATIVE_IMAGE = /^\.{1,2}\/.+\.(png|jpe?g|gif|webp|avif|svg)$/i;

const identifier = (name) => ({ type: 'Identifier', name });

export default function remarkStaticImages() {
  return (tree) => {
    const imports = [];

    const walk = (node) => {
      if (!Array.isArray(node.children)) {
        return;
      }
      node.children = node.children.map((child) => {
        if (child.type === 'image' && RELATIVE_IMAGE.test(child.url)) {
          const name = `__staticImage${imports.length}`;
          imports.push({ name, url: child.url });
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
