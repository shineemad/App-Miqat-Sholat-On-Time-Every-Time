#!/usr/bin/env python3
"""Menggambar aset logo Miqat dari glyph Icons.mosque (MaterialIcons).

Menghasilkan:
- assets/logo/miqat_icon.png       : ikon penuh (kotak coral + border hitam + masjid putih)
- assets/logo/miqat_foreground.png : masjid putih di atas transparan (adaptive foreground)
- assets/logo/miqat_splash.png     : logo untuk native splash (kotak coral)
"""
import os

from PIL import Image, ImageDraw, ImageFont

FONT = "/opt/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf"
MOSQUE = chr(0xF053E)
OUT = "assets/logo"

CORAL = (255, 90, 60, 255)
BLACK = (28, 27, 27, 255)
WHITE = (255, 255, 255, 255)

os.makedirs(OUT, exist_ok=True)


def draw_glyph(size, color, glyph_frac):
    """Kanvas transparan size×size dengan glyph masjid di tengah."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT, int(size * glyph_frac))
    bbox = d.textbbox((0, 0), MOSQUE, font=font)
    gw, gh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (size - gw) / 2 - bbox[0]
    y = (size - gh) / 2 - bbox[1]
    d.text((x, y), MOSQUE, font=font, fill=color)
    return img


def make_icon(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    m = int(size * 0.08)
    r = int(size * 0.21)
    bw = max(2, int(size * 0.035))
    d.rounded_rectangle(
        [m, m, size - m, size - m],
        radius=r,
        fill=CORAL,
        outline=BLACK,
        width=bw,
    )
    glyph = draw_glyph(size, WHITE, 0.5)
    img.alpha_composite(glyph)
    return img


def make_foreground(size=1024):
    # Masjid putih, area aman adaptive (~55% agar tak terpotong).
    return draw_glyph(size, WHITE, 0.45)


def make_ios(size=1024):
    # Full-bleed: iOS menerapkan sudut membulat sendiri, jadi tanpa margin,
    # border, maupun transparansi (App Store menolak alpha).
    img = Image.new("RGBA", (size, size), CORAL)
    img.alpha_composite(draw_glyph(size, WHITE, 0.52))
    return img.convert("RGB")


make_icon().save(f"{OUT}/miqat_icon.png")
make_foreground().save(f"{OUT}/miqat_foreground.png")
make_icon().save(f"{OUT}/miqat_splash.png")
make_ios().save(f"{OUT}/miqat_ios.png")
print("Saved logo assets to", OUT)
