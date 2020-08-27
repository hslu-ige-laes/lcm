
# ======================================================================

# ======================================================================

templateModuleUI <- function(id) {

  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title = "Title",
        solidHeader = TRUE,
        status="primary",
        width = 12,
        box(
          width = 3,
          "content tbd"
        )
      )
    ),
    tabsetPanel(
      id = "tabset1",
      tabPanel("Overview",
               fluidRow(
                 box(
                   title="Overview",
                   status="primary",
                   width = 12,
                   "content tbd"
                 )
               )
      ),
      tabPanel("Info",
               fluidRow(
                 box(
                   status="primary",
                   width = 12,
                   column(
                     width = 12,
                     includeMarkdown(here::here("docs", "docs", "modules","template.md"))
                   )
                 )
               )
      ),
      fluidRow(
        box(
          title = "Interpretation",
          solidHeader = TRUE,
          width = 12,
          background = "light-blue",
          "A box with a solid light-blue background"
        )
      )
    )
  )
}

templateModule <- function(input, output, session) {
  # add server code and visualizations
}