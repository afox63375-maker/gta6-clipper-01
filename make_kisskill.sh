#!/bin/bash
# make_kisskill.sh — builds the round-4 clipper clip: "Kiss and Kill in GTA 6"
#
# What this makes: a 27.7 s vertical (1080x1920) Short. The picture is the
# gameplay panel cropped out of Rio's phone screen recording of a GTA 6
# moment (two beats: the kiss, then the police shooting), the soundtrack is
# the "Hot Together" stretch of the official Trailer 2, and the last 3 s are
# the silent make.fun pitch card.
#
# Inputs (all local files, nothing is downloaded):
#   SRC     Rio's screen recording, 720x1624, 49.7 s
#   TRAILER Grand Theft Auto VI Trailer 2 (music bed only)
#   CARD    make.fun pitch card PNG, 1080x1920
#
# Usage:
#   ./make_kisskill.sh [output.mp4]            full build (default: ./clip.mp4)
#   ./make_kisskill.sh --final-only output.mp4 re-run only step 5 from the
#                                              intermediates of a full build
#                                              (used for the determinism test)
#
# Intermediates live in $WORK (default /tmp/kisskill-r4) so the repo stays
# clean; only the finished clip lands next to this script.

set -euo pipefail

SRC="${SRC:-$HOME/workspace/user/media_library/video/c9/c94374048f05e3ed97d1571d88dab4d587db68d774938376b8346847cc094277.mp4}"
TRAILER="${TRAILER:-$HOME/workspace/makefun/gta6-clipper-01/clip5/src/trailer2.mp4}"
CARD="${CARD:-$HOME/workspace/makefun/gta6-clipper-01/clip9/work/card.png}"
WORK="${WORK:-/tmp/kisskill-r4}"
HERE="$(cd "$(dirname "$0")" && pwd)"

step5_concat() {
    # Step 5: join the 9:16 main part and the card segment into the final
    # clip. Re-encoded (not stream-copied) so the two parts share one codec
    # configuration; the output is deterministic for identical inputs.
    local out="$1"
    printf "file '%s'\nfile '%s'\n" "$WORK/main916.mp4" "$WORK/cardseg.mp4" > "$WORK/final-list.txt"
    ffmpeg -y -loglevel error -f concat -safe 0 -i "$WORK/final-list.txt" \
        -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 160k "$out"
}

if [ "${1:-}" = "--final-only" ]; then
    step5_concat "${2:?usage: make_kisskill.sh --final-only output.mp4}"
    echo "final-only build written to $2"
    exit 0
fi

OUT="${1:-$HERE/clip.mp4}"
mkdir -p "$WORK"

# --- Step 1: cut the two moments out of the screen recording -----------------
# Kiss beat 23.0-31.5 s, shooting beat 33.5-49.7 s. Each beat is re-encoded
# (frame-accurate cuts) keeping the recording's own audio for now; the two
# are then joined with a stream copy.
ffmpeg -y -loglevel error -ss 23 -i "$SRC" -t 8.5 \
    -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 128k "$WORK/seg-kiss.mp4"
ffmpeg -y -loglevel error -ss 33.5 -i "$SRC" -t 16.2 \
    -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 128k "$WORK/seg-shooting.mp4"
printf "file '%s'\nfile '%s'\n" "$WORK/seg-kiss.mp4" "$WORK/seg-shooting.mp4" > "$WORK/join-list.txt"
ffmpeg -y -loglevel error -f concat -safe 0 -i "$WORK/join-list.txt" -c copy "$WORK/joined.mp4"

# --- Step 2: crop to the gameplay panel and lay the Trailer 2 music under it -
# In the 720x1624 recording the gameplay panel is the band y=774..1394, so
# crop 720x620 at y=774 (streamer cam above and comment bar below are cut
# away). Audio comes from Trailer 2 starting at 100.5 s (the "Hot Together"
# window), faded out over the last ~2 s; the recording's own audio is dropped.
ffmpeg -y -loglevel error -i "$WORK/joined.mp4" -ss 100.5 -i "$TRAILER" \
    -map 0:v:0 -map 1:a:0 \
    -vf "crop=720:620:0:774" -af "afade=t=out:st=22.5:d=2" -t 24.7 \
    -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 160k -shortest "$WORK/cropped.mp4"

# --- Step 3: place the cropped picture on a 9:16 canvas ----------------------
# The 720x620 panel is wider than 9:16, so it sits centred over a blurred,
# enlarged copy of itself (no black bars), rendered at 30 fps.
ffmpeg -y -loglevel error -i "$WORK/cropped.mp4" -filter_complex \
    "[0:v]split[a][b];[a]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=45[bg];[b]scale=1080:-2[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,fps=30,format=yuv420p[v]" \
    -map "[v]" -map 0:a -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 160k "$WORK/main916.mp4"

# --- Step 4: the pitch card as a 3 s silent segment --------------------------
ffmpeg -y -loglevel error -loop 1 -i "$CARD" -f lavfi -i anullsrc=r=44100:cl=stereo \
    -t 3 -vf "scale=1080:1920,fps=30,format=yuv420p" \
    -c:v libx264 -preset medium -crf 20 -c:a aac -shortest "$WORK/cardseg.mp4"

# --- Step 5: final join -------------------------------------------------------
step5_concat "$OUT"
echo "clip written to $OUT"
