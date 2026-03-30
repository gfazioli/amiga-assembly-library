'use client';

import { TextAnimate } from '@gfazioli/mantine-text-animate';
import { IconBrandGithub, IconExternalLink } from '@tabler/icons-react';
import { Badge, Button, Center, Group, Paper, Text, Title } from '@mantine/core';
import classes from './Welcome.module.css';

const LIBRARY_FUNCTIONS = [
  'assembly.library v41.21 — Motorola 68020',
  '',
  '> Exec Module:',
  '  AllocNewList()  AllocNode()  FreeList()',
  '  ReAllocVec()    RevertMem()  FreeNode()',
  '',
  '> DOS Module:',
  '  Load()  Save()  FileInfo()  CheckFile()',
  '  UnitInfo()  CheckSum()  LineInput()',
  '',
  '> Graphics Module:',
  '  AddBitPlanes()  AllocRastPort()  DrawBox()',
  '  TextFmtRastPortArgs()  FadeColor()',
  '',
  '> Math Module:',
  '  StringDecToValue()  ValueToStringDec()',
  '  StringHexToValue()  ValueToStringHex()',
  '  StringBinToValue()  ValueToStringBin()',
  '',
  '> REI Interface:',
  '  OpenREI()  CloseREI()  WaitREIMsg()',
  '  FindREI()  RefreshREI()  ActiveREI()',
  '',
  'Ready.',
];

export function Welcome() {
  return (
    <>
      <Center my={48}>
        <Group gap="xs">
          <Badge size="lg" variant="gradient" gradient={{ from: 'orange', to: 'yellow' }}>
            v41.21
          </Badge>
          <Badge size="lg" variant="light" color="gray">
            Public Domain
          </Badge>
          <Badge size="lg" variant="light" color="gray">
            68020
          </Badge>
        </Group>
      </Center>
      <Title maw="90vw" mx="auto" className={classes.title} ta="center">
        Amiga{' '}
        <TextAnimate
          animate="in"
          by="character"
          inherit
          variant="gradient"
          component="span"
          segmentDelay={0.2}
          duration={2}
          animation="scale"
          animateProps={{
            scaleAmount: 3,
          }}
          gradient={{ from: 'orange', to: 'yellow' }}
        >
          Assembly Library
        </TextAnimate>
      </Title>

      <Text c="dimmed" ta="center" size="xl" maw={620} mx="auto" mt="sm">
        A shared library for Commodore Amiga written in Motorola 68020 assembly language. Provides
        50+ functions for graphics, file I/O, memory management, UI, and more. Compatible with
        KickStart 3.0+.
      </Text>

      <Center>
        <Button
          href="https://github.com/gfazioli/amiga-68020-library"
          component="a"
          rightSection={<IconExternalLink />}
          leftSection={<IconBrandGithub />}
          variant="outline"
          color="orange"
          px={32}
          radius={256}
          size="lg"
          mx="auto"
          mt="xl"
        >
          View on GitHub
        </Button>
      </Center>

      <Paper shadow="xl" p={8} mih={300} my={32} bg="black" mx="auto" radius={8}>
        <TextAnimate.Typewriter
          fz={11}
          c="green.5"
          ff="monospace"
          multiline
          delay={60}
          loop={false}
          value={LIBRARY_FUNCTIONS}
        />
      </Paper>
    </>
  );
}
