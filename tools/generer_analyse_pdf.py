#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Génère ANALYSE_FONCTIONNELLE.pdf à partir de ANALYSE_FONCTIONNELLE.md.

Usage (depuis la racine du dépôt) :
    python3 tools/generer_analyse_pdf.py

Dépendances : reportlab, pillow (pip install reportlab pillow)
et des polices DejaVu (présentes dans /usr/share/fonts sous Linux).
Les trois schémas Mermaid du Markdown sont redessinés en images.
"""

from __future__ import annotations

import glob
import math
import os
import re
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(ROOT, "ANALYSE_FONCTIONNELLE.md")
TARGET = os.path.join(ROOT, "ANALYSE_FONCTIONNELLE.pdf")

NAVY = (0x18, 0x28, 0x48)
PURPLE = (0x49, 0x3A, 0x8C)
LIGHT = (0xEE, 0xF1, 0xF8)
GREY = (0x64, 0x74, 0x8B)
BLACK = (0x1F, 0x29, 0x37)
WHITE = (255, 255, 255)


def _find_font(name: str) -> str | None:
    hits = glob.glob(f"/usr/share/fonts/**/{name}", recursive=True)
    return hits[0] if hits else None


def _pil_font(size: int, bold: bool = False):
    path = _find_font("DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf")
    return ImageFont.truetype(path, size) if path else ImageFont.load_default()


def _wrap(draw: ImageDraw.ImageDraw, text: str, font, max_width: int) -> list[str]:
    lines: list[str] = []
    for paragraph in text.split("\n"):
        words, current = paragraph.split(), ""
        for word in words:
            trial = f"{current} {word}".strip()
            if draw.textlength(trial, font=font) <= max_width:
                current = trial
            else:
                if current:
                    lines.append(current)
                current = word
        lines.append(current)
    return lines


def _box(draw, xy, text, *, fill=WHITE, outline=PURPLE, txt=BLACK, size=34, bold=True, radius=26):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=4)
    font = _pil_font(size, bold)
    lines = _wrap(draw, text, font, xy[2] - xy[0] - 36)
    heights = [draw.textbbox((0, 0), line, font=font)[3] for line in lines]
    total = sum(heights) + 8 * (len(lines) - 1)
    y = (xy[1] + xy[3] - total) / 2
    for line, h in zip(lines, heights):
        w = draw.textlength(line, font=font)
        draw.text(((xy[0] + xy[2] - w) / 2, y), line, font=font, fill=txt)
        y += h + 8


def _arrow(draw, start, end, *, color=PURPLE, width=5, both=False, dashed=False):
    if dashed:
        steps = 26
        for i in range(0, steps, 2):
            t0, t1 = i / steps, min((i + 1) / steps, 1)
            draw.line(
                [start[0] + (end[0] - start[0]) * t0, start[1] + (end[1] - start[1]) * t0,
                 start[0] + (end[0] - start[0]) * t1, start[1] + (end[1] - start[1]) * t1],
                fill=color, width=width,
            )
    else:
        draw.line([start, end], fill=color, width=width)
    angle = math.atan2(end[1] - start[1], end[0] - start[0])

    def head(point, direction):
        size = 24
        pts = [
            point,
            (point[0] - size * math.cos(direction - 0.42), point[1] - size * math.sin(direction - 0.42)),
            (point[0] - size * math.cos(direction + 0.42), point[1] - size * math.sin(direction + 0.42)),
        ]
        draw.polygon(pts, fill=color)

    head(end, angle)
    if both:
        head(start, angle + math.pi)


def _label(draw, center, text, size=27):
    font = _pil_font(size)
    lines = _wrap(draw, text, font, 520)
    heights = [draw.textbbox((0, 0), line, font=font)[3] for line in lines]
    y = center[1] - sum(heights) / 2
    for line, h in zip(lines, heights):
        w = draw.textlength(line, font=font)
        draw.rectangle([center[0] - w / 2 - 8, y - 3, center[0] + w / 2 + 8, y + h + 4], fill=WHITE)
        draw.text((center[0] - w / 2, y), line, font=font, fill=GREY)
        y += h + 5


def diagram_contexte(path: str) -> str:
    img = Image.new("RGB", (1680, 940), WHITE)
    d = ImageDraw.Draw(img)
    app = (585, 350, 1095, 560)
    _arrow(d, (430, 175), (1175, 205))
    _arrow(d, (430, 455), (585, 455), both=True)
    _arrow(d, (1010, 360), (1215, 290))
    _arrow(d, (1095, 500), (1180, 645), both=True)
    _arrow(d, (430, 700), (620, 545), dashed=True, color=GREY)
    _box(d, (40, 95, 430, 255), "Mainteneur\ndu contenu", size=32)
    _box(d, (40, 360, 430, 550), "Joueur", size=40)
    _box(d, (40, 615, 430, 785), "Appareil Android", size=33)
    _box(d, app, "Application\nQuiz Game 7", fill=PURPLE, outline=NAVY, txt=WHITE, size=40)
    _box(d, (1180, 120, 1640, 315), "Contenu intégré\nJSON · images · sons", size=32)
    _box(d, (1180, 575, 1640, 770), "Données locales\nscore · progression", size=32)
    _label(d, (805, 150), "intègre avant compilation")
    _label(d, (507, 408), "réponses\nrésultats", size=24)
    _label(d, (1138, 300), "lit", size=25)
    _label(d, (1135, 605), "lit / écrit", size=25)
    img.save(path)
    return path


def diagram_navigation(path: str) -> str:
    img = Image.new("RGB", (1680, 1020), WHITE)
    d = ImageDraw.Draw(img)
    themes, scores, niveaux = (300, 395, 620, 605), (300, 80, 620, 265), (790, 395, 1110, 605)
    quiz, resultat = (1280, 300, 1620, 510), (1280, 680, 1620, 890)
    _arrow(d, (205, 500), (300, 500))
    _arrow(d, (430, 395), (430, 265), both=True)
    _arrow(d, (620, 470), (790, 470), both=True)
    _arrow(d, (1110, 475), (1280, 440))
    _arrow(d, (1450, 510), (1450, 680))
    _arrow(d, (1280, 800), (1085, 600))
    _arrow(d, (1295, 500), (1115, 555), color=GREY)
    _box(d, (35, 440, 205, 560), "Début", fill=LIGHT, size=32)
    _box(d, themes, "Thèmes\n(accueil)", size=36)
    _box(d, scores, "Score total", size=36)
    _box(d, niveaux, "Niveaux\ndu thème", size=36)
    _box(d, quiz, "Quiz", fill=PURPLE, outline=NAVY, txt=WHITE, size=40)
    _box(d, resultat, "Résultat\net correction", size=34)
    _label(d, (505, 330), "voir / retour", size=24)
    _label(d, (705, 425), "choisir", size=24)
    _label(d, (1195, 420), "niveau débloqué", size=23)
    _label(d, (1535, 595), "dernière question", size=23)
    _label(d, (1180, 735), "retour aux niveaux", size=23)
    _label(d, (1205, 535), "abandon", size=23)
    img.save(path)
    return path


def diagram_sequence(path: str) -> str:
    img = Image.new("RGB", (1680, 1320), WHITE)
    d = ImageDraw.Draw(img)
    centers = {"Joueur": 230, "Application": 640, "Contenu local": 1040, "Données locales": 1435}
    for name, cx in centers.items():
        _box(d, (cx - 175, 45, cx + 175, 155), name, fill=NAVY, outline=NAVY, txt=WHITE, size=31)
        for y in range(170, 1260, 34):
            d.line([(cx, y), (cx, y + 17)], fill=GREY, width=3)

    def msg(y, src, dst, text, dash=False, color=PURPLE):
        x1, x2 = centers[src], centers[dst]
        _arrow(d, (x1, y), (x2, y), color=color, dashed=dash, width=4)
        _label(d, ((x1 + x2) / 2, y - 32), text, size=24)

    msg(250, "Joueur", "Application", "Choisir un thème")
    msg(345, "Application", "Contenu local", "Lire les niveaux configurés")
    msg(440, "Application", "Données locales", "Lire les niveaux débloqués")
    msg(535, "Application", "Joueur", "Afficher niveaux et cadenas", dash=True)
    msg(630, "Joueur", "Application", "Choisir un niveau accessible")
    msg(725, "Application", "Contenu local", "Charger et valider les questions")
    d.rounded_rectangle([95, 770, 790, 1075], radius=18, outline=GREY, width=3)
    _label(d, (440, 792), "boucle — pour chaque question", size=24)
    msg(865, "Application", "Joueur", "Présenter question et temps restant", dash=True)
    msg(955, "Joueur", "Application", "Sélectionner une option")
    msg(1042, "Application", "Joueur", "Retour sonore", dash=True)
    _box(d, (835, 880, 1245, 1005), "si délai expiré :\nabsence de réponse", fill=LIGHT, outline=GREY, size=25)
    msg(1135, "Application", "Données locales", "Ajouter les points, débloquer la suite")
    msg(1230, "Application", "Joueur", "Afficher score et correction", dash=True)
    img.save(path)
    return path


# ---------------------------------------------------------------------------
# Conversion Markdown -> PDF (ReportLab)
# ---------------------------------------------------------------------------
from xml.sax.saxutils import escape as _xml_escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.pdfmetrics import registerFontFamily
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas as _canvas
from reportlab.platypus import (
    BaseDocTemplate, Frame, HRFlowable, Image as RLImage, PageBreak,
    PageTemplate, Paragraph, Preformatted, Spacer, Table, TableStyle,
)
from reportlab.platypus.tableofcontents import TableOfContents

C_NAVY = colors.HexColor("#182848")
C_PURPLE = colors.HexColor("#493A8C")
C_LIGHT = colors.HexColor("#EEF1F8")
C_GRID = colors.HexColor("#C9D2E8")
C_GREY = colors.HexColor("#64748B")

_sans = _find_font("DejaVuSans.ttf")
if _sans:
    pdfmetrics.registerFont(TTFont("QGSans", _sans))
    pdfmetrics.registerFont(TTFont("QGSans-Bold", _find_font("DejaVuSans-Bold.ttf")))
    pdfmetrics.registerFont(TTFont("QGMono", _find_font("DejaVuSansMono.ttf")))
    registerFontFamily("QGSans", normal="QGSans", bold="QGSans-Bold",
                       italic="QGSans", boldItalic="QGSans-Bold")
    SANS, SANS_B, MONO = "QGSans", "QGSans-Bold", "QGMono"
else:  # repli (caractères de dessin absents)
    SANS, SANS_B, MONO = "Helvetica", "Helvetica-Bold", "Courier"

ST = {
    "body": ParagraphStyle("QGBody", fontName=SANS, fontSize=9.3, leading=13.4,
                           alignment=TA_JUSTIFY, spaceAfter=5),
    "list": ParagraphStyle("QGList", fontName=SANS, fontSize=9.3, leading=13.2,
                           leftIndent=15, bulletIndent=4, spaceAfter=3),
    "h2": ParagraphStyle("QGH2", fontName=SANS_B, fontSize=15.5, leading=19,
                         textColor=C_NAVY, spaceBefore=6, spaceAfter=7, keepWithNext=1),
    "h3": ParagraphStyle("QGH3", fontName=SANS_B, fontSize=11.8, leading=15,
                         textColor=C_PURPLE, spaceBefore=10, spaceAfter=5, keepWithNext=1),
    "h4": ParagraphStyle("QGH4", fontName=SANS_B, fontSize=10.3, leading=13.5,
                         textColor=C_NAVY, spaceBefore=8, spaceAfter=4, keepWithNext=1),
    "quote": ParagraphStyle("QGQuote", fontName=SANS, fontSize=9.1, leading=13.2,
                            textColor=colors.HexColor("#24304D")),
    "code": ParagraphStyle("QGCode", fontName=MONO, fontSize=6.1, leading=7.6),
    "caption": ParagraphStyle("QGCaption", fontName=SANS, fontSize=8, leading=10,
                              alignment=TA_CENTER, textColor=C_GREY, spaceAfter=8),
    "cell": ParagraphStyle("QGCell", fontName=SANS, fontSize=7.3, leading=9.3),
    "cell5": ParagraphStyle("QGCell5", fontName=SANS, fontSize=6.6, leading=8.5),
    "head": ParagraphStyle("QGHead", fontName=SANS_B, fontSize=7.3, leading=9.3,
                           textColor=colors.white),
    "head5": ParagraphStyle("QGHead5", fontName=SANS_B, fontSize=6.7, leading=8.6,
                            textColor=colors.white),
}
AVAIL = A4[0] - 36 * mm


def inline(text: str) -> str:
    parts, last = [], 0
    text = text.replace("\\*", "\u0001")
    for m in re.finditer(r"`([^`]+)`", text):
        parts.append(("t", text[last:m.start()]))
        parts.append(("c", m.group(1)))
        last = m.end()
    parts.append(("t", text[last:]))
    out = []
    for kind, seg in parts:
        seg = _xml_escape(seg)
        if kind == "c":
            out.append(f'<font name="{MONO}" size="7.6">{seg}</font>')
        else:
            seg = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", seg)
            seg = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", seg)
            seg = re.sub(r"(?<!\*)\*([^*\n]+)\*(?!\*)", r"<i>\1</i>", seg)
            out.append(seg)
    return "".join(out).replace("\u0001", "*")


class NumberedCanvas(_canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved = []

    def showPage(self):
        self._saved.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        total = len(self._saved)
        for state in self._saved:
            self.__dict__.update(state)
            if self._pageNumber > 1:
                self.setFont(SANS, 7.5)
                self.setFillColor(C_GREY)
                self.drawString(18 * mm, A4[1] - 11 * mm,
                                "Quiz Game 7 — Analyse fonctionnelle")
                self.drawRightString(A4[0] - 18 * mm, A4[1] - 11 * mm, "24 octobre 2026")
                self.setStrokeColor(C_GRID)
                self.line(18 * mm, A4[1] - 13 * mm, A4[0] - 18 * mm, A4[1] - 13 * mm)
                self.drawString(18 * mm, 10 * mm, "Quiz Game 7 · Quiz éducatif")
                self.drawRightString(A4[0] - 18 * mm, 10 * mm,
                                     f"Page {self._pageNumber} / {total}")
            super().showPage()
        super().save()


class Doc(BaseDocTemplate):
    def __init__(self, filename):
        super().__init__(filename, pagesize=A4,
                         title="Quiz Game 7 — Analyse fonctionnelle",
                         author="Quiz Game 7",
                         subject="Analyse fonctionnelle de l'application Flutter Quiz éducatif")
        frame = Frame(18 * mm, 16 * mm, AVAIL, A4[1] - 33 * mm, id="normal")
        self.addPageTemplates([PageTemplate(id="page", frames=[frame])])
        self._bookmark_id = 0

    def afterFlowable(self, flowable):
        if isinstance(flowable, Paragraph) and flowable.style.name == "QGH2":
            text = flowable.getPlainText()
            key = f"sec{self._bookmark_id}"
            self._bookmark_id += 1
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(text, key, 0, 0)
            self.notify("TOCEntry", (0, text, self.page))


def make_table(rows: list[list[str]]):
    ncols = max(len(r) for r in rows)
    rows = [r + [""] * (ncols - len(r)) for r in rows]
    small = ncols >= 5
    cs, hs = (ST["cell5"], ST["head5"]) if small else (ST["cell"], ST["head"])
    weights = []
    for c in range(ncols):
        longest = max((len(r[c]) for r in rows), default=8)
        w = math.sqrt(max(10, longest))
        if rows[0][c].strip().lower() in ("code", "pri.", "statut", "ligne", "référence"):
            w = min(w, 2.3)
        weights.append(w)
    widths = [max(30, AVAIL * w / sum(weights)) for w in weights]
    scale = AVAIL / sum(widths)
    widths = [w * scale for w in widths]
    data = [[Paragraph(inline(c), hs if i == 0 else cs) for c in r] for i, r in enumerate(rows)]
    table = Table(data, colWidths=widths, repeatRows=1, splitByRow=1)
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), C_NAVY),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, C_LIGHT]),
        ("GRID", (0, 0), (-1, -1), 0.4, C_GRID),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 3.2),
        ("RIGHTPADDING", (0, 0), (-1, -1), 3.2),
        ("TOPPADDING", (0, 0), (-1, -1), 2.6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 2.6),
    ]))
    return table


def split_row(line: str) -> list[str]:
    line = line.strip().replace("\\|", "\u0002")
    if line.startswith("|"):
        line = line[1:]
    if line.endswith("|"):
        line = line[:-1]
    return [c.strip().replace("\u0002", "|") for c in line.split("|")]


def cover(story: list) -> None:
    center = ParagraphStyle("QGCtr", fontName=SANS, alignment=TA_CENTER)
    story.append(Spacer(1, 22 * mm))
    logo = os.path.join(ROOT, "assets", "logo.png")
    if os.path.isfile(logo):
        story.append(RLImage(logo, width=30 * mm, height=30 * mm, hAlign="CENTER"))
        story.append(Spacer(1, 8 * mm))
    story.append(Paragraph('<font color="#493A8C"><b>ANALYSE FONCTIONNELLE</b></font>',
                           ParagraphStyle("QGKick", parent=center, fontName=SANS_B,
                                            fontSize=13, textColor=C_PURPLE, spaceAfter=6)))
    story.append(Paragraph("Quiz Game 7",
                           ParagraphStyle("QGTitle", parent=center, fontName=SANS_B,
                                          fontSize=34, leading=38, textColor=C_NAVY)))
    story.append(Paragraph("« Quiz éducatif » — application Flutter",
                           ParagraphStyle("QGSub", parent=center, fontSize=15,
                                          textColor=C_GREY, spaceBefore=4, spaceAfter=10)))
    story.append(HRFlowable(width="55%", thickness=2, color=C_PURPLE, hAlign="CENTER"))
    story.append(Spacer(1, 9 * mm))
    quote = Table([[Paragraph(
        "<b>Fonction globale :</b> permettre à un joueur d’apprendre et "
        "d’évaluer ses connaissances au moyen de quiz thématiques "
        "chronométrés à niveaux progressifs, tout en conservant localement "
        "son score total et sa progression.", ST["quote"])]], colWidths=[140 * mm])
    quote.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), C_LIGHT),
        ("LINEBEFORE", (0, 0), (0, -1), 3, C_PURPLE),
        ("LEFTPADDING", (0, 0), (-1, -1), 10), ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (-1, -1), 8), ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
    ]))
    story.append(quote)
    story.append(Spacer(1, 12 * mm))
    meta = [
        ["Produit", "Application mobile Flutter / Android — Quiz Game 7"],
        ["Version du produit", "1.0.0+1"],
        ["Date", "24 octobre 2026"],
        ["Type d’analyse", "Analyse fonctionnelle de l’existant (code restauré et corrigé)"],
        ["Branche analysée", "arena/1ad9ed66-nouveau"],
        ["Documents liés", "README.md · FONCTIONS.md · CORRECTIONS.md"],
    ]
    mdata = [[Paragraph(f"<b>{_xml_escape(a)}</b>", ST["cell"]),
              Paragraph(_xml_escape(b), ST["cell"])] for a, b in meta]
    mtab = Table(mdata, colWidths=[42 * mm, 98 * mm], hAlign="CENTER")
    mtab.setStyle(TableStyle([
        ("GRID", (0, 0), (-1, -1), 0.4, C_GRID),
        ("BACKGROUND", (0, 0), (0, -1), C_LIGHT),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6), ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 4), ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    story.append(mtab)
    story.append(Spacer(1, 14 * mm))
    story.append(Paragraph("Document généré à partir de ANALYSE_FONCTIONNELLE.md",
                           ParagraphStyle("QGNote", parent=center, fontSize=8.5, textColor=C_GREY)))
    story.append(PageBreak())


_SPECIAL = ("#", "|", ">", "`")
_ITEM = re.compile(r"^(\s*)([-*]|\d+\.)\s+(.*)$")


def _starts_special(line: str) -> bool:
    s = line.strip()
    return (not s or s == "---" or s.startswith(("# ", "## ", "### ", "#### ", "|", ">", "```"))
            or bool(_ITEM.match(line)))


def parse(md: str, diagrams: dict[str, tuple[str, int, int]]) -> list:
    lines = md.splitlines()
    story: list = []
    i = 0
    # Sauter le titre et le tableau de fiche initial (repris en page de garde).
    while i < len(lines) and not lines[i].startswith("> **Lecture"):
        i += 1
    while i < len(lines):
        line = lines[i]
        s = line.strip()
        if not s:
            i += 1
            continue
        if s.startswith("```"):
            lang = s[3:].strip()
            block, i = [], i + 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                block.append(lines[i])
                i += 1
            i += 1
            text = "\n".join(block)
            if lang == "mermaid":
                kind = ("contexte" if "flowchart" in text else
                        "navigation" if "stateDiagram" in text else "sequence")
                captions = {"contexte": "Figure 1 — Diagramme de contexte",
                            "navigation": "Figure 2 — Navigation entre écrans",
                            "sequence": "Figure 3 — Séquence d’une partie réussie"}
                path, w, h = diagrams[kind]
                story.append(RLImage(path, width=AVAIL, height=AVAIL * h / w))
                story.append(Paragraph(captions[kind], ST["caption"]))
            else:
                code = Table([[Preformatted(_xml_escape(text), ST["code"])]],
                             colWidths=[AVAIL])
                code.setStyle(TableStyle([
                    ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F7F8FC")),
                    ("BOX", (0, 0), (-1, -1), 0.5, C_GRID),
                    ("LEFTPADDING", (0, 0), (-1, -1), 7), ("TOPPADDING", (0, 0), (-1, -1), 5),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ]))
                story.append(code)
                story.append(Spacer(1, 5))
            continue
        if s == "---":
            story.append(Spacer(1, 3))
            i += 1
            continue
        m = re.match(r"^(#{2,4})\s+(.*)$", s)
        if m:
            level, title = len(m.group(1)), m.group(2).strip()
            if level == 2:
                if re.match(r"^\d+\.", title):
                    story.append(PageBreak())
                story.append(Paragraph(inline(title), ST["h2"]))
                story.append(HRFlowable(width="100%", thickness=1.1, color=C_PURPLE,
                                         spaceAfter=7))
            else:
                story.append(Paragraph(inline(title), ST["h3"] if level == 3 else ST["h4"]))
            i += 1
            continue
        if s.startswith("|") and i + 1 < len(lines) and re.match(r"^[\s:\-\|]+$", lines[i + 1].strip()):
            rows = [split_row(line)]
            i += 2
            while i < len(lines) and lines[i].strip().startswith("|"):
                rows.append(split_row(lines[i]))
                i += 1
            story.append(make_table(rows))
            story.append(Spacer(1, 6))
            continue
        if s.startswith(">"):
            chunks = []
            while i < len(lines) and lines[i].strip().startswith(">"):
                chunks.append(lines[i].strip().lstrip(">").strip())
                i += 1
            box = Table([[Paragraph(inline(" ".join(chunks)), ST["quote"])]],
                        colWidths=[AVAIL])
            box.setStyle(TableStyle([
                ("BACKGROUND", (0, 0), (-1, -1), C_LIGHT),
                ("LINEBEFORE", (0, 0), (0, -1), 3, C_PURPLE),
                ("LEFTPADDING", (0, 0), (-1, -1), 9), ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                ("TOPPADDING", (0, 0), (-1, -1), 6), ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
            ]))
            story.append(box)
            story.append(Spacer(1, 6))
            continue
        if _ITEM.match(line):
            while i < len(lines) and (_ITEM.match(lines[i]) or
                                      (lines[i].startswith("  ") and lines[i].strip())):
                m2 = _ITEM.match(lines[i])
                if m2:
                    bullet, item = m2.group(2), m2.group(3).strip()
                    i += 1
                    while i < len(lines) and lines[i].startswith("  ") and lines[i].strip() \
                            and not _ITEM.match(lines[i]):
                        item += " " + lines[i].strip()
                        i += 1
                    story.append(Paragraph(inline(item), ST["list"],
                                           bulletText="•" if bullet in "-*" else bullet))
                else:
                    i += 1
            story.append(Spacer(1, 3))
            continue
        chunks = [s]
        i += 1
        while i < len(lines) and not _starts_special(lines[i]):
            chunks.append(lines[i].strip())
            i += 1
        story.append(Paragraph(inline(" ".join(chunks)), ST["body"]))
    return story


def main() -> int:
    if not os.path.isfile(SOURCE):
        print(f"source absente : {SOURCE}", file=sys.stderr)
        return 1
    with tempfile.TemporaryDirectory() as tmp:
        diagrams = {}
        for kind, fn in (("contexte", diagram_contexte),
                         ("navigation", diagram_navigation),
                         ("sequence", diagram_sequence)):
            path = fn(os.path.join(tmp, f"{kind}.png"))
            with Image.open(path) as im:
                diagrams[kind] = (path, im.width, im.height)
        with open(SOURCE, encoding="utf-8") as fh:
            md = fh.read()
        story: list = []
        cover(story)
        story.append(Paragraph("Sommaire",
                               ParagraphStyle("QGTocH", fontName=SANS_B, fontSize=16,
                                              textColor=C_NAVY, spaceAfter=8)))
        story.append(HRFlowable(width="100%", thickness=1.1, color=C_PURPLE, spaceAfter=9))
        toc = TableOfContents()
        toc.levelStyles = [ParagraphStyle("QGToc1", fontName=SANS, fontSize=10,
                                          leading=15.5, leftIndent=4)]
        toc.dotsMinLevel = 0
        story.append(toc)
        story.append(PageBreak())
        story.extend(parse(md, diagrams))
        Doc(TARGET).multiBuild(story, canvasmaker=NumberedCanvas)
    print(f"PDF généré : {TARGET} ({os.path.getsize(TARGET) // 1024} Kio)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
