// typst-fillable: Form field capture for fillable PDFs
// https://github.com/carpe-diem/typst-fillable

/// Capture a form field's position and metadata for fillable PDF generation.
///
/// This function uses Typst's metadata() and locate() to mark positions where
/// interactive form fields should be placed. The metadata is queried during
/// PDF generation to create fillable form fields.
///
/// Args:
///   field_name: Unique identifier for the form field (required)
///   field_type: Type of field - "text", "textarea", "checkbox", or "radio"
///   dimensions: Dictionary with "width" and "height" in points (optional)
///   group_name: For radio buttons, the group name (optional)
///   fill_cell: If true, field expands to fill table cell (default: false)
///   position_offset: Fine-tune position with (x: Xpt, y: Ypt) (optional)
///   min_width: Minimum width for fill_cell fields (optional)
///   min_height: Minimum height for fill_cell fields (optional)
///   prefix: Text to display before the field, e.g., "$" (optional)
///   suffix: Text to display after the field, e.g., "%" (optional)
///   content: The visual content to display (box, checkbox, etc.)
///
/// Returns:
///   The content with metadata attached for extraction
///
/// Example:
///   #capture_field(
///     field_name: "company_name",
///     field_type: "text",
///   )[
///     #box(width: 200pt, height: 14pt, stroke: 0.5pt + gray, fill: rgb("#f7f9fb"))
///   ]
#let capture_field(
  field_name: "",
  field_type: "text",
  dimensions: (:),
  group_name: none,
  fill_cell: false,
  position_offset: (x: 0, y: 0),
  min_width: none,
  min_height: none,
  prefix: "",
  suffix: "",
  content
) = {
  // Default table row height for inset calculation
  let table_row_height = 4.5pt

  // For fill_cell fields, use layout to get actual cell width and measure content height
  if fill_cell {
    context {
      // Capture position BEFORE layout
      let pos = here().position()
      let measured = measure(content)
      // Add table inset (top + bottom) to measured height to match actual cell height
      let content_with_inset = measured.height + (2 * table_row_height)
      // Use min_height if explicitly provided, otherwise use measured + inset
      let cell_height = if min_height != none { min_height } else { content_with_inset }

      layout(size => {
        box({
          // Emit metadata with cell width from layout and measured height
          metadata((
            fieldName: field_name,
            fieldType: field_type,
            dimensions: (
              width: size.width,
              height: cell_height,
            ),
            groupName: group_name,
            fillCell: fill_cell,
            positionOffset: position_offset,
            minWidth: min_width,
            minHeight: min_height,
            prefix: prefix,
            suffix: suffix,
            pos: (
              page: pos.page,
              x: pos.x,
              y: pos.y,
            ),
          ))
          content
        })
      })
    }
  } else {
    box({
      context {
        let measured = measure(content)
        let pos = here().position()

        // Emit metadata with measured dimensions
        metadata((
          fieldName: field_name,
          fieldType: field_type,
          dimensions: (
            width: measured.width,
            height: measured.height,
          ),
          groupName: group_name,
          fillCell: fill_cell,
          positionOffset: position_offset,
          minWidth: min_width,
          minHeight: min_height,
          prefix: prefix,
          suffix: suffix,
          pos: (
            page: pos.page,
            x: pos.x,
            y: pos.y,
          ),
        ))
      }

      // Render the content inline
      content
    })
  }
}

// ====== HELPER FUNCTIONS ======

/// Create a simple text input box with consistent styling
///
/// Args:
///   field_name: Unique field identifier
///   width: Box width (default: 150pt)
///   height: Box height (default: 14pt)
///   value: Pre-filled value to display (optional)
///   prefix: Text before the field (optional)
///   suffix: Text after the field (optional)
#let text_field(
  field_name,
  width: 150pt,
  height: 14pt,
  value: "",
  prefix: "",
  suffix: "",
) = {
  capture_field(
    field_name: field_name,
    field_type: "text",
    prefix: prefix,
    suffix: suffix,
  )[
    #box(
      width: width,
      height: height,
      stroke: 0.5pt + gray,
      fill: rgb("#f7f9fb"),
      inset: 2pt,
    )[#text(size: 8pt)[#value]]
  ]
}

/// Create a textarea (multiline text input)
///
/// Args:
///   field_name: Unique field identifier
///   width: Box width (default: 100%)
///   height: Box height (default: 40pt)
///   value: Pre-filled value to display (optional)
#let textarea_field(
  field_name,
  width: 100%,
  height: 40pt,
  value: "",
) = {
  capture_field(
    field_name: field_name,
    field_type: "textarea",
    fill_cell: true,
    min_height: height,
  )[
    #box(
      width: width,
      height: height,
      stroke: 0.5pt + gray,
      fill: rgb("#f7f9fb"),
      inset: 4pt,
    )[#text(size: 8pt)[#value]]
  ]
}

/// Create a checkbox
///
/// Args:
///   field_name: Unique field identifier
///   checked: Whether the checkbox is checked (default: false)
///   size: Checkbox size (default: 10pt)
#let checkbox_field(
  field_name,
  checked: false,
  size: 10pt,
) = {
  capture_field(
    field_name: field_name,
    field_type: "checkbox",
    dimensions: (width: size, height: size),
  )[
    #box(
      width: size,
      height: size,
      stroke: 0.5pt + gray,
      fill: rgb("#f7f9fb"),
      inset: 1pt,
    )[
      #if checked [
        #align(center + horizon)[#text(size: 7pt)[X]]
      ]
    ]
  ]
}

/// Create a radio button
///
/// Args:
///   field_name: Unique field identifier (value for this option)
///   group_name: The radio button group name
///   selected: Whether this option is selected (default: false)
///   size: Radio button size (default: 8pt)
#let radio_field(
  field_name,
  group_name,
  selected: false,
  size: 8pt,
) = {
  capture_field(
    field_name: field_name,
    field_type: "radio",
    group_name: group_name,
    dimensions: (width: size, height: size),
  )[
    #box(
      width: size,
      height: size,
      stroke: 0.5pt + gray,
      fill: rgb("#f7f9fb"),
      radius: 50%,
    )[
      #if selected [
        #align(center + horizon)[
          #circle(fill: black, radius: 2pt)
        ]
      ]
    ]
  ]
}
