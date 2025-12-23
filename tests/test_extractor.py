"""Tests for the field metadata extractor."""

import json
from pathlib import Path
from unittest.mock import patch

from typst_fillable.extractor import extract_field_metadata, parse_typst_length


class TestParseTypstLength:
    """Tests for parse_typst_length function."""

    def test_parse_float(self):
        assert parse_typst_length(40.5) == 40.5

    def test_parse_int(self):
        assert parse_typst_length(40) == 40.0

    def test_parse_string_with_pt(self):
        assert parse_typst_length("40pt") == 40.0

    def test_parse_string_float_with_pt(self):
        assert parse_typst_length("40.5pt") == 40.5


class TestExtractFieldMetadata:
    """Tests for extract_field_metadata function."""

    @patch("typst_fillable.extractor.typst.query")
    def test_extract_single_field(self, mock_query):
        """Test extraction of a single text field."""
        mock_query.return_value = json.dumps([
            {
                "value": {
                    "fieldName": "test_field",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "groupName": None,
                    "fillCell": False,
                    "positionOffset": {"x": 0, "y": 0},
                    "pos": {"page": 1, "x": "50pt", "y": "100pt"},
                }
            }
        ])

        fields = extract_field_metadata(Path("test.typ"))

        assert len(fields) == 1
        assert fields[0].fieldName == "test_field"
        assert fields[0].fieldType == "text"
        assert fields[0].pos.x == 50.0
        assert fields[0].pos.y == 100.0
        assert fields[0].dimensions["width"] == 100.0
        assert fields[0].dimensions["height"] == 14.0

    @patch("typst_fillable.extractor.typst.query")
    def test_extract_multiple_field_types(self, mock_query):
        """Test extraction of different field types."""
        mock_query.return_value = json.dumps([
            {
                "value": {
                    "fieldName": "text_field",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "100pt"},
                }
            },
            {
                "value": {
                    "fieldName": "checkbox_field",
                    "fieldType": "checkbox",
                    "dimensions": {"width": "10pt", "height": "10pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "150pt"},
                }
            },
            {
                "value": {
                    "fieldName": "radio_option",
                    "fieldType": "radio",
                    "groupName": "my_group",
                    "dimensions": {"width": "8pt", "height": "8pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "200pt"},
                }
            },
        ])

        fields = extract_field_metadata(Path("test.typ"))

        assert len(fields) == 3
        assert fields[0].fieldType == "text"
        assert fields[1].fieldType == "checkbox"
        assert fields[2].fieldType == "radio"
        assert fields[2].groupName == "my_group"

    @patch("typst_fillable.extractor.typst.query")
    def test_duplicate_field_names_keeps_first(self, mock_query):
        """Test that duplicate field names keep only the first occurrence."""
        mock_query.return_value = json.dumps([
            {
                "value": {
                    "fieldName": "duplicate",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "100pt"},
                }
            },
            {
                "value": {
                    "fieldName": "duplicate",
                    "fieldType": "text",
                    "dimensions": {"width": "200pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "150pt", "y": "100pt"},
                }
            },
        ])

        fields = extract_field_metadata(Path("test.typ"))

        assert len(fields) == 1
        assert fields[0].fieldName == "duplicate"
        assert fields[0].dimensions["width"] == 100.0  # First one

    @patch("typst_fillable.extractor.typst.query")
    def test_empty_field_names_filtered(self, mock_query):
        """Test that empty field names are filtered out."""
        mock_query.return_value = json.dumps([
            {
                "value": {
                    "fieldName": "",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "100pt"},
                }
            },
            {
                "value": {
                    "fieldName": "   ",  # Whitespace only
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "150pt"},
                }
            },
            {
                "value": {
                    "fieldName": "valid_field",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "200pt"},
                }
            },
        ])

        fields = extract_field_metadata(Path("test.typ"))

        assert len(fields) == 1
        assert fields[0].fieldName == "valid_field"

    @patch("typst_fillable.extractor.typst.query")
    def test_field_with_prefix_suffix(self, mock_query):
        """Test extraction of fields with prefix and suffix."""
        mock_query.return_value = json.dumps([
            {
                "value": {
                    "fieldName": "price",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "100pt"},
                    "prefix": "$",
                    "suffix": "%",
                }
            }
        ])

        fields = extract_field_metadata(Path("test.typ"))

        assert len(fields) == 1
        assert fields[0].prefix == "$"
        assert fields[0].suffix == "%"

    @patch("typst_fillable.extractor.typst.query")
    def test_field_with_position_offset(self, mock_query):
        """Test extraction of fields with position offset."""
        mock_query.return_value = json.dumps([
            {
                "value": {
                    "fieldName": "cell_field",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "100pt"},
                    "fillCell": True,
                    "positionOffset": {"x": "-5pt", "y": "5pt"},
                    "minWidth": "80pt",
                    "minHeight": "28pt",
                }
            }
        ])

        fields = extract_field_metadata(Path("test.typ"))

        assert len(fields) == 1
        assert fields[0].fillCell is True
        assert fields[0].positionOffset == {"x": -5.0, "y": 5.0}
        assert fields[0].minWidth == 80.0
        assert fields[0].minHeight == 28.0

    @patch("typst_fillable.extractor.typst.query")
    def test_multi_page_fields(self, mock_query):
        """Test extraction of fields across multiple pages."""
        mock_query.return_value = json.dumps([
            {
                "value": {
                    "fieldName": "page1_field",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "100pt"},
                }
            },
            {
                "value": {
                    "fieldName": "page2_field",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 2, "x": "50pt", "y": "100pt"},
                }
            },
        ])

        fields = extract_field_metadata(Path("test.typ"))

        assert len(fields) == 2
        assert fields[0].pos.page == 1
        assert fields[1].pos.page == 2

    @patch("typst_fillable.extractor.typst.query")
    def test_no_fields_returns_empty_list(self, mock_query):
        """Test that no fields returns empty list."""
        mock_query.return_value = json.dumps([])

        fields = extract_field_metadata(Path("test.typ"))

        assert fields == []

    @patch("typst_fillable.extractor.typst.query")
    def test_invalid_metadata_filtered(self, mock_query):
        """Test that invalid metadata entries are filtered."""
        mock_query.return_value = json.dumps([
            {"value": "not a dict"},  # Invalid: value is string
            {"value": {}},  # Invalid: no fieldName
            {"other_key": {}},  # Invalid: no value key
            {
                "value": {
                    "fieldName": "valid",
                    "fieldType": "text",
                    "dimensions": {"width": "100pt", "height": "14pt"},
                    "pos": {"page": 1, "x": "50pt", "y": "100pt"},
                }
            },
        ])

        fields = extract_field_metadata(Path("test.typ"))

        assert len(fields) == 1
        assert fields[0].fieldName == "valid"
