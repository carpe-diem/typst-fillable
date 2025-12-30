"""Merge base PDF with form field overlay."""

from io import BytesIO

from pypdf import PdfReader, PdfWriter


def merge_with_overlay(base_pdf: bytes, form_overlay: BytesIO) -> bytes:
    """
    Merge a base PDF with a form field overlay using PyPDF.

    This combines the static Typst-generated PDF with the interactive
    form fields overlay to create a single fillable PDF.

    Args:
        base_pdf: Bytes of the base PDF (from Typst compilation)
        form_overlay: BytesIO buffer containing the form fields overlay

    Returns:
        Bytes of the merged fillable PDF

    Raises:
        RuntimeError: If PDF merging fails
    """
    try:
        base_reader = PdfReader(BytesIO(base_pdf))

        writer = PdfWriter()

        # Add base pages first
        for page in base_reader.pages:
            writer.add_page(page)

        # Append the overlay - this preserves form field structure including radio groups
        writer.append(form_overlay)

        # Remove the duplicate blank pages from the overlay
        # The overlay pages are added after the base pages
        num_base_pages = len(base_reader.pages)
        num_total_pages = len(writer.pages)

        # We need to merge overlay content onto base pages, then remove overlay pages
        for i in range(num_base_pages):
            overlay_page_idx = num_base_pages + i
            if overlay_page_idx < num_total_pages:
                # Merge overlay page content onto base page
                writer.pages[i].merge_page(writer.pages[overlay_page_idx])

        # Remove the extra overlay pages (iterate in reverse to not mess up indices)
        for i in range(num_total_pages - 1, num_base_pages - 1, -1):
            del writer.pages[i]

        output = BytesIO()
        writer.write(output)
        output.seek(0)

        return output.read()

    except Exception as e:
        raise RuntimeError(f"Failed to merge PDF with form fields: {e}") from e
