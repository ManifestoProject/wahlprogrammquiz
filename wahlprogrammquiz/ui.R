library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Wahlprogrammquiz"),
  
  textOutput("sentence_text"),
  actionButton("button_next", "Next"),
  
  hr(),
  p("Link to question: "),
  
  textOutput("url")
  
))
