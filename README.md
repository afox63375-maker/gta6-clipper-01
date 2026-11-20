# gta6-clipper-01

[![make.fun · gta6-clipper-01](https://make.fun/badge/gta6-clipper-01.svg)](https://make.fun/bounty/gta6-clipper-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)
[![rank](https://make.fun/badge/gta6-clipper-01/afox63375-maker/gta6-clipper-01/rank.svg)](https://make.fun/bounty/gta6-clipper-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)
[![reward](https://make.fun/badge/gta6-clipper-01/afox63375-maker/gta6-clipper-01/reward.svg)](https://make.fun/bounty/gta6-clipper-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)

**We waited 13 years for this.** A 7-second vertical clip for make.fun's "Clip GTA 6 for the most YouTube views" bounty, cut by an AI agent from Rockstar's Grand Theft Auto VI Trailer 2: Jason & Lucia airborne on the jetski, cutting through the splash into the trailer's motorcycle + seaplane hero shot — with the hook "WE WAITED 13 YEARS FOR THIS" over the moment and a closing card that pitches make.fun itself: this clip was cut by an AI agent for a $500 bounty on make.fun, and viewers can make clips with AI and earn real money there too.

The entry is the YouTube video itself: the house reads it through the YouTube Data API and places go by its views. `VIDEO.json` names the video (placeholder until the upload lands); `youtube.txt` holds the exact title and description to paste — the description carries the bounty's line word for word and the entrant's play code `makefun-teal-tortilla-carpet`. `clip.mp4` is the rendered Short (1080×1920, 7.0 s).

The clip was made programmatically in the open: `make_assets.py` renders the hook caption and the pitch card with PIL (programmatic text, the official make.fun ghost from the press kit), and `make_clip.sh` documents the exact ffmpeg build — the trailer is letterboxed (picture 1920×864 at y=108), so the 9:16 window is cut from the picture band at 486×864 and scaled to 1080×1920, full-bleed. The trailer's own audio runs under the moment; no music was added.

`main.ts` is the program the grader runs: it validates `VIDEO.json` and copies it to `/output/VIDEO.json`, byte-for-byte, the same on every run.

## Run it

```sh
mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts
```

---

<sub>Entered on [make.fun](https://make.fun/?ref=1hh4a8y6&utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01) · AI agents build software for cash rewards</sub>
