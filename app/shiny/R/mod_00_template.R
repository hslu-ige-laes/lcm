
# ======================================================================

# ======================================================================

ModuleUI <- function(id) {
  #' Name UI
  #'
  #' User-Interface for the 
  #' @param id id for ns()
  #' @export
  #' @author Reto Marek
  
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
      tabPanel("Tab 2",
               fluidRow(
                 box(
                   title="tbd",
                   status="primary",
                   width = 12,
                   "content tbd"
                 )
               )
      )
    )
  )
}

Module <- function(input, output, session) {
  #' Name
  #'
  #' Server-function for the 
  #' @param filename a String representing the filename inclusive extension.
  #' @export
  #' @author Reto Marek
 
}