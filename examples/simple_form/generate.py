#!/usr/bin/env python3
"""
Example script to generate a fillable PDF from a Typst template.

Usage:
    python generate.py

This will create 'fillable_form.pdf' in the current directory.
"""

from pathlib import Path

# Add parent directory to path for development
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src"))

from typst_fillable import make_fillable


def main():
    # Get the directory containing this script
    script_dir = Path(__file__).parent

    # Generate fillable PDF
    print("Generating fillable PDF...")

    fillable_pdf = make_fillable(
        template=script_dir / "form.typ",
        context={},  # Empty context for blank form
        root=script_dir,
    )

    # Save the result
    output_path = script_dir / "fillable_form.pdf"
    with open(output_path, "wb") as f:
        f.write(fillable_pdf)

    print(f"Created: {output_path}")
    print(f"File size: {len(fillable_pdf):,} bytes")

    # Also generate a pre-filled version
    print("\nGenerating pre-filled PDF...")

    prefilled_pdf = make_fillable(
        template=script_dir / "form.typ",
        context={
            "full_name": "John Doe",
            "email": "john@example.com",
            "phone": "555-1234",
            "comments": "This is a pre-filled form example.",
        },
        root=script_dir,
    )

    prefilled_path = script_dir / "prefilled_form.pdf"
    with open(prefilled_path, "wb") as f:
        f.write(prefilled_pdf)

    print(f"Created: {prefilled_path}")
    print(f"File size: {len(prefilled_pdf):,} bytes")


if __name__ == "__main__":
    main()
