// Customer Satisfaction Survey - typst-fillable example
// Demonstrates radio button scales and multiple checkboxes

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
#let primary = rgb("#7C3AED")
#let primary_light = rgb("#EDE9FE")
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
#let radio_option(name, group, label) = {
  box[
    #capture_field(field_name: name, field_type: "radio", group_name: group)[
      #box(width: 16pt, height: 16pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 50%)
    ]
    #h(4pt)
    #text(size: 9pt)[#label]
  ]
}

#let checkbox_option(name, label) = {
  box[
    #capture_field(field_name: name, field_type: "checkbox")[
      #box(width: 14pt, height: 14pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 2pt)
    ]
    #h(4pt)
    #text(size: 9pt)[#label]
  ]
}

#let rating_scale(question_num, question_text, group_name) = {
  [
    #text(weight: "bold", size: 10pt)[#question_num. #question_text]
    #v(8pt)
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr),
      align: center,
      row-gutter: 6pt,
      radio_option(group_name + "_1", group_name, ""),
      radio_option(group_name + "_2", group_name, ""),
      radio_option(group_name + "_3", group_name, ""),
      radio_option(group_name + "_4", group_name, ""),
      radio_option(group_name + "_5", group_name, ""),
      text(size: 8pt, fill: text_muted)[Very Poor],
      text(size: 8pt, fill: text_muted)[Poor],
      text(size: 8pt, fill: text_muted)[Neutral],
      text(size: 8pt, fill: text_muted)[Good],
      text(size: 8pt, fill: text_muted)[Excellent],
    )
    #v(0.6cm)
  ]
}

// ============ PAGE SETUP ============
#set page(margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm))
#set text(font: "Helvetica", size: 10pt, fill: text_dark)

// ============ HEADER ============
#align(center)[
  #box(fill: primary, width: 100%, inset: 20pt, radius: 4pt)[
    #text(size: 22pt, weight: "bold", fill: white)[Customer Satisfaction Survey]
    #v(4pt)
    #text(size: 11pt, fill: white.transparentize(20%))[Help us improve our services]
  ]
]

#v(0.8cm)

#box(fill: primary_light, width: 100%, inset: 12pt, radius: 4pt)[
  #text(size: 9pt, fill: text_muted)[
    Please take a few minutes to complete this survey. Your feedback is valuable to us.
    Rate each aspect from 1 (Very Poor) to 5 (Excellent).
  ]
]

#v(1cm)

// ============ SECTION 1: SERVICE QUALITY ============
#text(size: 12pt, weight: "bold", fill: primary)[Section 1: Service Quality]
#v(2pt)
#line(length: 100%, stroke: 0.5pt + primary_light)
#v(0.5cm)

#rating_scale("1", "How would you rate our overall service?", "q1_service")
#rating_scale("2", "How responsive was our support team?", "q2_response")
#rating_scale("3", "How would you rate the quality of our product?", "q3_quality")

// ============ SECTION 2: EXPERIENCE ============
#text(size: 12pt, weight: "bold", fill: primary)[Section 2: Your Experience]
#v(2pt)
#line(length: 100%, stroke: 0.5pt + primary_light)
#v(0.5cm)

#text(weight: "bold", size: 10pt)[4. How did you hear about us?]
#v(6pt)
#grid(
  columns: (1fr, 1fr),
  row-gutter: 8pt,
  checkbox_option("source_search", "Search Engine"),
  checkbox_option("source_social", "Social Media"),
  checkbox_option("source_friend", "Friend/Colleague"),
  checkbox_option("source_ad", "Advertisement"),
  checkbox_option("source_blog", "Blog/Article"),
  checkbox_option("source_other", "Other"),
)

#v(0.8cm)

#text(weight: "bold", size: 10pt)[5. Would you recommend us to others?]
#v(8pt)
#grid(
  columns: (auto, auto, auto),
  column-gutter: 30pt,
  radio_option("recommend_yes", "recommend", "Yes, definitely"),
  radio_option("recommend_maybe", "recommend", "Maybe"),
  radio_option("recommend_no", "recommend", "No"),
)

#v(1cm)

// ============ SECTION 3: COMMENTS ============
#text(size: 12pt, weight: "bold", fill: primary)[Section 3: Additional Feedback]
#v(2pt)
#line(length: 100%, stroke: 0.5pt + primary_light)
#v(0.5cm)

#text(weight: "bold", size: 10pt)[6. What did you like most about our service?]
#v(4pt)
#capture_field(field_name: "liked_most", field_type: "textarea", fill_cell: true, min_height: 50pt)[
  #box(width: 100%, height: 50pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 4pt, inset: 8pt)[
    #text(size: 10pt)[#get(ctx, "liked_most")]
  ]
]

#v(0.6cm)

#text(weight: "bold", size: 10pt)[7. What could we improve?]
#v(4pt)
#capture_field(field_name: "improvements", field_type: "textarea", fill_cell: true, min_height: 50pt)[
  #box(width: 100%, height: 50pt, stroke: 0.5pt + border_color, fill: field_bg, radius: 4pt, inset: 8pt)[
    #text(size: 10pt)[#get(ctx, "improvements")]
  ]
]

#v(1cm)

// ============ CONTACT (OPTIONAL) ============
#box(fill: primary_light, width: 100%, inset: 14pt, radius: 4pt)[
  #text(size: 10pt, weight: "medium")[Optional: Leave your email for follow-up]
  #v(6pt)
  #capture_field(field_name: "email", field_type: "text")[
    #box(width: 250pt, height: 26pt, stroke: 0.5pt + primary, fill: white, radius: 4pt, inset: 6pt)[
      #text(size: 10pt)[#get(ctx, "email")]
    ]
  ]
]

#v(1.5cm)

// ============ FOOTER ============
#align(center)[
  #text(size: 8pt, fill: text_muted)[
    Thank you for your feedback! — Generated with #text(fill: primary)[typst-fillable]
  ]
]
