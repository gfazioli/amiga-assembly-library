import { Container } from '@mantine/core';
import { SkipNavContent } from 'nextra/components';
import { Content } from '@/components/Content/Content';
import { Welcome } from '@/components/Welcome/Welcome';

export default function HomePage() {
  // A <main> for the home: the docs pages get one from Nextra, this page had none, so everything
  // on it sat in no landmark. SkipNavContent is the skip link's target, which Nextra renders only
  // on docs pages.
  return (
    <>
      <SkipNavContent />
      <Container component="main" mih="calc(100vh - 328px)">
        <Welcome />
        <Content />
      </Container>
    </>
  );
}
