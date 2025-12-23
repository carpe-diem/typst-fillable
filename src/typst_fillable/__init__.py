"""
typst-fillable: Add interactive form fields to Typst-generated PDFs.

This package allows you to create fillable PDF forms from Typst templates
by extracting field metadata and adding interactive AcroForm fields.

Basic usage:
    from typst_fillable import make_fillable

    fillable_pdf = make_fillable(
        template="form.typ",
        context={"name": "John"},
        root="./templates"
    )

    with open("fillable.pdf", "wb") as f:
        f.write(fillable_pdf)
"""

import json
import shutil
import tempfile
from io import BytesIO
from pathlib import Path

import typst
from pypdf import PdfReader

from .extractor import extract_field_metadata
from .merger import merge_with_overlay
from .models import FieldMetadata, FieldPosition, FieldStyle
from .overlay import create_form_overlay

__version__ = "0.1.0"

__all__ = [
    "make_fillable",
    "compile_template",
    "extract_field_metadata",
    "create_form_overlay",
    "merge_with_overlay",
    "FieldMetadata",
    "FieldPosition",
    "FieldStyle",
]


def compile_template(
    template: str | Path,
    context: dict[str, object] | None = None,
    root: str | Path | None = None,
) -> bytes:
    """
    Compile a Typst template to PDF.

    If context is provided, it will be written to a context.json file
    in the same directory as the template.

    Args:
        template: Path to the Typst template file
        context: Optional dict to serialize as context.json
        root: Root directory for Typst compilation

    Returns:
        PDF bytes
    """
    template_path = Path(template)

    if context is not None:
        # Create temp directory and copy template
        temp_dir = Path(tempfile.mkdtemp())
        try:
            if root:
                # Copy entire root directory
                temp_root = temp_dir / "template"
                shutil.copytree(root, temp_root)
                temp_template = temp_root / template_path.name
            else:
                # Copy just the template file
                temp_root = temp_dir
                temp_template = temp_dir / template_path.name
                shutil.copy(template_path, temp_template)

            # Write context.json
            context_file = temp_template.parent / "context.json"
            with open(context_file, "w") as f:
                json.dump(context, f)

            return typst.compile(str(temp_template), root=str(temp_root))
        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)
    else:
        if root:
            return typst.compile(str(template_path), root=str(root))
        return typst.compile(str(template_path))


def make_fillable(
    template: str | Path,
    context: dict[str, object] | None = None,
    root: str | Path | None = None,
    pdf_bytes: bytes | None = None,
    style: FieldStyle | None = None,
) -> bytes:
    """
    Create a fillable PDF from a Typst template.

    This is the main entry point for the library. It:
    1. Compiles the template (or uses provided pdf_bytes)
    2. Extracts field metadata from the template
    3. Creates an interactive form overlay
    4. Merges everything into a fillable PDF

    Args:
        template: Path to the Typst template file
        context: Optional dict to serialize as context.json for the template
        root: Root directory for Typst compilation
        pdf_bytes: Optional pre-compiled PDF bytes (skips compilation)
        style: Optional styling for form fields

    Returns:
        Fillable PDF bytes

    Example:
        # Generate blank fillable form
        pdf = make_fillable("form.typ", context={})

        # Generate filled form
        pdf = make_fillable("form.typ", context={"name": "John Doe"})

        # Use pre-compiled PDF
        base = typst.compile("form.typ")
        pdf = make_fillable("form.typ", pdf_bytes=base)
    """
    template_path = Path(template)
    root_path = Path(root) if root else None

    # Create temp directory for compilation and metadata extraction
    # Both need context.json to exist for the template to compile
    temp_dir = Path(tempfile.mkdtemp())
    try:
        # Setup temp directory with template and context.json
        if root_path:
            temp_root = temp_dir / "template"
            shutil.copytree(root_path, temp_root)
            temp_template = temp_root / template_path.name
        else:
            temp_root = temp_dir
            temp_template = temp_dir / template_path.name
            shutil.copy(template_path, temp_template)

        # Write context.json (empty dict if not provided)
        context_file = temp_template.parent / "context.json"
        with open(context_file, "w") as f:
            json.dump(context if context is not None else {}, f)

        # Step 1: Compile template or use provided PDF
        if pdf_bytes is None:
            base_pdf = typst.compile(str(temp_template), root=str(temp_root))
        else:
            base_pdf = pdf_bytes

        # Step 2: Extract field metadata (using same temp directory with context.json)
        fields = extract_field_metadata(temp_template, root=temp_root)

        if not fields:
            # No fields to add, return base PDF as-is
            return base_pdf

        # Step 3: Get page count from base PDF
        reader = PdfReader(BytesIO(base_pdf))
        page_count = len(reader.pages)

        # Get page size from first page
        first_page = reader.pages[0]
        page_width = float(first_page.mediabox.width)
        page_height = float(first_page.mediabox.height)

        # Step 4: Create form overlay
        overlay = create_form_overlay(
            fields=fields,
            page_count=page_count,
            page_size=(page_width, page_height),
            style=style,
        )

        # Step 5: Merge base PDF with overlay
        return merge_with_overlay(base_pdf, overlay)

    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)
