"""Genera el icono de la app en todos los tamanos que piden Android, iOS y web.

El icono no es un PNG suelto que alguien dibujo una vez: se dibuja aca, asi que
cambiar el color o la forma es editar este archivo y volver a correrlo.

    python tool/icono.py

Necesita Pillow (pip install pillow). No forma parte de la compilacion: los PNG
generados quedan versionados en android/, ios/ y web/.
"""

from PIL import Image, ImageDraw

VERDE = (27, 127, 90)
VERDE_OSCURO = (19, 97, 68)
BLANCO = (255, 255, 255, 255)
SS = 8  # supermuestreo

def bolsa(C, sombra=True):
    """Bolsa de papel en blanco sobre lienzo transparente de lado C."""
    L = C * SS
    im = Image.new('RGBA', (L, L), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    u = lambda f: int(f * L)
    cx = L // 2

    # asa: arco grueso, ancho para que se lea de lejos
    gw = u(0.06)
    d.arc([cx - u(0.165), u(0.06), cx + u(0.165), u(0.06) + u(0.33)],
          start=180, end=360, fill=BLANCO, width=gw)

    # cuerpo: bolsa de papel, lados casi rectos y esquinas suaves
    top, bot = u(0.26), u(0.94)
    ht, hb = u(0.30), u(0.315)
    r = u(0.045)
    d.polygon([(cx - ht, top), (cx + ht, top),
               (cx + hb, bot - r), (cx - hb, bot - r)], fill=BLANCO)
    d.rounded_rectangle([cx - hb, bot - 2 * r, cx + hb, bot], radius=r, fill=BLANCO)

    # doblez del papel: franja recortada (deja ver el fondo)
    fy = u(0.375)
    d.rectangle([cx - ht, fy, cx + ht, fy + u(0.038)], fill=(0, 0, 0, 0))
    return im.resize((C, C), Image.LANCZOS)

def fondo(C):
    """Cuadrado verde con degradado vertical suave."""
    im = Image.new('RGBA', (C, C))
    d = ImageDraw.Draw(im)
    for y in range(C):
        t = y / max(C - 1, 1)
        d.line([(0, y), (C, y)], fill=tuple(
            int(a + (b - a) * t) for a, b in zip(VERDE, VERDE_OSCURO)) + (255,))
    return im

def icono(C, frac=0.72):
    """Ícono completo: fondo verde + bolsa centrada al `frac` del lienzo."""
    im = fondo(C)
    c = int(C * frac)
    im.alpha_composite(bolsa(c), ((C - c) // 2, (C - c) // 2))
    return im


# --- salidas ------------------------------------------------------------------

# Android legacy: el PNG cuadrado que usan los launchers viejos.
LEGACY = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}

# Android adaptativo: el lienzo es de 108dp pero el launcher solo garantiza que
# se vea el circulo central de 72dp, asi que la bolsa va mas chica.
ADAPTATIVO = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324,
              'xxxhdpi': 432}

IOS = {
    'Icon-App-20x20@1x': 20, 'Icon-App-20x20@2x': 40, 'Icon-App-20x20@3x': 60,
    'Icon-App-29x29@1x': 29, 'Icon-App-29x29@2x': 58, 'Icon-App-29x29@3x': 87,
    'Icon-App-40x40@1x': 40, 'Icon-App-40x40@2x': 80, 'Icon-App-40x40@3x': 120,
    'Icon-App-60x60@2x': 120, 'Icon-App-60x60@3x': 180,
    'Icon-App-76x76@1x': 76, 'Icon-App-76x76@2x': 152,
    'Icon-App-83.5x83.5@2x': 167, 'Icon-App-1024x1024@1x': 1024,
}


def generar(raiz='.'):
    import os
    j = lambda *p: os.path.join(raiz, *p)

    # Android: PNG cuadrado
    for dpi, px in LEGACY.items():
        icono(px).save(j('android/app/src/main/res', f'mipmap-{dpi}',
                         'ic_launcher.png'))

    # Android: capa de adelante del icono adaptativo (blanco sobre transparente).
    # La misma imagen sirve de capa monocroma para los iconos tematicos de
    # Android 13: de ahi solo se lee el canal alfa.
    for dpi, px in ADAPTATIVO.items():
        lienzo = Image.new('RGBA', (px, px), (0, 0, 0, 0))
        c = int(px * 0.53)
        lienzo.alpha_composite(bolsa(c), ((px - c) // 2, (px - c) // 2))
        lienzo.save(j('android/app/src/main/res', f'mipmap-{dpi}',
                      'ic_launcher_foreground.png'))

    # iOS no admite transparencia en el icono de la app.
    for nombre, px in IOS.items():
        icono(px).convert('RGB').save(
            j('ios/Runner/Assets.xcassets/AppIcon.appiconset', nombre + '.png'))

    # Web: el icono normal y el "maskable", que el sistema puede recortar en
    # circulo y por eso lleva mas aire alrededor.
    for px in (192, 512):
        icono(px).save(j('web/icons', f'Icon-{px}.png'))
        icono(px, frac=0.55).save(j('web/icons', f'Icon-maskable-{px}.png'))
    icono(16).save(j('web', 'favicon.png'))


if __name__ == '__main__':
    import os
    generar(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
    print('iconos generados')
