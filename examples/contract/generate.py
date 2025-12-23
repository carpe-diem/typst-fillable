#!/usr/bin/env python3
"""Generate fillable contract PDF."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src"))

from typst_fillable import make_fillable


def main():
    script_dir = Path(__file__).parent

    print("Generating fillable contract...")
    fillable_pdf = make_fillable(
        template=script_dir / "form.typ",
        context={},
        root=script_dir,
    )

    output_path = script_dir / "contract.pdf"
    with open(output_path, "wb") as f:
        f.write(fillable_pdf)

    print(f"Created: {output_path}")
    print(f"File size: {len(fillable_pdf):,} bytes")


if __name__ == "__main__":
    main()
