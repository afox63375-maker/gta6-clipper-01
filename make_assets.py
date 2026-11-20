#!/usr/bin/env python3
"""clip9 assets — "EVERY GTA 6 LOCATION IN 10 SECONDS" location tour.

Draws, with PIL only:
  * tag1.png .. tag7.png — transparent 1080x1920 overlays, one per beat.
    Style: chunky white place-name text, heavy black outline, lower
    third; a small black pill at top-left counts the stops (1/6 ... 6/6,
    FINALE on the skyline). Beat 1 also carries the big hook stack
    "EVERY GTA 6 / LOCATION / IN 10 SECONDS" in the upper half.
  * card.png — the silent 4 s pitch card: official make.fun ghost mark
    on ink #191419 with the bounty pitch lines.

Beat plan (Trailer 2 timecodes frame-verified in this session with
post-input -ss single-frame extraction; see make_clip.sh):
  1 THE KEYS            2 LEONIDA PRISON     3 VICE BEACH
  4 PORT GELLHORN       5 MOUNT KALAGA       6 DOWNTOWN VICE CITY
  7 finale skyline — WELCOME BACK TO VICE CITY
"""
from PIL import Image, ImageDraw, ImageFont

W, H = 1080, 1920
FONT = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
GHOST = ("/home/hatch/workspace/makefun/gta6-meme-x-01/assets/"
         "press-kit/make-fun-press-kit/mark-1024.png")
INK = (25, 20, 25)          # #191419
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
GOLD = (255, 196, 64)


def font(size):
    return ImageFont.truetype(FONT, size)


def fit(draw, text, max_w, start):
    """Largest font size <= start whose text fits max_w."""
    size = start
    while size > 20 and draw.textlength(text, font=font(size)) > max_w:
        size -= 4
    return font(size)


def chunky(draw, cx, y, text, fnt, fill=WHITE, stroke=10):
    """Centre text horizontally at cx, top at y, with black outline."""
    draw.text((cx, y), text, font=fnt, fill=fill, anchor="ma",
              stroke_width=stroke, stroke_fill=BLACK)


def pill(draw, label):
    """Stop counter pill, top-left."""
    f = font(44)
    tw = draw.textlength(label, font=f)
    x0, y0 = 48, 64
    draw.rounded_rectangle([x0, y0, x0 + tw + 56, y0 + 76], radius=38,
                           fill=BLACK)
    draw.text((x0 + 28, y0 + 12), label, font=f, fill=WHITE)


def tag_png(name, lines, pill_label, big=False):
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pill(d, pill_label)
    start = 128 if big else 104
    y = 1330 if len(lines) == 1 else 1270
    for line in lines:
        f = fit(d, line, 980, start)
        chunky(d, W // 2, y, line, f, stroke=12 if big else 10)
        y += int(start * 1.08)
    img.save(f"work/{name}.png")


# Beat 1: hook stack in the upper half + THE KEYS tag at the bottom.
img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
pill(d, "1 / 6")
y = 300
for line in ("EVERY GTA 6", "LOCATION", "IN 10 SECONDS"):
    f = fit(d, line, 1000, 138)
    chunky(d, W // 2, y, line, f, stroke=13)
    y += 152
f = fit(d, "THE KEYS", 980, 104)
chunky(d, W // 2, 1330, "THE KEYS", f, stroke=10)
img.save("work/tag1.png")

tag_png("tag2", ["LEONIDA PRISON"], "2 / 6")
tag_png("tag3", ["VICE BEACH"], "3 / 6")
tag_png("tag4", ["PORT GELLHORN"], "4 / 6")
tag_png("tag5", ["MOUNT KALAGA"], "5 / 6")
tag_png("tag6", ["DOWNTOWN", "VICE CITY"], "6 / 6")
tag_png("tag7", ["WELCOME BACK", "TO VICE CITY"], "FINALE", big=True)

# ---- Pitch card (silent, 4 s) -------------------------------------
card = Image.new("RGBA", (W, H), INK + (255,))
d = ImageDraw.Draw(card)
mark = Image.open(GHOST).convert("RGBA").resize((380, 380),
                                                Image.LANCZOS)
card.alpha_composite(mark, ((W - 380) // 2, 300))
chunky(d, W // 2, 800, "THIS CLIP WAS CUT", fit(d, "THIS CLIP WAS CUT", 980, 84), stroke=6)
chunky(d, W // 2, 905, "BY AN AI AGENT", fit(d, "BY AN AI AGENT", 980, 84), stroke=6)
f = fit(d, "for a $500 BOUNTY on make.fun", 980, 62)
d.text((W // 2, 1080), "for a $500 BOUNTY on make.fun", font=f,
       fill=GOLD, anchor="ma")
f = fit(d, "Make clips with AI. Earn real money.", 980, 56)
d.text((W // 2, 1200), "Make clips with AI. Earn real money.", font=f,
       fill=WHITE, anchor="ma")
f = fit(d, "make.fun/bounty/gta6-clipper-01", 980, 54)
d.text((W // 2, 1420), "make.fun/bounty/gta6-clipper-01", font=f,
       fill=WHITE, anchor="ma")
card.convert("RGB").save("work/card.png")
print("assets done")
