"""Genera l'icona dell'app: due elementi di un feed che finisce con un punto."""
from PIL import Image, ImageDraw
import sys

S = 4096  # disegno a 4x e poi riduco, per bordi morbidi
img = Image.new("RGB", (S, S))
top, bottom = (30, 27, 75), (15, 118, 110)  # indaco -> verde acqua
for y in range(S):
    t = y / (S - 1)
    ImageDraw.Draw(img).line([(0, y), (S, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))

d = ImageDraw.Draw(img)
w, h, r, x = 2300, 560, 180, (S - 2300) // 2
d.rounded_rectangle([x, 900, x + w, 900 + h], r, fill=(255, 255, 255))
d.rounded_rectangle([x, 1700, x + w, 1700 + h], r, fill=(196, 222, 226))
c, rad = S // 2, 260
d.ellipse([c - rad, 2900 - rad, c + rad, 2900 + rad], fill=(255, 255, 255))

img.resize((1024, 1024), Image.LANCZOS).save(sys.argv[1])
