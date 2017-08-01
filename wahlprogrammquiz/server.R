library(shiny)
library(readr)
library(dplyr) ## developed with package version 0.7
library(magrittr)

library(DBI) ## developed with package version 0.7
library(RSQLite) ## developed with package version 2.0

ROOT_URL = "localhost:8020" ## TODO replace with final URL
RESPONSES = "responses"
db_connection <- dbConnect(RSQLite::SQLite(), "wahlprogrammquiz.sqlite")
if (!db_has_table(db_connection, RESPONSES)) {
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

shinyServer(function(input, output) {
  
  
  ## internal reactives
  state <- reactiveValues(sentence_id = isolate(getQueryString()) %>%
                            extract2("sentence_id") %>%
                            iff(is.null, random_sentence_id),
                          seen_sentences = integer(0))
  
  sentence_text <- reactive(get_from_id(state$sentence_id, "text"))
  
  link_to_question <- reactive(paste0(ROOT_URL, "?sentence_id=", state$sentence_id))
  
  selected_answer <- reactive(input$answer_select) ## TODO this is likely replaced by more complex UI input processing?
  event_next <- reactive(input$button_next)
  
  answer_distribution <- reactive( ## This reacts on sentence_id, but should only be visible after selecting an answer
    db_connection %>%
      tbl(RESPONSES) %>%
      dplyr::filter(sentence_id == !!as.numeric(state$sentence_id)) %>%
      count(answer)
  )
  
  ## event observers
  observeEvent(event_next(), {
    
    state$seen_sentences <- c(state$seen_sentences, state$sentence_id)
    state$sentence_id <- random_sentence_id(without = state$seen_sentences)
    updateQueryString(paste0("?sentence_id=", state$sentence_id))
    
  }, ignoreInit = TRUE)
  
  
  ## output functions
  output$sentence_text <- renderText(sentence_text())
  output$url <- renderText(link_to_question())
   

})
