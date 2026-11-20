// gta6-clipper-01 entry program (Node 22, standard library only).
//
// The entry is the YouTube video itself: the agent found a GTA 6 moment in
// Rockstar's Trailer 2, cut it into the vertical clip in this repository
// (clip.mp4, built by make_clip.sh), and the clip goes up on YouTube as a
// public Short whose description carries the bounty's line and the entrant's
// play code. This program's whole job is to hand the video's address to the
// gate: it validates VIDEO.json at the repository root and copies it to
// /output/VIDEO.json, byte for byte, the same on every run.
//
// Outside the grader's container, MAKEFUN_BOT_DIR and MAKEFUN_OUTPUT_DIR
// stand in for /bot and /output:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, mkdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const BOT_DIR = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// The video's address as YouTube's Share button gives it: a shorts, watch or
// youtu.be URL whose id is 11 letters, digits, _ or -.
const VIDEO_URL = /^https:\/\/(www\.|m\.)?(youtube\.com\/(shorts\/|watch\?v=)|youtu\.be\/)[A-Za-z0-9_-]{11}([?&#].*)?$/;

function videoUrlOf(raw: string): string {
  const parsed = JSON.parse(raw) as { url?: unknown };
  if (typeof parsed.url !== 'string' || !VIDEO_URL.test(parsed.url)) {
    throw new Error('VIDEO.json does not hold a YouTube video address');
  }
  return parsed.url;
}

// The gate caps VIDEO.json at 16384 bytes; check before copying so an
// oversized file fails here with a clear message instead of at the gate.

mkdirSync(OUTPUT_DIR, { recursive: true });
try {
  const raw = readFileSync(join(BOT_DIR, 'VIDEO.json'), 'utf8');
  if (Buffer.byteLength(raw) > 16384) {
    throw new Error('VIDEO.json is over the 16384-byte cap');
  }
  videoUrlOf(raw); // refuse a malformed file rather than hand it on
  copyFileSync(join(BOT_DIR, 'VIDEO.json'), join(OUTPUT_DIR, 'VIDEO.json'));
} catch (err) {
  console.error(`VIDEO.json could not be copied from ${BOT_DIR}: ${(err as Error).message}`);
  process.exit(1);
}
