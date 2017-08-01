library(shiny)
library(shinyBS)

shinyUI(fluidPage(
  includeCSS("www/wahlprogrammquiz.css"),
  
  # Application title
  titlePanel("Wahlprogrammquiz"),
  
  p("Hello manifesto!"),
  
  span(id = "buttonsSpan",
       div(id="linkeDiv", class = "buttonDiv",
            img(id = "linkeButton", src = "images/linkeL.png")
            ),
       div(id="grueneSpan", class = "buttonDiv",
            img(id = "grueneButton", src = "images/grueneL.png")
            ),
       div(id="spdDiv", class = "buttonDiv",
            img(id = "spdeButton", src = "images/spdL.png")
            ),
       div(id="cduDiv", class = "buttonDiv",
            img(id = "cdueButton", src = "images/cduL.png")
            ),
       div(id="fdpDiv", class = "buttonDiv",
            img(id = "fdpButton", src = "images/fdpL.png")
            ),
       div(id="afdDiv", class = "buttonDiv",
            img(id = "afdButton", src = "images/afdL.png")
            )
       ),

  textOutput("statement")
  
  
))
