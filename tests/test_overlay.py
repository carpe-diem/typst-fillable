"""Tests for the form field overlay creation."""

from io import BytesIO

from pypdf import PdfReader

from typst_fillable.models import FieldMetadata, FieldPosition, FieldStyle
from typst_fillable.overlay import create_form_overlay


class TestCreateFormOverlay:
    """Tests for create_form_overlay function."""

    def test_create_text_field_overlay(self, sample_text_field):
        """Test creation of a text field overlay."""
        overlay = create_form_overlay(
            fields=[sample_text_field],
            page_count=1,
        )

        assert overlay is not None
        assert isinstance(overlay, BytesIO)
        overlay.seek(0)

        # Verify it's a valid PDF
        reader = PdfReader(overlay)
        assert len(reader.pages) == 1

    def test_create_checkbox_overlay(self, sample_checkbox_field):
        """Test creation of a checkbox field overlay."""
        overlay = create_form_overlay(
            fields=[sample_checkbox_field],
            page_count=1,
        )

        assert overlay is not None
        reader = PdfReader(overlay)
        assert len(reader.pages) == 1

    def test_create_textarea_overlay(self, sample_textarea_field):
        """Test creation of a textarea field overlay."""
        overlay = create_form_overlay(
            fields=[sample_textarea_field],
            page_count=1,
        )

        assert overlay is not None
        reader = PdfReader(overlay)
        assert len(reader.pages) == 1

    def test_create_radio_button_overlay(self, sample_radio_fields):
        """Test creation of radio button group overlay."""
        overlay = create_form_overlay(
            fields=sample_radio_fields,
            page_count=1,
        )

        assert overlay is not None
        reader = PdfReader(overlay)
        assert len(reader.pages) == 1

    def test_create_mixed_fields_overlay(
        self,
        sample_text_field,
        sample_checkbox_field,
        sample_textarea_field,
        sample_radio_fields,
    ):
        """Test creation of overlay with mixed field types."""
        all_fields = [
            sample_text_field,
            sample_checkbox_field,
            sample_textarea_field,
            *sample_radio_fields,
        ]

        overlay = create_form_overlay(
            fields=all_fields,
            page_count=1,
        )

        assert overlay is not None
        reader = PdfReader(overlay)
        assert len(reader.pages) == 1

    def test_multi_page_overlay(self, sample_text_field):
        """Test creation of multi-page overlay."""
        # Create fields on different pages
        page1_field = sample_text_field
        page2_field = FieldMetadata(
            fieldName="page2_field",
            fieldType="text",
            pos=FieldPosition(page=2, x=100, y=200),
            dimensions={"width": 150, "height": 14},
        )
        page3_field = FieldMetadata(
            fieldName="page3_field",
            fieldType="text",
            pos=FieldPosition(page=3, x=100, y=200),
            dimensions={"width": 150, "height": 14},
        )

        overlay = create_form_overlay(
            fields=[page1_field, page2_field, page3_field],
            page_count=3,
        )

        reader = PdfReader(overlay)
        assert len(reader.pages) == 3

    def test_custom_page_size(self, sample_text_field):
        """Test overlay with custom page size."""
        # A4 size
        overlay = create_form_overlay(
            fields=[sample_text_field],
            page_count=1,
            page_size=(595.28, 841.89),
        )

        reader = PdfReader(overlay)
        page = reader.pages[0]
        # Check page dimensions are close to A4
        assert abs(float(page.mediabox.width) - 595.28) < 1
        assert abs(float(page.mediabox.height) - 841.89) < 1

    def test_custom_style(self, sample_text_field):
        """Test overlay with custom styling."""
        custom_style = FieldStyle(
            fill_color="#ffffff",
            text_color="#333333",
            font_size=10,
            border_width=1,
        )

        overlay = create_form_overlay(
            fields=[sample_text_field],
            page_count=1,
            style=custom_style,
        )

        assert overlay is not None
        reader = PdfReader(overlay)
        assert len(reader.pages) == 1

    def test_field_with_prefix_suffix(self, sample_field_with_prefix_suffix):
        """Test overlay with prefix/suffix fields."""
        overlay = create_form_overlay(
            fields=[sample_field_with_prefix_suffix],
            page_count=1,
        )

        assert overlay is not None
        reader = PdfReader(overlay)
        assert len(reader.pages) == 1

    def test_fill_cell_field(self, sample_fill_cell_field):
        """Test overlay with fill_cell field."""
        overlay = create_form_overlay(
            fields=[sample_fill_cell_field],
            page_count=1,
        )

        assert overlay is not None
        reader = PdfReader(overlay)
        assert len(reader.pages) == 1

    def test_empty_fields_creates_blank_pages(self):
        """Test that empty fields still creates correct number of pages."""
        overlay = create_form_overlay(
            fields=[],
            page_count=3,
        )

        reader = PdfReader(overlay)
        assert len(reader.pages) == 3

    def test_buffer_position_at_start(self, sample_text_field):
        """Test that returned buffer position is at start."""
        overlay = create_form_overlay(
            fields=[sample_text_field],
            page_count=1,
        )

        assert overlay.tell() == 0
