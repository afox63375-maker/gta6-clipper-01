#!/usr/bin/env bash
# gta6-clipper-01 — reproducible clip build.
#
# Source: Grand Theft Auto VI Trailer 2 (Rockstar Games, official)
#   https://www.youtube.com/watch?v=VQRLujxTm3c   (1920x1080, 30 fps, 166.75 s)
#   fetched in-session with yt-dlp 2026.10.26:
#     .venv/bin/yt-dlp --no-playlist --js-runtimes node \
#       -f "bv*[height<=1080]+ba/b[height<=1080]" --merge-output-format mp4 \
#       -o "src/trailer2.%(ext)s" "https://www.youtube.com/watch?v=VQRLujxTm3c"
#   (Trailer 1, QdBZY2fkU-0, was fetched the same way and reviewed; the moment
#    below is Trailer 2's.)
#
# The moment (Trailer 2 timecodes): 140.30-143.75 s — Jason & Lucia airborne on
# the green jetski with a police helicopter overhead and the Vice City skyline
# behind them, cutting through the splash into the motorcycle + seaplane hero
# shot. Chosen because it is the trailer's most clipped beat: two instantly
# readable hero frames in 3.5 s, bright daylight, faces to camera.
#
# Edit (all ffmpeg, in-session):
#   The trailer is letterboxed: picture content is 1920x864 at y=108..972
#   (cropdetect, limit 24). The 9:16 window is therefore 486x864 cut from
#   the content band, then scaled to 1080x1920 — full-bleed, no bars.
#   A 140.30-141.90  jetski   crop x=1190 (riders sit right of centre)
#   B 141.90-143.30  splash -> motorcycle/seaplane, crop x=717 (centred)
#   (B ends at 143.30: the trailer's night-truck shot starts right after,
#    and its dark frames must not leak into the clip's tail.)
#   hook.png (PIL, make_assets.py) overlaid for the whole moment
#   card.png (PIL pitch end-card) appended for 4.0 s
#   audio: the trailer's own audio for the moment, faded out, padded with
#   silence under the card. No added music.
# Output: clip.mp4 — 1080x1920, 30 fps, 7.00 s, H.264 + AAC, faststart.
set -euo pipefail
cd "$(dirname "$0")"

ffmpeg -y -v error \
  -i src/trailer2.mp4 \
  -loop 1 -t 3.00 -i work/hook.png \
  -loop 1 -t 4.00 -i work/card.png \
  -filter_complex "\
[0:v]trim=start=140.30:end=141.90,setpts=PTS-STARTPTS,crop=486:864:1190:108,scale=1080:1920:flags=lanczos,setsar=1[a];\
[0:v]trim=start=141.90:end=143.30,setpts=PTS-STARTPTS,crop=486:864:717:108,scale=1080:1920:flags=lanczos,setsar=1[b];\
[a][b]concat=n=2:v=1:a=0[mv];\
[mv][1:v]overlay=0:0[hv];\
[2:v]scale=1080:1920,setsar=1,format=yuv420p[card];\
[hv][card]concat=n=2:v=1:a=0[vout];\
[0:a]atrim=start=140.30:end=143.30,asetpts=PTS-STARTPTS,afade=t=out:st=2.40:d=0.6,apad=whole_dur=7.00[aout]" \
  -map "[vout]" -map "[aout]" \
  -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 160k -movflags +faststart \
  clip.mp4

ffprobe -v error -show_entries stream=codec_type,width,height,r_frame_rate \
  -show_entries format=duration,size -of default=noprint_wrappers=1 clip.mp4
