library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Wahlprogrammquiz"),
  
  textOutput("sentence_text"),
  selectInput("answer_select", "Select an answer", list("Die Gruenen" = 41113L,
                                                        "SPD" = 41320L,
                                                        "AfD" = 41953L)),
  actionButton("button_next", "Next"),
  
  hr(),
  p("Link to question: "),
  textOutput("url"),
  
  hr(),
  p("Answer distribution"),
  tableOutput("answer_distribution")
  
))
