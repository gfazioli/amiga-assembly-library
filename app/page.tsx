import { Container } from '@mantine/core';
import { Content } from '@/components/Content/Content';
import { Welcome } from '@/components/Welcome/Welcome';

export default function HomePage() {
  return (
    <Container mih="calc(100vh - 328px)">
      <Welcome />
      <Content />
    </Container>
  );
}
