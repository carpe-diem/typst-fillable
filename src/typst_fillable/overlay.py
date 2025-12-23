"""Create PDF overlay with interactive form fields using ReportLab."""

from io import BytesIO

from reportlab.lib.colors import HexColor
from reportlab.pdfgen import canvas

from .models import FieldMetadata, FieldStyle


def create_form_overlay(
    fields: list[FieldMetadata],
    page_count: int,
    page_size: tuple[float, float] = (612.0, 792.0),
    style: FieldStyle | None = None,
) -> BytesIO:
    """
    Generate a PDF overlay with interactive form fields using ReportLab's acroform.

    This creates form fields (text inputs, checkboxes, etc.) at the positions
    specified in the field metadata.

    Args:
        fields: List of FieldMetadata objects with coordinates and properties
        page_count: Number of pages in the PDF
        page_size: (width, height) in PDF points (default: US Letter)
        style: Optional styling for form fields

    Returns:
        BytesIO buffer containing the PDF overlay

    Raises:
        RuntimeError: If overlay generation fails
    """
    if style is None:
        style = FieldStyle()

    page_width, page_height = page_size

    try:
        buffer = BytesIO()
        light_grey_fill = HexColor(style.fill_color)
        text_color = HexColor(style.text_color)

        # Group fields by page
        fields_by_page: dict[int, list[FieldMetadata]] = {}
        for field in fields:
            page = field.pos.page
            if page not in fields_by_page:
                fields_by_page[page] = []
            fields_by_page[page].append(field)

        c = canvas.Canvas(buffer, pagesize=(page_width, page_height))
        all_radio_groups: dict[str, list[str]] = {}

        for page_num in range(1, page_count + 1):
            page_fields = fields_by_page.get(page_num, [])
            radio_groups: dict[str, list[dict[str, object]]] = {}

            for field in page_fields:
                field_width = field.dimensions.get("width", 100)
                field_height = field.dimensions.get("height", 14)

                # For fields that should fill table cells
                if field.fillCell:
                    if field.minWidth is not None:
                        field_width = max(field_width, field.minWidth)
                    if field.minHeight is not None:
                        field_height = max(field_height, field.minHeight)

                # Apply position offset
                offset_x = field.positionOffset.get("x", 0)
                offset_y = field.positionOffset.get("y", 0)

                # Compensate for border (not for checkboxes)
                if field.fieldType != "checkbox":
                    offset_x += 1
                    offset_y += -1
                    field_width -= 1
                    field_height -= 1

                # Convert Typst Y coordinate to PDF Y coordinate
                # Typst: Y increases downward from top of page
                # PDF: Y increases upward from bottom of page
                absolute_x = field.pos.x + offset_x
                adjusted_y = field.pos.y  # Y from Typst already includes margin
                pdf_y = page_height - adjusted_y - field_height + offset_y

                # Calculate space for prefix/suffix
                prefix_width = 0
                suffix_width = 0
                text_font_size = 8

                if field.prefix:
                    prefix_width = c.stringWidth(field.prefix, "Helvetica", text_font_size) + 3

                if field.suffix:
                    suffix_width = c.stringWidth(field.suffix, "Helvetica", text_font_size) + 6

                # Adjust field position and width for prefix/suffix
                field_x = absolute_x + prefix_width
                actual_field_width = max(field_width - prefix_width - suffix_width, 20)

                # Use smaller font for fields with prefix/suffix
                field_font_size = 6 if (field.prefix or field.suffix) else style.font_size

                if field.fieldType == "text":
                    c.acroForm.textfield(
                        name=field.fieldName,
                        x=field_x,
                        y=pdf_y,
                        width=actual_field_width,
                        height=field_height,
                        borderWidth=style.border_width,
                        fillColor=light_grey_fill,
                        textColor=text_color,
                        forceBorder=False,
                        annotationFlags="print",
                        fontSize=field_font_size,
                        fieldFlags="",
                    )
                elif field.fieldType == "textarea":
                    c.acroForm.textfield(
                        name=field.fieldName,
                        x=field_x,
                        y=pdf_y,
                        width=actual_field_width,
                        height=field_height,
                        borderWidth=style.border_width,
                        fillColor=light_grey_fill,
                        textColor=text_color,
                        forceBorder=False,
                        annotationFlags="print",
                        fontSize=style.font_size,
                        fieldFlags="multiline",
                    )
                elif field.fieldType == "checkbox":
                    c.acroForm.checkbox(
                        name=field.fieldName,
                        x=absolute_x,
                        y=pdf_y,
                        size=field.dimensions.get("width", 10),
                        borderWidth=style.border_width,
                        fillColor=light_grey_fill,
                        forceBorder=False,
                        annotationFlags="print",
                    )
                elif field.fieldType == "radio":
                    group_name = field.groupName or field.fieldName
                    if group_name not in radio_groups:
                        radio_groups[group_name] = []
                    radio_groups[group_name].append(
                        {
                            "value": field.fieldName,
                            "x": absolute_x,
                            "y": pdf_y,
                            "size": field.dimensions.get("width", 5),
                        }
                    )

            # Create radio button groups
            for group_name, buttons in radio_groups.items():
                if group_name not in all_radio_groups:
                    all_radio_groups[group_name] = []

                for button in buttons:
                    c.acroForm.radio(
                        name=group_name,
                        value=button["value"],
                        x=button["x"],
                        y=button["y"],
                        size=button["size"],
                        buttonStyle="check",
                        borderWidth=style.border_width,
                        fillColor=light_grey_fill,
                        forceBorder=False,
                        selected=False,
                        annotationFlags="print",
                    )
                    all_radio_groups[group_name].append(str(button["value"]))

            c.showPage()

        c.save()
        buffer.seek(0)
        return buffer

    except Exception as e:
        raise RuntimeError(f"Failed to create form field overlay: {e}") from e
