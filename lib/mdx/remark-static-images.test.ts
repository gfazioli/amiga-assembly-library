import remarkStaticImages from './remark-static-images.mjs';

const image = (url: string, alt = 'A photo', title?: string) => ({
  type: 'image',
  url,
  alt,
  title,
});

function transform(children: unknown[]) {
  const tree = {
    type: 'root',
    children: [
      { type: 'paragraph', children },
      { type: 'paragraph', children: [] },
    ],
  } as any;
  remarkStaticImages()(tree);
  return tree;
}

describe('remarkStaticImages', () => {
  it('turns a relative image into an import and an <img src={import}>', () => {
    const tree = transform([image('./photo.png', 'A photo', 'Caption')]);

    const [esm] = tree.children;
    expect(esm.type).toBe('mdxjsEsm');
    expect(esm.value).toBe('import __staticImage0 from "./photo.png"');
    expect(esm.data.estree.body[0].source.value).toBe('./photo.png');

    const img = tree.children[1].children[0];
    expect(img.type).toBe('mdxJsxTextElement');
    expect(img.name).toBe('img');
    const [src, alt, title] = img.attributes;
    expect(src.value.value).toBe('__staticImage0');
    expect(src.value.data.estree.body[0].expression.name).toBe('__staticImage0');
    expect([alt.value, title.value]).toEqual(['A photo', 'Caption']);
  });

  it('numbers each image and follows ../ paths', () => {
    const tree = transform([image('./a.jpg'), image('../b.webp')]);
    expect(tree.children.slice(0, 2).map((node: any) => node.value)).toEqual([
      'import __staticImage0 from "./a.jpg"',
      'import __staticImage1 from "../b.webp"',
    ]);
  });

  it('imports a path with no ./ as ./path, never as a bare package specifier', () => {
    const tree = transform([image('photo.png'), image('images/photo.jpg')]);
    expect(tree.children.slice(0, 2).map((node: any) => node.value)).toEqual([
      'import __staticImage0 from "./photo.png"',
      'import __staticImage1 from "./images/photo.jpg"',
    ]);
  });

  it('leaves remote, absolute and non-image URLs alone', () => {
    const tree = transform([
      image('https://example.com/a.png'),
      image('//cdn.example.com/a.png'),
      image('data:image/png;base64,AAAA'),
      image('/public/a.png'),
      image('./notes.pdf'),
    ]);
    expect(tree.children).toHaveLength(2);
    expect(tree.children[0].children.every((node: any) => node.type === 'image')).toBe(true);
  });
});
