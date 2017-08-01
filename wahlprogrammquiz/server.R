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
  sentence_id <- reactive({

    getQueryString() %>%
      extract2("sentence_id") %>%
      iff(is.null, random_sentence_id)

    })
  
  sentence_text <- reactive(get_from_id(sentence_id(), "text"))
  
  ## output functions
  output$sentence_text <- renderText(sentence_text())
   

})
