library(shiny)
library(readr)
library(dplyr) ## developed with package version 0.7
library(magrittr)
library(rlang)
library(stringi)

library(DBI) ## developed with package version 0.7
library(RSQLite) ## developed with package version 2.0
library(dbplyr)

ROOT_URL = "http://localhost:8020" ## TODO replace with final URL
RESPONSES = "responses"
db_connection <- dbConnect(RSQLite::SQLite(), "wahlprogrammquiz.sqlite")
if (!dbExistsTable(db_connection, RESPONSES)) {
  dbWriteTable(db_connection,
               RESPONSES,
               data_frame(session_id = character(),  ## This is a schema definition
                          sentence_id = integer(),   ## for the database table
                          time_stamp = character(),
                          answer = character()
                          ))
} 

### iff function from gitlabr and manifestoR; this is copied in order to not import these packages
iff <- function (obj, test, fun, ...) {
  if ((is.function(test) && test(obj)) || (is.logical(test) && test)) {
    fun(obj, ...)
  } else {
    obj
  }
}

questions <- read_csv("sentences.csv")

get_from_id <- function(id, field_name) {
  questions %>%
    filter(sentence_id == id) %>%
    select(one_of(field_name)) %>%
    unlist()
}

random_sentence_id <- function(without = c()) {
  questions %>%
    filter(!sentence_id %in% without) %>%
    select(sentence_id) %>%
    sample_n(1) %>%
    unlist()
}

valid_sentence_ids <- function() {
  questions %$% sentence_id %>% unlist()
}

party_order <- c("41113", "41223", "41320", "41521", "41420", "41953")

shinyServer(function(input, output, session) {
  
  
  ## internal reactives
  state <- reactiveValues(sentence_id = isolate(getQueryString()) %>%
                            extract2("sentence_id") %>%
                            iff(is.null, random_sentence_id) %>%
                            iff(. %>% is_in(valid_sentence_ids()) %>% not(), random_sentence_id),
                          seen_sentences = integer(0),
                          session_id = paste0(stri_rand_strings(1, 20), "_", as.character(as.POSIXct(Sys.time()))),
                          show_answer = FALSE)
  
  sentence_text <- reactive(get_from_id(state$sentence_id, "text"))
  context_before <- reactive(get_from_id(state$sentence_id, "context_before"))
  context_after <- reactive(get_from_id(state$sentence_id, "context_after"))
  info_span <- reactive(HTML(paste0(
                             "Aus dem Wahlprogramm der ",
                             strong(get_from_id(state$sentence_id, "party")),  ## TODO change to partyname when new table is there
                             ", Abschnitt ",
                             strong(get_from_id(state$sentence_id, "heading")),
                             ":",
                             collapse = "")))
  
  sentence_party <- reactive(get_from_id(state$sentence_id, "party"))
  
  link_to_question <- reactive(paste0(ROOT_URL, "?sentence_id=", state$sentence_id))
  
  selected_answer <- eventReactive(input$partyButton,
                                   switch(input$partyButton,
                                     linkeButton = "41113",
                                     grueneButton = "41223",
                                     spdButton = "41320",
                                     cduButton = "41521",
                                     fdpButton = "41420",
                                     afdButton = "41953",
                                     default = NULL),
                                   ignoreNULL = FALSE)

  event_next <- reactive(input$button_next)
  
  answer_distribution <- reactive(
    db_connection %>%
      tbl(RESPONSES) %>%
      dplyr::filter(sentence_id == !!as.numeric(state$sentence_id)) %>%
      count(answer) %>%
      collect() %>%
      transmute(party = answer, per = n/sum(n)) %>%
      left_join(data_frame(party = party_order), ., copy = TRUE) %>%
      pull(per)
  )
  
  ## event observers
  observeEvent(event_next(), {
    #this sends a message to js to reset the bars to 0, and hide the percentages
    session$sendCustomMessage(type='resetValuesCallbackHandler', "none")
    state$show_answer <- FALSE
    
    state$seen_sentences <- c(state$seen_sentences, state$sentence_id)
    
    ## If User is through all questions, start over
    if (length(setdiff(state$seen_sentences, valid_sentence_ids())) == 0) {
      state$seen_sentences <- integer(0)
    }
    state$sentence_id <- random_sentence_id(without = state$seen_sentences)
    updateQueryString(paste0("?sentence_id=", state$sentence_id))
    
  }, ignoreInit = TRUE)
  
  observeEvent(input$partyButton, {
    
    if (!is.null(selected_answer())) {
      state$show_answer <- TRUE

        db_connection %>%
        db_insert_into(RESPONSES,
                       data_frame(session_id = state$session_id,
                                  sentence_id = state$sentence_id,   ## for the database table
                                  time_stamp = as.character(as.POSIXct(Sys.time())),
                                  answer = selected_answer()))
        
        #this sends the accumulated values to js, so that the bars can animate to the correct heights and display the percentage
        #they should be between 0 and 1, I've put some sample values in below. Should be a length 6 numeric vector
        session$sendCustomMessage(type='barValuesCallbackHandler', 
                                  message = list(percentages = answer_distribution(), 
                                                 opacities = 0.3 + 0.7*(party_order == sentence_party())))
        
    }

  })
  
  ## output functions
  output$sentence_text <- renderText(sentence_text())
  output$context_before <- renderText(if (state$show_answer) context_before() else "")
  output$context_after <- renderText(if (state$show_answer) context_after() else "")
  output$info_span <- renderUI(if (state$show_answer) span(class = "infoSpan", info_span()) else span())
  output$sentence_party <- renderText(sentence_party())
  output$answer_distribution <- renderTable(answer_distribution())
  output$answer_area <- renderUI({ ## This should be greatly modified for layouting!
    if(state$show_answer) {
      fluidRow(
        id = "bottom_row",
        column(width = 2,
               a("Link to this question", href = link_to_question())),
        column(width = 8),
        column(width = 2,
               actionButton("button_next", "Next question"))
      )
    } else {
      fluidRow()
    }
  })

})
