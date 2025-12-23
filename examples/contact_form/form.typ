// Contact Form - typst-fillable example
// A clean, professional contact form

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
#let accent = rgb("#4A90A4")
#let accent_light = rgb("#E8F4F8")
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

// ============ PAGE SETUP ============
#set page(margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm))
#set text(font: "Helvetica", size: 10pt, fill: text_dark)

// ============ HEADER ============
#align(center)[
  #box(fill: accent, width: 100%, inset: 20pt, radius: 4pt)[
    #text(size: 22pt, weight: "bold", fill: white)[Contact Us]
    #v(4pt)
    #text(size: 11pt, fill: white.transparentize(20%))[We'd love to hear from you]
  ]
]

#v(1.2cm)

// ============ PERSONAL INFORMATION ============
#text(size: 12pt, weight: "bold", fill: accent)[Personal Information]
#v(2pt)
#line(length: 100%, stroke: 0.5pt + accent_light)
#v(0.5cm)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 20pt,
  row-gutter: 14pt,

  [
    #text(size: 9pt, fill: text_muted)[Full Name #text(fill: rgb("#EF4444"))[\*]]
    #v(4pt)
    #capture_field(field_name: "full_name", field_type: "text")[
      #box(width: 100%, height: 28pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 4pt, inset: 6pt)[
        #text(size: 10pt)[#get(ctx, "full_name")]
      ]
    ]
  ],
  [
    #text(size: 9pt, fill: text_muted)[Email Address #text(fill: rgb("#EF4444"))[\*]]
    #v(4pt)
    #capture_field(field_name: "email", field_type: "text")[
      #box(width: 100%, height: 28pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 4pt, inset: 6pt)[
        #text(size: 10pt)[#get(ctx, "email")]
      ]
    ]
  ],
  [
    #text(size: 9pt, fill: text_muted)[Phone Number]
    #v(4pt)
    #capture_field(field_name: "phone", field_type: "text")[
      #box(width: 100%, height: 28pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 4pt, inset: 6pt)[
        #text(size: 10pt)[#get(ctx, "phone")]
      ]
    ]
  ],
  [
    #text(size: 9pt, fill: text_muted)[Company]
    #v(4pt)
    #capture_field(field_name: "company", field_type: "text")[
      #box(width: 100%, height: 28pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 4pt, inset: 6pt)[
        #text(size: 10pt)[#get(ctx, "company")]
      ]
    ]
  ],
)

#v(0.8cm)

// ============ CONTACT PREFERENCES ============
#text(size: 12pt, weight: "bold", fill: accent)[Contact Preferences]
#v(2pt)
#line(length: 100%, stroke: 0.5pt + accent_light)
#v(0.5cm)

#text(size: 9pt, fill: text_muted)[Preferred contact method]
#v(6pt)

#grid(
  columns: (auto, auto, auto),
  column-gutter: 25pt,
  [
    #capture_field(field_name: "contact_email", field_type: "radio", group_name: "contact_method")[
      #box(width: 14pt, height: 14pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 50%)
    ]
    #h(5pt) #text(size: 10pt)[Email]
  ],
  [
    #capture_field(field_name: "contact_phone", field_type: "radio", group_name: "contact_method")[
      #box(width: 14pt, height: 14pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 50%)
    ]
    #h(5pt) #text(size: 10pt)[Phone]
  ],
  [
    #capture_field(field_name: "contact_either", field_type: "radio", group_name: "contact_method")[
      #box(width: 14pt, height: 14pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 50%)
    ]
    #h(5pt) #text(size: 10pt)[Either]
  ],
)

#v(0.8cm)

// ============ MESSAGE ============
#text(size: 12pt, weight: "bold", fill: accent)[Your Message]
#v(2pt)
#line(length: 100%, stroke: 0.5pt + accent_light)
#v(0.5cm)

#text(size: 9pt, fill: text_muted)[How can we help you? #text(fill: rgb("#EF4444"))[\*]]
#v(4pt)

#capture_field(field_name: "message", field_type: "textarea", fill_cell: true, min_height: 80pt)[
  #box(width: 100%, height: 80pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 4pt, inset: 8pt)[
    #text(size: 10pt)[#get(ctx, "message")]
  ]
]

#v(0.8cm)

// ============ NEWSLETTER ============
#box(fill: accent_light, width: 100%, inset: 14pt, radius: 4pt)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 10pt,
    align: horizon,
    capture_field(field_name: "newsletter", field_type: "checkbox")[
      #box(width: 16pt, height: 16pt, stroke: 0.5pt + accent, fill: white, radius: 3pt)
    ],
    [
      #text(size: 10pt, weight: "medium")[Subscribe to our newsletter]
      #h(8pt)
      #text(size: 9pt, fill: text_muted)[Get updates about products and services]
    ],
  )
]

#v(0.6cm)

// ============ TERMS ============
#grid(
  columns: (auto, 1fr),
  column-gutter: 8pt,
  capture_field(field_name: "terms", field_type: "checkbox")[
    #box(width: 14pt, height: 14pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 3pt)
  ],
  text(size: 9pt)[I agree to the #text(fill: accent)[Terms of Service] and #text(fill: accent)[Privacy Policy] #text(fill: rgb("#EF4444"))[\*]],
)

#v(1.5cm)

// ============ FOOTER ============
#align(center)[
  #text(size: 8pt, fill: text_muted)[
    Generated with #text(fill: accent)[typst-fillable]
  ]
]
