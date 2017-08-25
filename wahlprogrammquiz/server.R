library(shiny)
library(readr)
library(dplyr) ## developed with package version 0.7
library(magrittr)
library(rlang)
library(stringi)

library(DBI) ## developed with package version 0.7
library(dbplyr)

if (file.exists("database.yml")) { ## use postgresql
  require(RPostgreSQL)
  require(yaml)
  db_config <- yaml.load_file("database.yml")
  RESPONSES <- db_config$table
  db_connection <- dbConnect(
    dbDriver("PostgreSQL"),
    host = db_config$host,
    port = db_config$port,
    user = db_config$user,
    password = db_config$password,
    dbname = db_config$database)
  
} else { ## use local RSQLite
  require(RSQLite) ## developed with package version 2.0
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
}


### iff function from gitlabr and manifestoR; this is copied in order to not import these packages
iff <- function (obj, test, fun, ...) {
  if ((is.function(test) && test(obj)) || (is.logical(test) && test)) {
    fun(obj, ...)
  } else {
    obj
  }
}

questions <- read_csv("sentences.csv") %>%
  mutate_if(is.numeric, as.integer)

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

party_order <- c("41223", "41113", "41320", "41521", "41420", "41953")

shinyServer(function(input, output, session) {
  
  
  ## internal reactives
  state <- reactiveValues(sentence_id = isolate(getQueryString()) %>%
                            extract2("sentence_id") %>%
                            iff(is.null, random_sentence_id) %>%
                            iff(. %>% is_in(valid_sentence_ids()) %>% not(), random_sentence_id),
                          seen_sentences = integer(0),
                          correct_answers = logical(0),
                          session_id = paste0(stri_rand_strings(1, 20), "_", as.character(as.POSIXct(Sys.time()))),
                          show_answer = FALSE,
                          show_share = FALSE)
  
  sentence_text <- reactive(get_from_id(state$sentence_id, ifelse(state$show_answer, "sentence", "text")))
  context_before <- reactive(get_from_id(state$sentence_id, "context_before") %>% iff(is.na, function(obj) ""))
  context_after <- reactive(get_from_id(state$sentence_id, "context_after") %>% iff(is.na, function(obj) ""))
  
  info_span <- reactive(HTML(paste0(
                             if (sentence_party() == selected_answer()) "<font color='LimeGreen'><b>Richtig!</b></font> " else "<font color='red'><b>Falsch!</b></font> ",
                             "Aus dem Wahlprogramm der ",
                             strong(get_from_id(state$sentence_id, "partyabbrev")),  ## TODO change to partyname when new table is there
                             ", Abschnitt ",
                             strong(get_from_id(state$sentence_id, "heading")),
                            ":",
                             collapse = "")))
  
  info2_span <- reactive(HTML(paste0(
                                    "Bisher ", 
                                    if (sentence_party() == selected_answer()) {
                                      sum(state$correct_answers, na.rm=TRUE) + 1
                                    }
                                    else  {
                                      sum(state$correct_answers, na.rm=TRUE) 
                                    },
                                    " aus ", 
                                    length(state$correct_answers)+1, 
                                    if (length(state$correct_answers) > 0) " Zitaten "
                                    else " Zitat ",
                                    "richtig zugeordnet. Es gibt noch ",
                                    97 - length(state$correct_answers)-1,
                                    " weitere Zitate. Die Balken zeigen die Antworten aller Nutzer an.",
                                    collapse = "")))
  
  sentence_party <- reactive(get_from_id(state$sentence_id, "party"))

  link_to_question <- reactive(paste0("https://",
                                      session$clientData$url_hostname,
                                      session$clientData$url_pathname,
                                      "?sentence_id=", state$sentence_id))
  short_link_to_question <- reactive(paste0("https://tinyurl.com/wahlprogrammquiz",
                                     "?sentence_id=", state$sentence_id))
  
  selected_answer <- eventReactive(
    if (state$show_answer==FALSE) { 
    input$partyButton},
      switch(input$partyButton,
                                     linkeButton = "41223",
                                     grueneButton = "41113",
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
    state$show_share <- FALSE
    
    state$seen_sentences <- c(state$seen_sentences, as.integer(state$sentence_id))
    state$correct_answers <- c(state$correct_answers, sentence_party() == selected_answer())
    
    ## If User is through all questions, start over
    if (length(setdiff(valid_sentence_ids(), state$seen_sentences)) == 0) {
      state$seen_sentences <- integer(0)
    }
    state$sentence_id <- random_sentence_id(without = state$seen_sentences)
    updateQueryString(paste0("?sentence_id=", state$sentence_id))
    
  }, ignoreInit = TRUE)
  
  observeEvent(input$partyButton, {
    
    if (!is.null(selected_answer()) & state$show_answer == FALSE) {
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
  output$info2_span <- renderUI(if (state$show_answer) span(class = "info2Span", info2_span()) else span())
  output$sentence_party <- renderText(sentence_party())
  output$answer_distribution <- renderTable(answer_distribution())
  output$answer_area <- renderUI({ ## This should be greatly modified for layouting!
    if(state$show_answer) {
      fluidRow(
        id = "bottom_row",
        column(width = 8),
        column(width = 2,
               actionButton("share_link", "Dieses Zitat teilen")),
        column(width = 2,
               actionButton("button_next", "Nächste Frage"))
      )
    } else {
      fluidRow()
    }
  })
  output$question_url <- renderText(link_to_question())
  observeEvent(input$share_link, {
    state$show_share <- TRUE
  })
  observeEvent(input$hide_link, {
    state$show_share <- FALSE
  })
  share_style <- reactive(if(state$show_share) "display:block;" else "display:none;")
  
  output$share_overlay <- renderUI({
      div(id = "ShareOverlay", style=share_style(),
          textInput("ignore_url", label = "Kurz-URL:", value = short_link_to_question()),
          textInput("ignore_short_url", label = "Permanente URL:", value = link_to_question()),
          tags$button("Tweet Link", onclick = paste0(
            "location.href='https://twitter.com/intent/tweet",
            "?text=", URLencode("Welche Partei sagt: "), substr(get_from_id(state$sentence_id, "text"), 1, 68), "...",
            "&url=", URLencode(short_link_to_question()),
            "&hashtags=btw17,wahlprogrammquiz'")),
          div(align = "right",
          actionButton("hide_link", "Zurück")))
  })

})
