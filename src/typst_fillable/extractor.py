"""Extract form field metadata from Typst templates."""

import json
from pathlib import Path
from typing import Any

import typst

from .models import FieldMetadata, FieldPosition


def parse_typst_length(value: Any) -> float:
    """Convert Typst length string (e.g., '40pt') to float in points."""
    if isinstance(value, int | float):
        return float(value)
    if isinstance(value, str):
        return float(value.rstrip("pt"))
    return float(value)


def extract_field_metadata(
    template_path: str | Path,
    root: str | Path | None = None,
) -> list[FieldMetadata]:
    """
    Extract form field positions from Typst template using typst.query().

    This uses Typst's metadata() function and query API to extract
    coordinates of form fields from the compiled template. Each field
    uses capture_field() which emits metadata with field properties.

    Args:
        template_path: Path to the Typst template file
        root: Root directory for Typst compilation (optional)

    Returns:
        List of FieldMetadata objects with coordinates and properties

    Raises:
        RuntimeError: If Typst query fails
    """
    template_path = Path(template_path)

    try:
        if root is not None:
            all_metadata = typst.query(str(template_path), "metadata", root=str(root))
        else:
            all_metadata = typst.query(str(template_path), "metadata")

        if isinstance(all_metadata, str):
            all_metadata = json.loads(all_metadata)

        # Filter metadata to only include form fields with valid names
        fields_data = [
            m
            for m in all_metadata
            if isinstance(m.get("value"), dict)
            and "fieldName" in m.get("value", {})
            and m.get("value", {}).get("fieldName", "").strip() != ""
        ]

        fields = []
        seen_field_names: set[str] = set()

        for field_data in fields_data:
            value = field_data.get("value", {})
            field_name = value.get("fieldName", "").strip()

            # Skip duplicates (keep first occurrence only)
            if field_name in seen_field_names:
                continue
            seen_field_names.add(field_name)

            # Extract position from metadata
            pos_data = value.get("pos", {})
            pos = FieldPosition(
                page=pos_data.get("page", 1),
                x=parse_typst_length(pos_data.get("x", 0)),
                y=parse_typst_length(pos_data.get("y", 0)),
            )

            # Extract dimensions from metadata
            dims_data = value.get("dimensions", {})
            dimensions = {
                "width": parse_typst_length(dims_data.get("width", 100)),
                "height": parse_typst_length(dims_data.get("height", 14)),
            }

            # Extract position offset
            offset_data = value.get("positionOffset", {})
            position_offset = {
                "x": parse_typst_length(offset_data.get("x", 0)),
                "y": parse_typst_length(offset_data.get("y", 0)),
            }

            # Extract min dimensions (optional)
            min_width_raw = value.get("minWidth")
            min_height_raw = value.get("minHeight")
            min_width = parse_typst_length(min_width_raw) if min_width_raw is not None else None
            min_height = parse_typst_length(min_height_raw) if min_height_raw is not None else None

            # Extract prefix and suffix (optional)
            prefix = value.get("prefix", "") or ""
            suffix = value.get("suffix", "") or ""

            fields.append(
                FieldMetadata(
                    fieldName=field_name,
                    fieldType=value.get("fieldType", "text"),
                    pos=pos,
                    dimensions=dimensions,
                    groupName=value.get("groupName"),
                    fillCell=value.get("fillCell", False),
                    positionOffset=position_offset,
                    minWidth=min_width,
                    minHeight=min_height,
                    prefix=prefix,
                    suffix=suffix,
                )
            )

        return fields

    except typst.TypstError as e:
        raise RuntimeError(f"Typst query failed: {e}") from e
    except Exception as e:
        raise RuntimeError(f"Failed to extract field metadata: {e}") from e
