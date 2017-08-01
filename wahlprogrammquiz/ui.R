library(shiny)
library(shinyBS)

shinyUI(fluidPage(
  includeCSS("www/wahlprogrammquiz.css"),
  htmltools::tags$head(htmltools::tags$script(src='wahlprogrammquiz.js')),
  
  # Application title
  titlePanel("Wahlprogrammquiz"),
  
  textOutput("sentence_text"),
  
  span(id = "buttonsSpan",
       div(id="linkeDiv", class = "buttonDiv",
            img(id = "linkeButton", class="partyButton",src = "images/linkeL.png")
            ),
       div(id="grueneSpan", class = "buttonDiv",
            img(id = "grueneButton", class="partyButton",src = "images/grueneL.png")
            ),
       div(id="spdDiv", class = "buttonDiv",
            img(id = "spdButton", class="partyButton", src = "images/spdL.png")
            ),
       div(id="cduDiv", class = "buttonDiv",
            img(id = "cduButton", class="partyButton",src = "images/cduL.png")
            ),
       div(id="fdpDiv", class = "buttonDiv",
            img(id = "fdpButton", class="partyButton", src = "images/fdpL.png")
            ),
       div(id="afdDiv", class = "buttonDiv",
            img(id = "afdButton", class="partyButton", src = "images/afdL.png")
            )
  ),

  
  actionButton("button_next", "Next"),
  
  hr(),
  p("Link to question: "),
  textOutput("url"),
  
  hr(),
  p("Answer distribution"),
  tableOutput("answer_distribution")


))
