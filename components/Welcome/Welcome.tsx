'use client';

import { useEffect, useState } from 'react';
import { TextAnimate } from '@gfazioli/mantine-text-animate';
import { IconBrandGithub, IconDownload, IconExternalLink } from '@tabler/icons-react';
import { Badge, Box, Button, Center, Group, Paper, Switch, Text, Title } from '@mantine/core';
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

/**
 * Official Amiga checkmark logo — rainbow stripe V/checkmark.
 */
function AmigaCheckmark({ size = 200 }: { size?: number }) {
  return (
    <svg
      clipRule="evenodd"
      fillRule="evenodd"
      height={size}
      viewBox="0 0 48 48"
      width={size}
      xmlns="http://www.w3.org/2000/svg"
    >
      <g clipRule="evenodd">
        <g fillRule="evenodd">
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
        </g>
      </g>
    </svg>
  );
}

export function Welcome() {
  const [amigaMode, setAmigaMode] = useState(false);

  useEffect(() => {
    const saved = localStorage.getItem('amiga-mode');
    if (saved === 'true') {
      setAmigaMode(true);
    }
  }, []);

  const toggleAmigaMode = (checked: boolean) => {
    setAmigaMode(checked);
    if (checked) {
      document.documentElement.setAttribute('data-amiga-mode', '');
      localStorage.setItem('amiga-mode', 'true');
    } else {
      document.documentElement.removeAttribute('data-amiga-mode');
      localStorage.setItem('amiga-mode', 'false');
    }
  };

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

      <Center mb="md">
        <Switch
          checked={amigaMode}
          onChange={(event) => toggleAmigaMode(event.currentTarget.checked)}
          label="Amiga Mode"
          size="lg"
          color="orange"
          labelPosition="left"
          thumbIcon={<AmigaCheckmark size={16} />}
          onLabel="ON"
          offLabel="OFF"
        />
      </Center>

      <Title maw="90vw" mx="auto" className={classes.title} ta="center" data-amiga-logo="">
        <Box
          component="span"
          style={{
            display: 'inline-block',
            verticalAlign: 'middle',
            marginRight: '-0.5em',
            marginBottom: '0.4em',
          }}
        >
          <AmigaCheckmark size={140} />
        </Box>
        <span
          data-amiga-logo=""
          style={{
            fontStyle: 'italic',
            fontFamily: 'Garamond, "EB Garamond", "Times New Roman", serif',
            textTransform: 'uppercase',
            letterSpacing: '0.02em',
            fontSize: '1.15em',
          }}
        >
          Amiga
        </span>{' '}
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
        <Group gap="md">
          <Button
            href="https://github.com/gfazioli/amiga-assembly-library"
            component="a"
            rightSection={<IconExternalLink />}
            leftSection={<IconBrandGithub />}
            variant="outline"
            color="orange"
            px={32}
            radius={256}
            size="lg"
            mt="xl"
          >
            View on GitHub
          </Button>
          <Button
            href="/docs/getting-started"
            component="a"
            variant="filled"
            color="orange"
            px={32}
            radius={256}
            size="lg"
            mt="xl"
          >
            Get Started
          </Button>
          <Button
            href="/download.zip"
            component="a"
            leftSection={<IconDownload />}
            variant="light"
            color="orange"
            px={32}
            radius={256}
            size="lg"
            mt="xl"
          >
            Download
          </Button>
        </Group>
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
