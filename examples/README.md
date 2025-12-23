# Examples

## simple_form

A basic contact form demonstrating all supported field types:

- Text fields (name, email, phone)
- Radio buttons (newsletter preference)
- Checkbox (terms acceptance)
- Textarea (comments)

### Running the example

```bash
cd examples/simple_form
python generate.py
```

This will create:
- `fillable_form.pdf` - A blank fillable form
- `prefilled_form.pdf` - A form with pre-filled values

### Files

- `form.typ` - The Typst template with capture_field markers
- `context.json` - Default context data (empty values)
- `generate.py` - Python script to generate the PDFs
