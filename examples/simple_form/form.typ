// Simple fillable form example
// This demonstrates how to use capture_field to create a fillable PDF

// Import the capture_field function
// In a real project, you would import from the package:
// #import "@preview/typst-fillable:0.1.0": capture_field, text_field, checkbox_field

// For now, we define capture_field inline (copy from src/typst_fillable/typst/capture_field.typ)
#let table_row_height = 4.5pt

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
  if fill_cell {
    context {
      let pos = here().position()
      let measured = measure(content)
      let content_with_inset = measured.height + (2 * table_row_height)
      let cell_height = if min_height != none { min_height } else { content_with_inset }

      layout(size => {
        box({
          metadata((
            fieldName: field_name,
            fieldType: field_type,
            dimensions: (width: size.width, height: cell_height),
            groupName: group_name,
            fillCell: fill_cell,
            positionOffset: position_offset,
            minWidth: min_width,
            minHeight: min_height,
            prefix: prefix,
            suffix: suffix,
            pos: (page: pos.page, x: pos.x, y: pos.y),
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
        metadata((
          fieldName: field_name,
          fieldType: field_type,
          dimensions: (width: measured.width, height: measured.height),
          groupName: group_name,
          fillCell: fill_cell,
          positionOffset: position_offset,
          minWidth: min_width,
          minHeight: min_height,
          prefix: prefix,
          suffix: suffix,
          pos: (page: pos.page, x: pos.x, y: pos.y),
        ))
      }
      content
    })
  }
}

// Load context data (optional - for pre-filled forms)
#let ctx = json("context.json")

// Helper to get value from context
#let get(dict, key, default: "") = {
  if dict == none or type(dict) != dictionary { return default }
  if key in dict.keys() { dict.at(key) } else { default }
}

// Colors
#let grey = rgb("#BFC7D5")
#let light_grey = rgb("#f7f9fb")

// Page setup
#set page(margin: 2cm)
#set text(font: "Helvetica", size: 10pt)

// Title
#align(center)[
  #text(size: 18pt, weight: "bold")[Simple Contact Form]
  #v(0.5cm)
]

// Form content
#text(weight: "bold")[Personal Information]
#v(0.3cm)

#grid(
  columns: (120pt, 1fr),
  row-gutter: 12pt,
  [Full Name:],
  capture_field(field_name: "full_name", field_type: "text")[
    #box(width: 250pt, height: 16pt, stroke: 0.5pt + grey, fill: light_grey, inset: 3pt)[
      #text(size: 9pt)[#get(ctx, "full_name")]
    ]
  ],

  [Email:],
  capture_field(field_name: "email", field_type: "text")[
    #box(width: 250pt, height: 16pt, stroke: 0.5pt + grey, fill: light_grey, inset: 3pt)[
      #text(size: 9pt)[#get(ctx, "email")]
    ]
  ],

  [Phone:],
  capture_field(field_name: "phone", field_type: "text")[
    #box(width: 150pt, height: 16pt, stroke: 0.5pt + grey, fill: light_grey, inset: 3pt)[
      #text(size: 9pt)[#get(ctx, "phone")]
    ]
  ],
)

#v(0.5cm)
#text(weight: "bold")[Preferences]
#v(0.3cm)

#grid(
  columns: (auto, auto, 30pt, auto, auto),
  column-gutter: 8pt,
  row-gutter: 10pt,

  capture_field(field_name: "newsletter_yes", field_type: "radio", group_name: "newsletter")[
    #box(width: 12pt, height: 12pt, stroke: 0.5pt + grey, fill: light_grey, radius: 50%)
  ],
  [Subscribe to newsletter],
  [],
  capture_field(field_name: "newsletter_no", field_type: "radio", group_name: "newsletter")[
    #box(width: 12pt, height: 12pt, stroke: 0.5pt + grey, fill: light_grey, radius: 50%)
  ],
  [No thanks],
)

#v(0.3cm)

#grid(
  columns: (auto, auto),
  column-gutter: 8pt,

  capture_field(field_name: "terms_accepted", field_type: "checkbox")[
    #box(width: 12pt, height: 12pt, stroke: 0.5pt + grey, fill: light_grey)
  ],
  [I accept the terms and conditions],
)

#v(0.5cm)
#text(weight: "bold")[Additional Comments]
#v(0.3cm)

#capture_field(
  field_name: "comments",
  field_type: "textarea",
  fill_cell: true,
  min_height: 60pt,
)[
  #box(width: 100%, height: 60pt, stroke: 0.5pt + grey, fill: light_grey, inset: 5pt)[
    #text(size: 9pt)[#get(ctx, "comments")]
  ]
]

#v(1cm)
#align(center)[
  #text(size: 8pt, fill: rgb("#666"))[
    This form was generated with typst-fillable
  ]
]
