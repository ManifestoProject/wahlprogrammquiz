library(shiny)
library(readr)
library(dplyr)
library(magrittr)

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
  
  event_next <- reactive(input$button_next)
  
  ## event observers
  observeEvent(event_next(), {
    
    state$seen_sentences <- c(state$seen_sentences, state$sentence_id)
    state$sentence_id <- random_sentence_id(without = state$seen_sentences)
    updateQueryString(paste0("?sentence_id=", state$sentence_id))
    
  }, ignoreInit = TRUE)
  
  
  ## output functions
  output$sentence_text <- renderText(sentence_text())
   

})
