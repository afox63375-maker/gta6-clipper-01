#!/usr/bin/env bash
# gta6-clipper-01 ROUND 3 — clip9: BRAND-NEW entry built from scratch
# at Rio's order ("Buat ulang entry bounty clipper dari Trailer 2").
# Concept (new in this session): "EVERY GTA 6 LOCATION IN 10 SECONDS"
# — a rapid location tour of Leonida / Vice City, Trailer 2 footage
# only, big place-name tags counting up as the cuts accelerate.
#
# Source: Grand Theft Auto VI Trailer 2 (Rockstar Games, official)
#   https://www.youtube.com/watch?v=VQRLujxTm3c  (1920x1080, 30 fps,
#   166.75 s). src/trailer2.mp4 is the workspace's local copy; nothing
#   was downloaded in this session.
#
# Beats (timecodes verified FRAME-ACCURATELY in this session with
# post-input -ss single-frame extraction — the file's fps sampling
# drifts, so every window below was confirmed on extracted frames at
# both its start and its end):
#   1.   6.30-  7.40 (1.10 s) Keys aerial: turquoise water, coastal
#        town. HOOK "EVERY GTA 6 LOCATION IN 10 SECONDS" + tag
#        "THE KEYS", crop x=560.
#   2.  50.30- 51.30 (1.00 s) prison watchtower behind razor wire.
#        Tag "LEONIDA PRISON", crop x=1000.
#   3.  38.60- 39.60 (1.00 s) outdoor beach gym, bench press under
#        palms. Tag "VICE BEACH", crop x=700.
#   4. 127.00-127.95 (0.95 s) neon club canopy at night, pink neon,
#        palms. Tag "PORT GELLHORN", crop x=480.
#   5. 138.40-139.35 (0.95 s) helicopter sweeping over the swamp
#        river, airboat below. Tag "MOUNT KALAGA", crop x=820.
#   6. 144.45-145.35 (0.90 s) downtown at night: pink-lit tower,
#        skyline, truck stunt. Tag "DOWNTOWN VICE CITY", crop x=620.
#   7. 154.40-155.50 (1.10 s) golden-hour causeway into the widest
#        skyline. Tag "WELCOME BACK TO VICE CITY", crop x=717.
#   Pitch card: 4.00 s, SILENT.  Beats 7.00 s; total 11.00 s.
#
# Method: each beat rendered by its OWN ffmpeg invocation, pieces
# joined with the concat demuxer. Picture band is 1920x864 at
# y=108..972; the 9:16 window is 486x864 scaled to 1080x1920,
# full-bleed, no letterbox.
#
# AUDIO: one continuous music bed — "Hot Together" by The Pointer
# Sisters (Trailer 2's own track) from the trailer audio at
# 104.00-108.70 s, looped into itself with a 0.7 s crossfade to cover
# the 7.00 s of beats, volume 0.75, faded out over the last 0.55 s of
# beat 7; the card is silence-padded. Native beat audio dropped.
# Output: clip.mp4 — 1080x1920, 30 fps, 11.00 s, H.264 + AAC,
# faststart.
set -euo pipefail
cd "$(dirname "$0")"

python3 make_assets.py

seg() { # $1=name $2=start $3=end $4=crop_x $5=tag_png $6=dur
  ffmpeg -y -v error \
    -i src/trailer2.mp4 \
    -loop 1 -t "$6" -i "work/$5" \
    -filter_complex "\
[0:v]trim=start=$2:end=$3,setpts=PTS-STARTPTS,crop=486:864:$4:108,scale=1080:1920:flags=lanczos,setsar=1[s];\
[s][1:v]overlay=0:0,format=yuv420p[v]" \
    -map "[v]" -an -c:v libx264 -preset medium -crf 19 -r 30 "work/$1.mp4"
}

seg seg1   6.30   7.40  560 tag1.png 1.10
seg seg2  50.30  51.30 1000 tag2.png 1.00
seg seg3  38.60  39.60  700 tag3.png 1.00
seg seg4 127.00 127.95  480 tag4.png 0.95
seg seg5 138.40 139.35  820 tag5.png 0.95
seg seg6 144.45 145.35  620 tag6.png 0.90
seg seg7 154.40 155.50  717 tag7.png 1.10

ffmpeg -y -v error -loop 1 -t 4.00 -i work/card.png \
  -vf "scale=1080:1920,setsar=1,format=yuv420p" \
  -c:v libx264 -preset medium -crf 19 -r 30 work/seg8.mp4

printf "file 'seg1.mp4'\nfile 'seg2.mp4'\nfile 'seg3.mp4'\nfile 'seg4.mp4'\nfile 'seg5.mp4'\nfile 'seg6.mp4'\nfile 'seg7.mp4'\nfile 'seg8.mp4'\n" > work/list.txt

ffmpeg -y -v error \
  -f concat -safe 0 -i work/list.txt \
  -i src/trailer2.mp4 \
  -filter_complex "\
[1:a]atrim=start=104.00:end=108.70,asetpts=PTS-STARTPTS,asplit=2[m1][m2];\
[m1][m2]acrossfade=d=0.7:c1=tri:c2=tri,volume=0.75,afade=t=in:st=0:d=0.06,afade=t=out:st=6.45:d=0.55,apad=whole_dur=11.00,atrim=end=11.00[aout]" \
  -map 0:v -map "[aout]" \
  -c:v copy -c:a aac -b:a 160k -movflags +faststart \
  clip.mp4

ffprobe -v error -show_entries stream=codec_type,codec_name,width,height,r_frame_rate \
  -show_entries format=duration,size -of default=noprint_wrappers=1 clip.mp4
