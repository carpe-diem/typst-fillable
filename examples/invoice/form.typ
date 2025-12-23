// Invoice Template - typst-fillable example
// Demonstrates tables, currency fields, and calculated totals

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
#let primary = rgb("#059669")
#let primary_dark = rgb("#047857")
#let primary_light = rgb("#D1FAE5")
#let field_bg = rgb("#f7f9fb")
#let border_color = rgb("#CBD5E1")
#let text_dark = rgb("#1E293B")
#let text_muted = rgb("#64748B")

// ============ CONTEXT ============
#let ctx = json("context.json")
#let get(dict, key, default: "") = {
  if dict == none or type(dict) != dictionary { return default }
  if key in dict.keys() { dict.at(key) } else { default }
}

// ============ HELPERS ============
#let inline_field(name, width: 150pt, align_right: false) = {
  capture_field(field_name: name, field_type: "text")[
    #box(width: width, height: 18pt, fill: field_bg, stroke: 0.5pt + border_color, radius: 2pt, inset: 4pt)[
      #if align_right [
        #align(right)[#text(size: 9pt)[#get(ctx, name)]]
      ] else [
        #text(size: 9pt)[#get(ctx, name)]
      ]
    ]
  ]
}

#let currency_field(name, width: 80pt) = {
  capture_field(field_name: name, field_type: "text", prefix: "$")[
    #box(width: width, height: 18pt, fill: field_bg, stroke: 0.5pt + border_color, radius: 2pt, inset: 4pt)[
      #grid(
        columns: (auto, 1fr),
        text(size: 9pt, fill: text_muted)[\$],
        align(right)[#text(size: 9pt)[#get(ctx, name)]],
      )
    ]
  ]
}

// ============ PAGE SETUP ============
#set page(margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm))
#set text(font: "Helvetica", size: 10pt, fill: text_dark)

// ============ HEADER ============
#grid(
  columns: (1fr, auto),
  align: (left, right),

  // Company info
  [
    #box(fill: primary, inset: 10pt, radius: 4pt)[
      #text(size: 16pt, weight: "bold", fill: white)[ACME Corp]
    ]
    #v(8pt)
    #text(size: 9pt, fill: text_muted)[
      123 Business Street \
      City, State 12345 \
      contact\@acme.com
    ]
  ],

  // Invoice title
  [
    #text(size: 28pt, weight: "bold", fill: primary)[INVOICE]
    #v(8pt)
    #grid(
      columns: (auto, auto),
      column-gutter: 8pt,
      row-gutter: 4pt,
      align: (right, left),
      text(size: 9pt, fill: text_muted)[Invoice \#:], inline_field("invoice_number", width: 100pt),
      text(size: 9pt, fill: text_muted)[Date:], inline_field("invoice_date", width: 100pt),
      text(size: 9pt, fill: text_muted)[Due Date:], inline_field("due_date", width: 100pt),
    )
  ],
)

#v(1cm)

// ============ BILL TO ============
#grid(
  columns: (1fr, 1fr),
  column-gutter: 40pt,

  [
    #box(fill: primary_light, width: 100%, inset: (left: 8pt, top: 4pt, bottom: 4pt), radius: (left: 4pt))[
      #text(size: 9pt, weight: "bold", fill: primary_dark)[BILL TO]
    ]
    #v(8pt)
    #grid(
      columns: (60pt, 1fr),
      row-gutter: 6pt,
      text(size: 9pt, fill: text_muted)[Name:], inline_field("client_name", width: 100%),
      text(size: 9pt, fill: text_muted)[Company:], inline_field("client_company", width: 100%),
      text(size: 9pt, fill: text_muted)[Address:], inline_field("client_address", width: 100%),
      text(size: 9pt, fill: text_muted)[Email:], inline_field("client_email", width: 100%),
    )
  ],

  [
    #box(fill: primary_light, width: 100%, inset: (left: 8pt, top: 4pt, bottom: 4pt), radius: (left: 4pt))[
      #text(size: 9pt, weight: "bold", fill: primary_dark)[PAYMENT INFO]
    ]
    #v(8pt)
    #grid(
      columns: (70pt, 1fr),
      row-gutter: 6pt,
      text(size: 9pt, fill: text_muted)[Bank:], inline_field("bank_name", width: 100%),
      text(size: 9pt, fill: text_muted)[Account:], inline_field("account_number", width: 100%),
      text(size: 9pt, fill: text_muted)[Routing:], inline_field("routing_number", width: 100%),
    )
  ],
)

#v(1cm)

// ============ LINE ITEMS TABLE ============
#table(
  columns: (2fr, 4fr, 1fr, 1.2fr, 1.2fr),
  stroke: 0.5pt + border_color,
  inset: 8pt,
  align: (left, left, center, right, right),

  // Header
  table.cell(fill: primary)[#text(fill: white, weight: "bold", size: 9pt)[Item]],
  table.cell(fill: primary)[#text(fill: white, weight: "bold", size: 9pt)[Description]],
  table.cell(fill: primary)[#text(fill: white, weight: "bold", size: 9pt)[Qty]],
  table.cell(fill: primary)[#text(fill: white, weight: "bold", size: 9pt)[Unit Price]],
  table.cell(fill: primary)[#text(fill: white, weight: "bold", size: 9pt)[Amount]],

  // Row 1
  capture_field(field_name: "item1_name", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #text(size: 9pt)[#get(ctx, "item1_name")]
  ],
  capture_field(field_name: "item1_desc", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #text(size: 9pt)[#get(ctx, "item1_desc")]
  ],
  capture_field(field_name: "item1_qty", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #align(center)[#text(size: 9pt)[#get(ctx, "item1_qty")]]
  ],
  capture_field(field_name: "item1_price", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8), prefix: "$")[
    #align(right)[#text(size: 9pt)[#get(ctx, "item1_price")]]
  ],
  capture_field(field_name: "item1_amount", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8), prefix: "$")[
    #align(right)[#text(size: 9pt)[#get(ctx, "item1_amount")]]
  ],

  // Row 2
  capture_field(field_name: "item2_name", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #text(size: 9pt)[#get(ctx, "item2_name")]
  ],
  capture_field(field_name: "item2_desc", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #text(size: 9pt)[#get(ctx, "item2_desc")]
  ],
  capture_field(field_name: "item2_qty", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #align(center)[#text(size: 9pt)[#get(ctx, "item2_qty")]]
  ],
  capture_field(field_name: "item2_price", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8), prefix: "$")[
    #align(right)[#text(size: 9pt)[#get(ctx, "item2_price")]]
  ],
  capture_field(field_name: "item2_amount", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8), prefix: "$")[
    #align(right)[#text(size: 9pt)[#get(ctx, "item2_amount")]]
  ],

  // Row 3
  capture_field(field_name: "item3_name", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #text(size: 9pt)[#get(ctx, "item3_name")]
  ],
  capture_field(field_name: "item3_desc", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #text(size: 9pt)[#get(ctx, "item3_desc")]
  ],
  capture_field(field_name: "item3_qty", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #align(center)[#text(size: 9pt)[#get(ctx, "item3_qty")]]
  ],
  capture_field(field_name: "item3_price", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8), prefix: "$")[
    #align(right)[#text(size: 9pt)[#get(ctx, "item3_price")]]
  ],
  capture_field(field_name: "item3_amount", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8), prefix: "$")[
    #align(right)[#text(size: 9pt)[#get(ctx, "item3_amount")]]
  ],

  // Row 4
  capture_field(field_name: "item4_name", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #text(size: 9pt)[#get(ctx, "item4_name")]
  ],
  capture_field(field_name: "item4_desc", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #text(size: 9pt)[#get(ctx, "item4_desc")]
  ],
  capture_field(field_name: "item4_qty", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8))[
    #align(center)[#text(size: 9pt)[#get(ctx, "item4_qty")]]
  ],
  capture_field(field_name: "item4_price", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8), prefix: "$")[
    #align(right)[#text(size: 9pt)[#get(ctx, "item4_price")]]
  ],
  capture_field(field_name: "item4_amount", field_type: "text", fill_cell: true, position_offset: (x: -8, y: 8), prefix: "$")[
    #align(right)[#text(size: 9pt)[#get(ctx, "item4_amount")]]
  ],
)

#v(0.5cm)

// ============ TOTALS ============
#align(right)[
  #box(width: 250pt)[
    #grid(
      columns: (1fr, 100pt),
      row-gutter: 8pt,
      align: (right, right),

      text(size: 10pt)[Subtotal:],
      currency_field("subtotal"),

      text(size: 10pt)[Tax (10%):],
      currency_field("tax"),

      text(size: 10pt)[Discount:],
      currency_field("discount"),

      grid.cell(colspan: 2)[#line(length: 100%, stroke: 0.5pt + border_color)],

      text(size: 12pt, weight: "bold", fill: primary)[TOTAL:],
      box(fill: primary, inset: 6pt, radius: 4pt)[
        #capture_field(field_name: "total", field_type: "text", prefix: "$")[
          #text(size: 12pt, weight: "bold", fill: white)[\$ #get(ctx, "total")]
        ]
      ],
    )
  ]
]

#v(1cm)

// ============ NOTES ============
#text(size: 10pt, weight: "bold", fill: primary)[Notes]
#v(4pt)
#capture_field(field_name: "notes", field_type: "textarea", fill_cell: true, min_height: 50pt)[
  #box(width: 100%, height: 50pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 4pt, inset: 8pt)[
    #text(size: 9pt)[#get(ctx, "notes")]
  ]
]

#v(1cm)

// ============ FOOTER ============
#align(center)[
  #text(size: 9pt, fill: text_muted)[Thank you for your business!]
  #v(4pt)
  #text(size: 8pt, fill: text_muted)[
    Generated with #text(fill: primary)[typst-fillable]
  ]
]
