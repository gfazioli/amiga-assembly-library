import { IconCpu } from '@tabler/icons-react';
import { useMantineTheme } from '@mantine/core';

export function Logo() {
  const theme = useMantineTheme();

  return <IconCpu size={48} color={theme.colors.orange[5]} />;
}
