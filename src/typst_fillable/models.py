"""Pydantic models for form field metadata."""

from pydantic import BaseModel


class FieldPosition(BaseModel):
    """Position of a form field in the PDF."""

    page: int
    x: float
    y: float


class FieldMetadata(BaseModel):
    """Metadata for a form field extracted from Typst template."""

    fieldName: str
    fieldType: str  # text, textarea, checkbox, radio
    pos: FieldPosition
    dimensions: dict[str, float]
    groupName: str | None = None
    fillCell: bool = False
    positionOffset: dict[str, float] = {"x": 0, "y": 0}
    minWidth: float | None = None
    minHeight: float | None = None
    prefix: str = ""
    suffix: str = ""


class FieldStyle(BaseModel):
    """Styling options for form fields."""

    fill_color: str = "#f7f9fb"
    text_color: str = "#000000"
    font_size: int = 8
    border_width: int = 0
