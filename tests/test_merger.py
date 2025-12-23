"""Tests for PDF merging functionality."""

from io import BytesIO

from pypdf import PdfReader, PdfWriter

from typst_fillable.merger import merge_with_overlay
from typst_fillable.models import FieldMetadata, FieldPosition
from typst_fillable.overlay import create_form_overlay


class TestMergeWithOverlay:
    """Tests for merge_with_overlay function."""

    def test_basic_merge(self, blank_pdf_bytes, sample_text_field):
        """Test basic PDF merging."""
        overlay = create_form_overlay(
            fields=[sample_text_field],
            page_count=1,
        )

        result = merge_with_overlay(blank_pdf_bytes, overlay)

        assert result is not None
        assert isinstance(result, bytes)

        # Verify result is valid PDF
        reader = PdfReader(BytesIO(result))
        assert len(reader.pages) == 1

    def test_multi_page_merge(self, multi_page_pdf_bytes):
        """Test merging multi-page PDFs."""
        fields = [
            FieldMetadata(
                fieldName=f"field_page_{i}",
                fieldType="text",
                pos=FieldPosition(page=i, x=100, y=200),
                dimensions={"width": 150, "height": 14},
            )
            for i in range(1, 4)
        ]

        overlay = create_form_overlay(
            fields=fields,
            page_count=3,
        )

        result = merge_with_overlay(multi_page_pdf_bytes, overlay)

        reader = PdfReader(BytesIO(result))
        assert len(reader.pages) == 3

    def test_acroform_preserved(self, blank_pdf_bytes, sample_text_field):
        """Test that AcroForm is preserved after merge."""
        overlay = create_form_overlay(
            fields=[sample_text_field],
            page_count=1,
        )

        result = merge_with_overlay(blank_pdf_bytes, overlay)

        reader = PdfReader(BytesIO(result))
        # Check that AcroForm exists in the result
        assert "/AcroForm" in reader.trailer["/Root"]

    def test_merge_with_mixed_fields(
        self,
        blank_pdf_bytes,
        sample_text_field,
        sample_checkbox_field,
    ):
        """Test merging with multiple field types."""
        overlay = create_form_overlay(
            fields=[sample_text_field, sample_checkbox_field],
            page_count=1,
        )

        result = merge_with_overlay(blank_pdf_bytes, overlay)

        reader = PdfReader(BytesIO(result))
        assert len(reader.pages) == 1
        assert "/AcroForm" in reader.trailer["/Root"]

    def test_merge_preserves_base_content(self):
        """Test that base PDF content is preserved."""
        # Create a base PDF with some content
        buffer = BytesIO()
        writer = PdfWriter()
        writer.add_blank_page(width=612, height=792)
        # Note: We can't easily add visible content in tests,
        # but we verify the page dimensions are preserved
        writer.write(buffer)
        base_pdf = buffer.getvalue()

        fields = [
            FieldMetadata(
                fieldName="test",
                fieldType="text",
                pos=FieldPosition(page=1, x=100, y=200),
                dimensions={"width": 150, "height": 14},
            )
        ]

        overlay = create_form_overlay(fields=fields, page_count=1)
        result = merge_with_overlay(base_pdf, overlay)

        reader = PdfReader(BytesIO(result))
        result_page = reader.pages[0]

        # Verify page dimensions are preserved
        assert float(result_page.mediabox.width) == 612
        assert float(result_page.mediabox.height) == 792

    def test_empty_overlay_merge(self, blank_pdf_bytes):
        """Test merging with empty overlay (no fields)."""
        overlay = create_form_overlay(
            fields=[],
            page_count=1,
        )

        result = merge_with_overlay(blank_pdf_bytes, overlay)

        reader = PdfReader(BytesIO(result))
        assert len(reader.pages) == 1
