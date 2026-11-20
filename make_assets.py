#!/usr/bin/env python3
"""Render the text/brand overlays for the gta6-clipper-01 clip with PIL.

Programmatic text only (Liberation Sans Bold) — crisp at any size, no
AI-generated lettering. Produces, next to this script:
  work/hook.png  1080x1920 transparent hook caption for the trailer moment
  work/card.png  1080x1920 make.fun pitch end-card (ink #191419, magenta #C41C83)
"""
from PIL import Image, ImageDraw, ImageFont

W, H = 1080, 1920
MAGENTA = (196, 28, 131, 255)
INK = (25, 20, 25, 255)
WHITE = (255, 255, 255, 255)
GREY = (178, 170, 178, 255)
BOLD = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
MARK = ("/home/hatch/workspace/makefun/gta6-meme-x-01/assets/"
        "press-kit/make-fun-press-kit/mark-1024.png")


def font(size):
    return ImageFont.truetype(BOLD, size)


def centered(draw, cx, y, text, fnt, fill, stroke=0, stroke_fill=(0, 0, 0, 255)):
    w = draw.textlength(text, font=fnt)
    draw.text((cx - w / 2, y), text, font=fnt, fill=fill,
              stroke_width=stroke, stroke_fill=stroke_fill)
    return fnt.size


def fit_font(draw, text, max_w, start):
    size = start
    while size > 20 and draw.textlength(text, font=font(size)) > max_w:
        size -= 4
    return font(size)


# ---------------------------------------------------------------- hook overlay
hook = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(hook)
cx = W // 2
# soft shadow band behind the caption block for legibility over bright sky
shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow)
sd.rounded_rectangle([70, 92, W - 70, 500], radius=36, fill=(0, 0, 0, 92))
hook = Image.alpha_composite(hook, shadow)
d = ImageDraw.Draw(hook)
y = 118
y += centered(d, cx, y, "WE WAITED", font(96), WHITE, stroke=7) + 26
f_big = fit_font(d, "13 YEARS", 900, 178)
y += centered(d, cx, y, "13 YEARS", f_big, MAGENTA, stroke=8) + 30
centered(d, cx, y, "FOR THIS", font(96), WHITE, stroke=7)
hook.save("work/hook.png")

# ---------------------------------------------------------------- pitch card
card = Image.new("RGBA", (W, H), INK)
d = ImageDraw.Draw(card)
mark = Image.open(MARK).convert("RGBA")
mark_w = 400
mark = mark.resize((mark_w, mark_w), Image.LANCZOS)
card.alpha_composite(mark, ((W - mark_w) // 2, 190))
d = ImageDraw.Draw(card)
y = 660
y += centered(d, cx, y, "THIS CLIP WAS CUT BY", font(58), WHITE) + 14
y += centered(d, cx, y, "AN AI AGENT", font(58), WHITE) + 44
y += centered(d, cx, y, "for a", font(52), GREY) + 20
f_bounty = fit_font(d, "$500 BOUNTY", 920, 150)
y += centered(d, cx, y, "$500 BOUNTY", f_bounty, MAGENTA) + 26
y += centered(d, cx, y, "on make.fun", font(84), WHITE) + 64
d.line([240, y, W - 240, y], fill=MAGENTA, width=6)
y += 48
y += centered(d, cx, y, "Make clips with AI.", font(66), WHITE) + 16
y += centered(d, cx, y, "Earn real money.", font(66), WHITE) + 90
f_url = fit_font(d, "make.fun/bounty/gta6-clipper-01", 980, 52)
centered(d, cx, 1700, "make.fun/bounty/gta6-clipper-01", f_url, MAGENTA)
card.convert("RGB").save("work/card.png")
print("wrote work/hook.png and work/card.png")
