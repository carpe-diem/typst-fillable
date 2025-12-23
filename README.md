# typst-fillable

[![CI](https://github.com/carpe-diem/typst-fillable/actions/workflows/ci.yml/badge.svg)](https://github.com/carpe-diem/typst-fillable/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/carpe-diem/typst-fillable/branch/main/graph/badge.svg)](https://codecov.io/gh/carpe-diem/typst-fillable)
[![PyPI version](https://badge.fury.io/py/typst-fillable.svg)](https://badge.fury.io/py/typst-fillable)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Add interactive form fields to Typst-generated PDFs.

## Overview

`typst-fillable` is a Python library that transforms static Typst PDFs into interactive fillable forms. It extracts field position metadata embedded in Typst templates and overlays interactive AcroForm fields using ReportLab.

**Key features:**
- Create fillable PDFs from Typst templates
- Support for text fields, textareas, checkboxes, and radio buttons
- Customizable field styling
- Works with multi-page documents
- Pre-fill forms with data or generate blank forms

## Installation

```bash
pip install typst-fillable
```

**Requirements:**
- Python 3.10+
- Typst CLI installed and available in PATH

## Quick Start

### 1. Create a Typst template with form fields

```typst
// form.typ
#import "capture_field.typ": capture_field

#let ctx = json("context.json")

Name: #capture_field(field_name: "name", field_type: "text")[
  #box(width: 200pt, height: 14pt, stroke: 0.5pt, fill: rgb("#f7f9fb"))
]

Email: #capture_field(field_name: "email", field_type: "text")[
  #box(width: 200pt, height: 14pt, stroke: 0.5pt, fill: rgb("#f7f9fb"))
]
```

### 2. Generate a fillable PDF

```python
from typst_fillable import make_fillable

# Generate blank fillable form
pdf = make_fillable(
    template="form.typ",
    context={},
    root="./templates"
)

with open("fillable_form.pdf", "wb") as f:
    f.write(pdf)
```

## How It Works

1. **Template Design**: Use `capture_field()` in your Typst template to mark where interactive fields should appear. The function emits metadata about field position and properties.

2. **Metadata Extraction**: When generating a PDF, `typst-fillable` queries the template using `typst.query()` to extract all field metadata.

3. **Overlay Creation**: ReportLab creates a transparent PDF overlay with interactive AcroForm fields at the exact positions specified in the metadata.

4. **Merge**: The base Typst PDF and the form overlay are merged using PyPDF to create the final fillable document.

## API Reference

### `make_fillable()`

The main entry point for generating fillable PDFs.

```python
def make_fillable(
    template: str | Path,
    context: dict | None = None,
    root: str | Path | None = None,
    pdf_bytes: bytes | None = None,
    style: FieldStyle | None = None,
) -> bytes:
```

**Parameters:**
- `template`: Path to the Typst template file
- `context`: Optional dict to pass as `context.json` to the template
- `root`: Root directory for Typst compilation
- `pdf_bytes`: Pre-compiled PDF bytes (skips compilation if provided)
- `style`: Custom styling for form fields

**Returns:** Fillable PDF as bytes

### `extract_field_metadata()`

Extract field positions from a Typst template.

```python
def extract_field_metadata(
    template_path: str | Path,
    root: str | Path | None = None,
) -> list[FieldMetadata]:
```

### `create_form_overlay()`

Create a PDF overlay with interactive form fields.

```python
def create_form_overlay(
    fields: list[FieldMetadata],
    page_count: int,
    page_size: tuple[float, float] = (612.0, 792.0),
    style: FieldStyle | None = None,
) -> BytesIO:
```

### `merge_with_overlay()`

Merge a base PDF with a form field overlay.

```python
def merge_with_overlay(
    base_pdf: bytes,
    form_overlay: BytesIO,
) -> bytes:
```

### `FieldStyle`

Customize form field appearance.

```python
from typst_fillable import FieldStyle

style = FieldStyle(
    fill_color="#ffffff",    # Field background color
    text_color="#000000",    # Text color
    font_size=8,             # Font size in points
    border_width=0,          # Border width (0 for none)
)
```

## Typst Template Guide

### The `capture_field()` Function

```typst
#let capture_field(
  field_name: "",           // Unique field identifier (required)
  field_type: "text",       // "text", "textarea", "checkbox", or "radio"
  dimensions: (:),          // Custom dimensions (optional)
  group_name: none,         // Radio button group name
  fill_cell: false,         // Expand to fill table cell
  position_offset: (x: 0, y: 0),  // Fine-tune position
  min_width: none,          // Minimum width
  min_height: none,         // Minimum height
  prefix: "",               // Text before field (e.g., "$")
  suffix: "",               // Text after field (e.g., "%")
  content                   // Visual content to display
) = { ... }
```

### Field Types

#### Text Field
```typst
#capture_field(field_name: "company", field_type: "text")[
  #box(width: 200pt, height: 14pt, stroke: 0.5pt + gray, fill: rgb("#f7f9fb"))
]
```

#### Textarea (Multiline)
```typst
#capture_field(
  field_name: "comments",
  field_type: "textarea",
  fill_cell: true,
  min_height: 50pt,
)[
  #box(width: 100%, height: 50pt, stroke: 0.5pt + gray, fill: rgb("#f7f9fb"))
]
```

#### Checkbox
```typst
#capture_field(field_name: "agree", field_type: "checkbox")[
  #box(width: 12pt, height: 12pt, stroke: 0.5pt + gray, fill: rgb("#f7f9fb"))
]
```

#### Radio Buttons
```typst
// Same group_name links radio buttons together
#capture_field(field_name: "yes", field_type: "radio", group_name: "answer")[
  #box(width: 10pt, height: 10pt, stroke: 0.5pt + gray, radius: 50%)
] Yes

#capture_field(field_name: "no", field_type: "radio", group_name: "answer")[
  #box(width: 10pt, height: 10pt, stroke: 0.5pt + gray, radius: 50%)
] No
```

### Fields with Prefix/Suffix

```typst
#capture_field(
  field_name: "price",
  field_type: "text",
  prefix: "$",
  suffix: ".00",
)[
  #box(width: 80pt, height: 14pt, stroke: 0.5pt + gray, fill: rgb("#f7f9fb"))
]
```

### Table Cell Fields

For fields inside table cells that should expand to fill the cell:

```typst
#table(
  columns: (1fr, 1fr),
  [Label],
  capture_field(
    field_name: "value",
    field_type: "text",
    fill_cell: true,
    position_offset: (x: -5, y: 5),
  )[
    #text[#ctx.at("value", default: "")]
  ],
)
```

## Examples

See the `examples/` directory for complete working examples:

- `contact_form/` - Professional contact form with sections, radio buttons, and checkboxes
- `survey/` - Customer satisfaction survey with rating scales (1-5) and multiple choice
- `contract/` - Service agreement with signature boxes and legal checkboxes
- `invoice/` - Invoice with line items table, currency fields, and totals

Each example can be run with:

```bash
cd examples/<name>
python generate.py
```

## Development

### Setting up the development environment

This project uses [uv](https://github.com/astral-sh/uv) for fast and reliable Python package management. If you don't have `uv` installed yet:

```bash
# Install uv (macOS/Linux)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or with pip
pip install uv
```

#### Clone and setup

```bash
# Clone the repository
git clone https://github.com/carpe-diem/typst-fillable.git
cd typst-fillable

# Create a virtual environment and install dependencies with uv
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install the package in editable mode with dev dependencies
uv pip install -e ".[dev]"
```

#### Alternative: Using pip

If you prefer to use pip:

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install development dependencies
pip install -e ".[dev]"
```

### Running tests and checks

```bash
# Run tests
pytest

# Run tests with coverage report
pytest --cov=src/typst_fillable --cov-report=term-missing

# Run linter
ruff check .

# Auto-fix linting issues
ruff check . --fix

# Format code
ruff format .

# Type check
mypy src/
```

### Project structure

```
typst-fillable/
├── src/typst_fillable/    # Main package source code
├── tests/                 # Test suite
├── examples/              # Example forms and usage
├── pyproject.toml         # Project configuration
└── README.md             # This file
```

## Contributing

Contributions are welcome! Here's how you can help:

### Reporting bugs

If you find a bug, please [open an issue](https://github.com/carpe-diem/typst-fillable/issues) with:
- A clear description of the problem
- Steps to reproduce the issue
- Expected vs actual behavior
- Your Python and Typst versions

### Suggesting features

Feature requests are welcome! Please [open an issue](https://github.com/carpe-diem/typst-fillable/issues) describing:
- The use case for the feature
- How it would work
- Any alternatives you've considered

### Submitting pull requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Set up your development environment (see Development section above)
4. Make your changes
5. Run tests and checks to ensure everything passes:
   ```bash
   pytest
   ruff check .
   mypy src/
   ```
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to your branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code style

- We use [Ruff](https://docs.astral.sh/ruff/) for linting and formatting
- We use [mypy](https://mypy-lang.org/) for type checking
- Follow PEP 8 guidelines
- Add type hints to all functions
- Write docstrings for public APIs
- Keep line length to 100 characters

### Testing

- Write tests for new features and bug fixes
- Ensure test coverage remains high
- Use descriptive test names
- Add integration tests for end-to-end scenarios

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributors

<a href="https://github.com/carpe-diem/typst-fillable/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=carpe-diem/typst-fillable" />
</a>

## Author

**Alberto Paparelli** ([@carpe-diem](https://github.com/carpe-diem))

---

If you find this project useful, please consider giving it a star!
