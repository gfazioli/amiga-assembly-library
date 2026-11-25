import { Container } from '@mantine/core';
import { Content } from '@/components/Content/Content';
import { Welcome } from '@/components/Welcome/Welcome';

export default function HomePage() {
  // The <main> landmark comes from the site shell (AppShell.Main), on this page as on the docs.
  return (
    <Container mih="calc(100vh - 328px)">
      <Welcome />
      <Content />
    </Container>
  );
}
