"""Merge base PDF with form field overlay."""

from io import BytesIO

from pypdf import PdfReader, PdfWriter
from pypdf.generic import NameObject


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
        overlay_reader = PdfReader(form_overlay)

        writer = PdfWriter()

        # Merge pages
        for i, page in enumerate(base_reader.pages):
            if i < len(overlay_reader.pages):
                page.merge_page(overlay_reader.pages[i])
            writer.add_page(page)

        # Copy AcroForm from overlay to preserve form fields
        root_obj = overlay_reader.trailer["/Root"]
        if hasattr(root_obj, "__contains__") and "/AcroForm" in root_obj:
            writer._root_object[NameObject("/AcroForm")] = root_obj["/AcroForm"]  # type: ignore[index]

        output = BytesIO()
        writer.write(output)
        output.seek(0)

        return output.read()

    except Exception as e:
        raise RuntimeError(f"Failed to merge PDF with form fields: {e}") from e
