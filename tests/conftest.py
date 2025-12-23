"""Pytest fixtures for typst-fillable tests."""

from io import BytesIO

import pytest
from pypdf import PdfWriter

from typst_fillable.models import FieldMetadata, FieldPosition


@pytest.fixture
def sample_text_field():
    """A simple text field."""
    return FieldMetadata(
        fieldName="test_text",
        fieldType="text",
        pos=FieldPosition(page=1, x=100, y=200),
        dimensions={"width": 150, "height": 14},
    )


@pytest.fixture
def sample_checkbox_field():
    """A simple checkbox field."""
    return FieldMetadata(
        fieldName="test_checkbox",
        fieldType="checkbox",
        pos=FieldPosition(page=1, x=100, y=250),
        dimensions={"width": 10, "height": 10},
    )


@pytest.fixture
def sample_textarea_field():
    """A multiline textarea field."""
    return FieldMetadata(
        fieldName="test_textarea",
        fieldType="textarea",
        pos=FieldPosition(page=1, x=100, y=300),
        dimensions={"width": 200, "height": 50},
    )


@pytest.fixture
def sample_radio_fields():
    """A group of radio buttons."""
    return [
        FieldMetadata(
            fieldName="option_a",
            fieldType="radio",
            groupName="test_group",
            pos=FieldPosition(page=1, x=100, y=350),
            dimensions={"width": 8, "height": 8},
        ),
        FieldMetadata(
            fieldName="option_b",
            fieldType="radio",
            groupName="test_group",
            pos=FieldPosition(page=1, x=150, y=350),
            dimensions={"width": 8, "height": 8},
        ),
    ]


@pytest.fixture
def sample_field_with_prefix_suffix():
    """A text field with prefix and suffix."""
    return FieldMetadata(
        fieldName="price_field",
        fieldType="text",
        pos=FieldPosition(page=1, x=100, y=400),
        dimensions={"width": 100, "height": 14},
        prefix="$",
        suffix=".00",
    )


@pytest.fixture
def sample_fill_cell_field():
    """A field that fills a table cell."""
    return FieldMetadata(
        fieldName="cell_field",
        fieldType="text",
        pos=FieldPosition(page=1, x=50, y=100),
        dimensions={"width": 80, "height": 20},
        fillCell=True,
        positionOffset={"x": -5, "y": 5},
        minHeight=28.0,
    )


@pytest.fixture
def blank_pdf_bytes():
    """Generate a blank single-page PDF."""
    buffer = BytesIO()
    writer = PdfWriter()
    writer.add_blank_page(width=612, height=792)
    writer.write(buffer)
    return buffer.getvalue()


@pytest.fixture
def multi_page_pdf_bytes():
    """Generate a blank multi-page PDF."""
    buffer = BytesIO()
    writer = PdfWriter()
    writer.add_blank_page(width=612, height=792)
    writer.add_blank_page(width=612, height=792)
    writer.add_blank_page(width=612, height=792)
    writer.write(buffer)
    return buffer.getvalue()
