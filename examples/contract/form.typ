// Simple Service Agreement - typst-fillable example
// Demonstrates signature boxes, dates, and legal checkboxes

// ============ CAPTURE FIELD FUNCTION ============
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
            fieldName: field_name, fieldType: field_type,
            dimensions: (width: size.width, height: cell_height),
            groupName: group_name, fillCell: fill_cell, positionOffset: position_offset,
            minWidth: min_width, minHeight: min_height, prefix: prefix, suffix: suffix,
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
          fieldName: field_name, fieldType: field_type,
          dimensions: (width: measured.width, height: measured.height),
          groupName: group_name, fillCell: fill_cell, positionOffset: position_offset,
          minWidth: min_width, minHeight: min_height, prefix: prefix, suffix: suffix,
          pos: (page: pos.page, x: pos.x, y: pos.y),
        ))
      }
      content
    })
  }
}

// ============ DESIGN TOKENS ============
#let primary = rgb("#1E3A5F")
#let primary_light = rgb("#E8EEF4")
#let field_bg = rgb("#f7f9fb")
#let border_color = rgb("#94A3B8")
#let text_dark = rgb("#1E293B")
#let text_muted = rgb("#64748B")

// ============ CONTEXT ============
#let ctx = json("context.json")
#let get(dict, key, default: "") = {
  if dict == none or type(dict) != dictionary { return default }
  if key in dict.keys() { dict.at(key) } else { default }
}

// ============ HELPERS ============
#let inline_field(name, width: 150pt) = {
  capture_field(field_name: name, field_type: "text")[
    #box(width: width, height: 14pt, stroke: (bottom: 0.5pt + border_color), inset: (bottom: 1pt))[
      #text(size: 8pt)[#get(ctx, name)]
    ]
  ]
}

// ============ PAGE SETUP ============
#set page(margin: (top: 1.8cm, bottom: 1.8cm, left: 2cm, right: 2cm))
#set text(font: "Helvetica", size: 9pt, fill: text_dark)
#set par(justify: true, leading: 0.65em)

// ============ HEADER ============
#align(center)[
  #text(size: 16pt, weight: "bold", fill: primary, tracking: 0.5pt)[SERVICE AGREEMENT]
  #v(2pt)
  #text(size: 8pt, fill: text_muted)[Contract Reference: SA-2024-001]
]

#v(0.6cm)

// ============ PARTIES ============
#text(size: 9pt, weight: "bold", fill: primary)[1. PARTIES]
#v(0.2cm)

This Service Agreement ("Agreement") is entered into on #inline_field("effective_date", width: 80pt) by and between:

#v(0.25cm)

#box(fill: primary_light, width: 100%, inset: 8pt, radius: 3pt)[
  #grid(
    columns: (60pt, 1fr),
    row-gutter: 6pt,
    text(size: 8pt, weight: "medium")[Provider:], inline_field("provider_name", width: 100%),
    text(size: 8pt, weight: "medium")[Address:], inline_field("provider_address", width: 100%),
    text(size: 8pt, weight: "medium")[Email:], inline_field("provider_email", width: 180pt),
  )
]

#v(0.25cm)

#box(fill: primary_light, width: 100%, inset: 8pt, radius: 3pt)[
  #grid(
    columns: (60pt, 1fr),
    row-gutter: 6pt,
    text(size: 8pt, weight: "medium")[Client:], inline_field("client_name", width: 100%),
    text(size: 8pt, weight: "medium")[Address:], inline_field("client_address", width: 100%),
    text(size: 8pt, weight: "medium")[Email:], inline_field("client_email", width: 180pt),
  )
]

#v(0.4cm)

// ============ SERVICES ============
#text(size: 9pt, weight: "bold", fill: primary)[2. SERVICES]
#v(0.2cm)

The Provider agrees to perform the following services:

#v(0.2cm)
#capture_field(field_name: "services_description", field_type: "textarea", fill_cell: true, min_height: 45pt)[
  #box(width: 100%, height: 45pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 3pt, inset: 6pt)[
    #text(size: 8pt)[#get(ctx, "services_description")]
  ]
]

#v(0.4cm)

// ============ COMPENSATION ============
#text(size: 9pt, weight: "bold", fill: primary)[3. COMPENSATION]
#v(0.2cm)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 16pt,
  [
    Total Amount: #capture_field(field_name: "total_amount", field_type: "text", prefix: "$")[
      #box(width: 80pt, height: 14pt, stroke: (bottom: 0.5pt + border_color), inset: (left: 2pt, bottom: 1pt))[
        #text(size: 8pt)[\$ #get(ctx, "total_amount")]
      ]
    ]
  ],
  [
    Payment Terms: #inline_field("payment_terms", width: 100pt)
  ],
)

#v(0.4cm)

// ============ TERM ============
#text(size: 9pt, weight: "bold", fill: primary)[4. TERM]
#v(0.2cm)

This Agreement shall commence on #inline_field("start_date", width: 80pt) and shall continue until #inline_field("end_date", width: 80pt), unless terminated earlier in accordance with this Agreement.

#v(0.4cm)

// ============ ACKNOWLEDGMENTS ============
#text(size: 9pt, weight: "bold", fill: primary)[5. ACKNOWLEDGMENTS]
#v(0.2cm)

#grid(
  columns: (auto, 1fr),
  row-gutter: 6pt,
  column-gutter: 6pt,

  capture_field(field_name: "ack_read", field_type: "checkbox")[
    #box(width: 10pt, height: 10pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 2pt)
  ],
  text(size: 8pt)[I have read and understand all terms of this Agreement.],

  capture_field(field_name: "ack_authority", field_type: "checkbox")[
    #box(width: 10pt, height: 10pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 2pt)
  ],
  text(size: 8pt)[I have the authority to enter into this Agreement on behalf of the party I represent.],

  capture_field(field_name: "ack_binding", field_type: "checkbox")[
    #box(width: 10pt, height: 10pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 2pt)
  ],
  text(size: 8pt)[I agree that this Agreement is legally binding.],
)

#v(0.6cm)

// ============ SIGNATURES ============
#text(size: 9pt, weight: "bold", fill: primary)[6. SIGNATURES]
#v(0.3cm)

#grid(
  columns: (1fr, 30pt, 1fr),

  // Provider signature
  [
    #text(size: 7pt, weight: "medium", fill: text_muted, tracking: 0.3pt)[PROVIDER]
    #v(0.2cm)
    #capture_field(field_name: "provider_signature", field_type: "text")[
      #box(width: 100%, height: 40pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 3pt)[
        #align(center + horizon)[
          #text(size: 7pt, fill: text_muted)[Signature]
        ]
      ]
    ]
    #v(0.2cm)
    #grid(
      columns: (36pt, 1fr),
      row-gutter: 5pt,
      text(size: 8pt)[Name:], inline_field("provider_signatory", width: 100%),
      text(size: 8pt)[Date:], inline_field("provider_sign_date", width: 80pt),
    )
  ],

  [],

  // Client signature
  [
    #text(size: 7pt, weight: "medium", fill: text_muted, tracking: 0.3pt)[CLIENT]
    #v(0.2cm)
    #capture_field(field_name: "client_signature", field_type: "text")[
      #box(width: 100%, height: 40pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 3pt)[
        #align(center + horizon)[
          #text(size: 7pt, fill: text_muted)[Signature]
        ]
      ]
    ]
    #v(0.2cm)
    #grid(
      columns: (36pt, 1fr),
      row-gutter: 5pt,
      text(size: 8pt)[Name:], inline_field("client_signatory", width: 100%),
      text(size: 8pt)[Date:], inline_field("client_sign_date", width: 80pt),
    )
  ],
)

#v(1cm)

// ============ FOOTER ============
#align(center)[
  #text(size: 7pt, fill: text_muted)[
    Generated with #text(fill: primary)[typst-fillable]
  ]
]
