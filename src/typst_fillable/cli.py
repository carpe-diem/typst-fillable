"""Command-line interface for typst-fillable.

Installed as the `typst-fillable` console script, so it can be run via
`uvx typst-fillable`, `pipx run typst-fillable`, or after `pip install typst-fillable`.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from . import __version__, make_fillable
from .models import FieldStyle


def _load_context(context_path: Path | None, context_json: str | None) -> dict[str, object]:
    if context_path is not None and context_json is not None:
        raise ValueError("--context and --context-json are mutually exclusive")
    raw = context_json if context_json is not None else "{}"
    if context_path is not None:
        raw = context_path.read_text(encoding="utf-8")
    data: dict[str, object] = json.loads(raw)
    return data


def _build_style(args: argparse.Namespace) -> FieldStyle | None:
    overrides = {
        key: value
        for key, value in (
            ("fill_color", args.fill_color),
            ("text_color", args.text_color),
            ("font_size", args.font_size),
            ("border_width", args.border_width),
        )
        if value is not None
    }
    return FieldStyle(**overrides) if overrides else None


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="typst-fillable",
        description="Generate a fillable PDF from a Typst template.",
    )
    parser.add_argument("template", type=Path, help="Path to the Typst template file (.typ)")
    parser.add_argument(
        "-o",
        "--out",
        type=Path,
        default=None,
        help="Output PDF path (default: <template stem>.pdf in the current directory)",
    )
    parser.add_argument(
        "-r",
        "--root",
        type=Path,
        default=None,
        help="Root directory for Typst compilation (default: the template's parent directory)",
    )
    parser.add_argument(
        "-c",
        "--context",
        type=Path,
        default=None,
        help="Path to a JSON file used to pre-fill the template's context.json",
    )
    parser.add_argument(
        "--context-json",
        default=None,
        help="Inline JSON string used to pre-fill the template (alternative to --context)",
    )
    parser.add_argument(
        "--pdf",
        type=Path,
        default=None,
        help="Path to a pre-compiled PDF to use instead of compiling the template "
        "(the template is still read to extract field metadata)",
    )
    parser.add_argument("--fill-color", default=None, help="Field background color, e.g. #f7f9fb")
    parser.add_argument("--text-color", default=None, help="Field text color, e.g. #000000")
    parser.add_argument("--font-size", type=int, default=None, help="Field font size in points")
    parser.add_argument(
        "--border-width", type=int, default=None, help="Field border width in points (0 for none)"
    )
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    template_path: Path = args.template
    if not template_path.exists():
        parser.error(f"template not found: {template_path}")

    if args.pdf is not None and not args.pdf.exists():
        parser.error(f"pdf not found: {args.pdf}")

    try:
        context = _load_context(args.context, args.context_json)
    except (ValueError, json.JSONDecodeError, OSError) as exc:
        parser.error(str(exc))

    root = args.root if args.root is not None else template_path.parent
    out_path = args.out if args.out is not None else Path(f"{template_path.stem}.pdf")
    style = _build_style(args)
    precompiled_pdf = args.pdf.read_bytes() if args.pdf is not None else None

    if precompiled_pdf is None:
        print(f"Compiling {template_path} ...")
    else:
        print(f"Using pre-compiled {args.pdf}, extracting fields from {template_path} ...")

    fillable_pdf = make_fillable(
        template=template_path,
        context=context,
        root=root,
        pdf_bytes=precompiled_pdf,
        style=style,
    )

    out_path.write_bytes(fillable_pdf)

    print(f"Created: {out_path} ({len(fillable_pdf):,} bytes)")


if __name__ == "__main__":
    main()
