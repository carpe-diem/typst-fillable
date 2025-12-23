# Examples

This directory contains example templates demonstrating different use cases for `typst-fillable`.

## Quick Start

Each example can be run with:

```bash
cd examples/<example_name>
python generate.py
```

---

## contact_form

A professional contact form with clean sectioned layout.

**Features demonstrated:**
- Text fields (name, email, phone, company)
- Radio button group (contact preference)
- Checkboxes (newsletter, terms)
- Textarea (message)
- Grid-based form layout
- Color-coded sections

**Output:** `contact_form.pdf`

---

## survey

A customer satisfaction survey with rating scales.

**Features demonstrated:**
- Radio button scales (1-5 ratings)
- Multiple choice checkboxes
- Radio groups for single selection
- Textarea for open feedback
- Numbered questions
- Visual scale indicators

**Output:** `survey.pdf`

---

## contract

A simple service agreement with signature sections.

**Features demonstrated:**
- Text fields for parties info
- Date fields
- Currency fields with prefix
- Signature boxes (using textarea)
- Legal acceptance checkboxes
- Formal document structure
- Numbered clauses

**Output:** `contract.pdf`

---

## invoice

A professional invoice with line items table.

**Features demonstrated:**
- Header with company branding
- Table cells with `fill_cell: true`
- Currency fields with `$` prefix
- Calculated totals section
- Grid-based bill-to section
- Position offset for table alignment

**Output:** `invoice.pdf`

---

## File Structure

Each example contains:

```
example_name/
├── form.typ        # Typst template with capture_field markers
├── context.json    # Default context data (empty values for fillable fields)
└── generate.py     # Python script to generate the PDF
```

## Creating Your Own Template

1. Copy an example directory as a starting point
2. Modify `form.typ` with your layout and fields
3. Update `context.json` with your field names
4. Run `python generate.py` to test

### Key Concepts

**capture_field parameters:**
- `field_name`: Unique identifier for the field
- `field_type`: "text", "textarea", "checkbox", or "radio"
- `fill_cell`: Set `true` for table cells to auto-size
- `position_offset`: Fine-tune field position `(x: 0, y: 0)`
- `prefix`/`suffix`: Add text before/after field value
- `group_name`: Group radio buttons together
- `min_width`/`min_height`: Set minimum dimensions

**Design tips:**
- Use consistent colors via design tokens
- Add visual indicators for required fields
- Group related fields in sections
- Test with both empty and filled states
