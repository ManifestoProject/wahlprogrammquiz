library(shiny)
library(shinyBS)

shinyUI(fixedPage(title = "Welche Partei hat's gesagt?",
                  tags$head(tags$meta(property="og:image", content="images/thumb.jpg")),
                  includeCSS("www/wahlprogrammquiz.css"),
  htmltools::tags$head(htmltools::tags$script(src='wahlprogrammquiz.js')),

  div(id="title", "Welche Partei hat's gesagt?"),
  
  div(id = "infoDiv",
      uiOutput("info_span")),
  
  div(id = "sentenceDiv",
      textOutput("context_before"),
      span(id="sentenceSpan",
           textOutput("sentence_text")
           ),
      textOutput("context_after")
      ),

  div(id = "info2Div",
      uiOutput("info2_span")),
  uiOutput("answer_area"),
  div(id="buttonsDiv",
  span(id = "buttonsSpan",
       div(id="linkeDiv", class = "partyDiv",
            img(id = "linkeButton", class="partyButton",src = "images/linkeL.png"),
            div(id="linkeBarDiv", class = "barDiv", div(class ="per", "00"),
                div(id="linkeBar", class = "bar")
                )
            ),
       div(id="grueneDiv", class = "partyDiv",
            img(id = "grueneButton", class="partyButton",src = "images/grueneL.png"),
           div(id="grueneBarDiv", class = "barDiv", div(class ="per", "00"),
               div(id="grueneBar", class = "bar")
           )
            ),
       div(id="spdDiv", class = "partyDiv",
            img(id = "spdButton", class="partyButton", src = "images/spdL.png"),
           div(id="spdBarDiv", class = "barDiv", div(class ="per", "00"),
               div(id="spdBar", class = "bar")
           )
            ),
       div(id="cduDiv", class = "partyDiv",
            img(id = "cduButton", class="partyButton",src = "images/cduL.png"),
           div(id="cduBarDiv", class = "barDiv", div(class ="per", "00"),
               div(id="cduBar", class = "bar")
           )
            ),
       div(id="fdpDiv", class = "partyDiv",
            img(id = "fdpButton", class="partyButton", src = "images/fdpL.png"),
           div(id="fdpBarDiv", class = "barDiv", div(class ="per", "00"),
               div(id="fdpBar", class = "bar")
           )
            ),
       div(id="afdDiv", class = "partyDiv",
            img(id = "afdButton", class="partyButton", src = "images/afdL.png"),
           div(id="afdBarDiv", class = "barDiv", div(class ="per", "00"),
               div(id="afdBar", class = "bar")
           )
       )
  )),

  div(id = "AboutLink",
      a("About & Impressum", href="javascript:void(0)", onClick = "toggleOverlay('AboutOverlay')")),
  div(id = "AboutOverlay", style = "display:none",
      includeMarkdown("about.md"),
      div(align = "right",
          a("Zurück", href="javascript:void(0)", onClick = "toggleOverlay('AboutOverlay')"))),
  uiOutput("share_overlay")
  
))
