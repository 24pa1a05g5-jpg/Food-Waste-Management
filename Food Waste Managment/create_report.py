from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_ALIGN_VERTICAL
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


ROOT = Path(r"C:\Users\asus\OneDrive\Documents\ChatGPT\Food Waste Managment")
OUTPUT = ROOT / "Food_Waste_Management_Project_Report.docx"
LOGO = Path(r"C:\Users\asus\Downloads\images\vit logo.png")
SCREENSHOTS = [
    ("Home screen", Path(r"C:\Users\asus\OneDrive\Pictures\Screenshots\Screenshot 2026-10-27 165202.png")),
    ("Pantry screen", Path(r"C:\Users\asus\OneDrive\Pictures\Screenshots\Screenshot 2026-10-27 165216.png")),
    ("Donation screen", Path(r"C:\Users\asus\OneDrive\Pictures\Screenshots\Screenshot 2026-10-27 165231.png")),
    ("Profile screen", Path(r"C:\Users\asus\OneDrive\Pictures\Screenshots\Screenshot 2026-10-27 165246.png")),
]

GREEN = "2D6A4F"
LIGHT_GREEN = "E4F3E9"
ORANGE = "E07A3F"
DARK = "1F2925"
GRAY = "66716C"


def shade(cell, color):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), color)
    tc_pr.append(shd)


def borders(table, color="D9D9D9"):
    tbl_pr = table._tbl.tblPr
    borders_el = OxmlElement("w:tblBorders")
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        tag = OxmlElement(f"w:{edge}")
        tag.set(qn("w:val"), "single")
        tag.set(qn("w:sz"), "6")
        tag.set(qn("w:color"), color)
        borders_el.append(tag)
    tbl_pr.append(borders_el)


def set_font(run, size=None, bold=None, color=None, name="Aptos"):
    run.font.name = name
    run._element.rPr.rFonts.set(qn("w:ascii"), name)
    run._element.rPr.rFonts.set(qn("w:hAnsi"), name)
    if size:
        run.font.size = Pt(size)
    if bold is not None:
        run.bold = bold
    if color:
        run.font.color.rgb = RGBColor.from_string(color)


def add_text(doc, text, size=11, bold=False, color=DARK, align=None, before=0, after=7):
    paragraph = doc.add_paragraph()
    if align is not None:
        paragraph.alignment = align
    paragraph.paragraph_format.space_before = Pt(before)
    paragraph.paragraph_format.space_after = Pt(after)
    paragraph.paragraph_format.line_spacing = 1.18
    run = paragraph.add_run(text)
    set_font(run, size=size, bold=bold, color=color)
    return paragraph


def add_heading(doc, text, level=1):
    paragraph = doc.add_paragraph(style=f"Heading {level}")
    paragraph.paragraph_format.space_before = Pt(15 if level == 1 else 10)
    paragraph.paragraph_format.space_after = Pt(6)
    run = paragraph.add_run(text)
    set_font(run, size=15 if level == 1 else 12, bold=True, color="000000")
    return paragraph


def add_bullets(doc, items):
    for item in items:
        paragraph = doc.add_paragraph(style="List Bullet")
        paragraph.paragraph_format.space_after = Pt(3)
        run = paragraph.add_run(item)
        set_font(run, size=10.5, color=DARK)


def code_block(doc, code):
    table = doc.add_table(rows=1, cols=1)
    table.autofit = False
    borders(table, "CAD7D0")
    cell = table.cell(0, 0)
    shade(cell, "F3F7F4")
    cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
    paragraph = cell.paragraphs[0]
    paragraph.paragraph_format.space_before = Pt(6)
    paragraph.paragraph_format.space_after = Pt(6)
    run = paragraph.add_run(code)
    set_font(run, size=8.5, color="183D2C", name="Consolas")


def caption(doc, text):
    paragraph = add_text(doc, text, size=9.5, color=GRAY, align=WD_ALIGN_PARAGRAPH.CENTER, after=12)
    paragraph.runs[0].italic = True


def page_break(doc):
    doc.add_paragraph().add_run().add_break(WD_BREAK.PAGE)


def add_footer(section):
    footer = section.footer
    paragraph = footer.paragraphs[0]
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = paragraph.add_run("Food Waste Management App Project Report")
    set_font(run, size=8, color=GRAY)


def add_info_table(doc):
    table = doc.add_table(rows=5, cols=2)
    table.autofit = False
    table.columns[0].width = Inches(2.0)
    table.columns[1].width = Inches(4.4)
    borders(table)
    data = [
        ("Student Name", "N Sudhakar"),
        ("Registration Number", "24PA1A05G5"),
        ("Department", "Computer Science and Engineering"),
        ("Project Title", "Food Waste Management App"),
        ("Platform", "Flutter and Dart"),
    ]
    for row, (label, value) in zip(table.rows, data):
        row.cells[0].vertical_alignment = WD_ALIGN_VERTICAL.CENTER
        row.cells[1].vertical_alignment = WD_ALIGN_VERTICAL.CENTER
        shade(row.cells[0], LIGHT_GREEN)
        p0 = row.cells[0].paragraphs[0]
        p1 = row.cells[1].paragraphs[0]
        p0.paragraph_format.space_after = Pt(5)
        p1.paragraph_format.space_after = Pt(5)
        r0 = p0.add_run(label)
        r1 = p1.add_run(value)
        set_font(r0, size=10.5, bold=True, color=DARK)
        set_font(r1, size=10.5, color=DARK)


def add_architecture_table(doc):
    table = doc.add_table(rows=1, cols=3)
    table.autofit = False
    borders(table)
    headers = ["Presentation Layer", "Application Layer", "Data and Service Layer"]
    values = [
        "Flutter Material UI\nHome, Pantry, Donate, Profile\nNavigation bar and forms",
        "Stateful widgets\nPantry item management\nExpiry prioritisation\nDonation workflow",
        "In-memory food list\nFuture local database\nNotification service\nDonation partner API",
    ]
    for index, header in enumerate(headers):
        cell = table.cell(0, index)
        shade(cell, GREEN)
        paragraph = cell.paragraphs[0]
        paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = paragraph.add_run(header)
        set_font(run, size=10, bold=True, color="FFFFFF")
    row = table.add_row()
    for index, value in enumerate(values):
        cell = row.cells[index]
        shade(cell, "F6F9F7")
        cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
        paragraph = cell.paragraphs[0]
        paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = paragraph.add_run(value)
        set_font(run, size=9.5, color=DARK)


def build():
    doc = Document()
    section = doc.sections[0]
    section.top_margin = Inches(0.7)
    section.bottom_margin = Inches(0.65)
    section.left_margin = Inches(0.8)
    section.right_margin = Inches(0.8)
    add_footer(section)
    normal = doc.styles["Normal"]
    normal.font.name = "Aptos"
    normal._element.rPr.rFonts.set(qn("w:ascii"), "Aptos")
    normal._element.rPr.rFonts.set(qn("w:hAnsi"), "Aptos")
    normal.font.size = Pt(10.5)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(13)
    p.add_run().add_picture(str(LOGO), width=Inches(1.65))
    add_text(doc, "VISHNU INSTITUTE OF TECHNOLOGY", size=17, bold=True, align=WD_ALIGN_PARAGRAPH.CENTER, after=5)
    add_text(doc, "Department of Computer Science and Engineering", size=12, color=GRAY, align=WD_ALIGN_PARAGRAPH.CENTER, after=30)
    title = doc.add_paragraph(style="Title")
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title.paragraph_format.space_after = Pt(10)
    run = title.add_run("Food Waste Management App")
    set_font(run, size=27, bold=True, color="000000")
    add_text(doc, "Project Report", size=14, bold=True, color=GREEN, align=WD_ALIGN_PARAGRAPH.CENTER, after=34)
    add_info_table(doc)
    add_text(doc, "Submitted by", size=10, color=GRAY, align=WD_ALIGN_PARAGRAPH.CENTER, before=28, after=3)
    add_text(doc, "N Sudhakar", size=15, bold=True, align=WD_ALIGN_PARAGRAPH.CENTER, after=2)
    add_text(doc, "Registration Number  24PA1A05G5", size=10.5, color=GRAY, align=WD_ALIGN_PARAGRAPH.CENTER, after=0)

    page_break(doc)
    add_heading(doc, "Project Description")
    add_text(doc, "The Food Waste Management App is a Flutter mobile application designed to support responsible consumption and production. It helps users record food items, monitor expiry dates, use ingredients before they spoil, and donate surplus food to nearby community partners. The application addresses food waste at the household level through simple daily actions and clear visual reminders.")
    add_heading(doc, "Objectives", level=2)
    add_bullets(doc, [
        "Help users maintain a digital pantry with food category and expiry information.",
        "Highlight food items that should be consumed soon to reduce avoidable waste.",
        "Encourage reuse through recipe suggestions based on available items.",
        "Support food sharing by presenting nearby donation partners.",
        "Promote sustainable habits through an easy and motivating interface.",
    ])
    add_heading(doc, "Core Features", level=2)
    feature_table = doc.add_table(rows=1, cols=2)
    borders(feature_table)
    for cell, text in zip(feature_table.rows[0].cells, ["Feature", "Purpose"]):
        shade(cell, GREEN)
        run = cell.paragraphs[0].add_run(text)
        set_font(run, size=10, bold=True, color="FFFFFF")
    features = [
        ("Home dashboard", "Shows meals saved, money saved, carbon impact, and items that need attention."),
        ("Pantry management", "Stores food items with category labels and the number of days left."),
        ("Add food form", "Allows users to add an item, choose a category, and set a use-by period."),
        ("Donation partners", "Lists nearby community fridges and foundations for surplus food donation."),
        ("Profile settings", "Provides expiry reminder, monthly goal, and help options."),
    ]
    for index, (feature, purpose) in enumerate(features):
        row = feature_table.add_row()
        if index % 2 == 0:
            shade(row.cells[0], "F6F9F7")
            shade(row.cells[1], "F6F9F7")
        for cell, text in zip(row.cells, [feature, purpose]):
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            run = cell.paragraphs[0].add_run(text)
            set_font(run, size=9.5, bold=(cell == row.cells[0]), color=DARK)

    page_break(doc)
    add_heading(doc, "System Architecture")
    add_text(doc, "The app follows a simple layered Flutter architecture. The presentation layer contains responsive Material Design screens. Stateful widgets manage user interactions and pantry data. The current prototype uses in-memory data, while the data layer can later be extended with a local database, notifications, and external donation services.")
    add_architecture_table(doc)
    add_heading(doc, "Application Flow", level=2)
    add_bullets(doc, [
        "The user opens the Home screen and sees impact metrics and food items that require attention.",
        "The Pantry screen displays all tracked items and their remaining days before expiry.",
        "The Add Food action saves a new item with its selected category and usage period.",
        "The Donate screen helps users start a donation request with a nearby partner.",
        "The Profile screen centralises reminders, goals, and food-waste guidance.",
    ])
    add_heading(doc, "Project Structure")
    code_block(doc, "food_waste_management/\n|-- lib/\n|   `-- main.dart             # UI, navigation, and app logic\n|-- pubspec.yaml              # Flutter project configuration\n`-- analysis_options.yaml     # Lint configuration")
    add_text(doc, "The prototype keeps the user interface and basic state management in main.dart. As the app grows, it can be separated into models, screens, reusable widgets, services, and local storage modules.", size=10)

    page_break(doc)
    add_heading(doc, "Code Snippets")
    add_heading(doc, "App Entry and Material Theme", level=2)
    code_block(doc, "void main() => runApp(const SavoraApp());\n\nclass SavoraApp extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      title: 'Savora',\n      theme: ThemeData(useMaterial3: true),\n      home: const MainScreen(),\n    );\n  }\n}")
    add_heading(doc, "Food Item Model", level=2)
    code_block(doc, "class FoodItem {\n  FoodItem({\n    required this.name,\n    required this.category,\n    required this.daysLeft,\n    required this.icon,\n  });\n\n  final String name;\n  final String category;\n  final int daysLeft;\n  final IconData icon;\n}")
    add_heading(doc, "Expiry Priority Logic", level=2)
    code_block(doc, "final urgent = pantry\n    .where((item) => item.daysLeft <= 2)\n    .toList();\n\nfinal isUrgent = item.daysLeft <= 2;\nfinal label = item.daysLeft == 0\n    ? 'Use today'\n    : '${item.daysLeft} days left';")
    add_heading(doc, "Add Food Interaction", level=2)
    code_block(doc, "void _addFood() async {\n  final FoodItem? item = await showModalBottomSheet<FoodItem>(\n    context: context,\n    builder: (_) => const AddFoodSheet(),\n  );\n  if (item != null) setState(() => _pantry.add(item));\n}")

    page_break(doc)
    add_heading(doc, "Application Outputs")
    add_text(doc, "The following screenshots demonstrate the implemented user interface. The app uses an eco-friendly green palette, rounded cards, and a bottom navigation bar to make food management quick and approachable.")
    for index, (name, image) in enumerate(SCREENSHOTS):
        if index > 0:
            page_break(doc)
            add_heading(doc, "Application Outputs")
        image_paragraph = doc.add_paragraph()
        image_paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
        image_paragraph.add_run().add_picture(str(image), width=Inches(6.55))
        caption(doc, f"Figure {index + 1}  {name}")
        descriptions = [
            "The Home screen summarises monthly food-saving impact, highlights items that should be used soon, and offers quick actions.",
            "The Pantry screen displays the tracked food inventory, search input, category details, and expiry status labels.",
            "The Donation screen shows nearby food-sharing partners and provides a direct Donate action for each partner.",
            "The Profile screen provides a focused settings area for expiry reminders, goals, and food-waste help.",
        ]
        add_text(doc, descriptions[index], size=10, after=0)

    page_break(doc)
    add_heading(doc, "Conclusion")
    add_text(doc, "The Food Waste Management App provides a practical digital solution for reducing household food waste. Its pantry tracking, expiry awareness, recipe direction, and donation support encourage users to make sustainable choices before food is discarded. The Flutter implementation provides a clean base for future additions such as database storage, push notifications, barcode scanning, real-time maps, and authenticated user profiles.")
    add_heading(doc, "Future Enhancements", level=2)
    add_bullets(doc, [
        "Local database storage using Hive or SQLite for persistent pantry data.",
        "Scheduled notifications before a food item reaches its expiry date.",
        "Barcode scanning to add packaged food quickly.",
        "Location-based maps for verified community fridges and food banks.",
        "Recipe recommendations based on user preferences and pantry ingredients.",
    ])
    doc.core_properties.title = "Food Waste Management App Project Report"
    doc.core_properties.author = "N Sudhakar"
    doc.save(OUTPUT)


if __name__ == "__main__":
    build()
