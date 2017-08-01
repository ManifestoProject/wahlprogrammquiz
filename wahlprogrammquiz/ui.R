library(shiny)
library(shinyBS)

shinyUI(fluidPage(
  includeCSS("www/wahlprogrammquiz.css"),
  
  # Application title
  titlePanel("Wahlprogrammquiz"),
  
  p("Hello manifesto!"),
  
  span(id = "buttonsSpan",
       div(id="linkeSpan", class = "buttonDiv",
            img(id = "linkeButton", src = "images/linkeL.png")
            ),
       div(id="grueneSpan", class = "buttonDiv",
            img(id = "grueneButton", src = "images/grueneL.png")
            ),
       div(id="spdSpan", class = "buttonDiv",
            img(id = "spdeButton", src = "images/spdL.png")
            ),
       div(id="cduSpan", class = "buttonDiv",
            img(id = "cdueButton", src = "images/cduL.png")
            ),
       div(id="fdpSpan", class = "buttonDiv",
            img(id = "fdpButton", src = "images/fdpL.png")
            ),
       div(id="afdSpan", class = "buttonDiv",
            img(id = "afdButton", src = "images/afdL.png")
            )
       ),

  textOutput("statement")
  
  
))
