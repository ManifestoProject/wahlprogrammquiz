## read programs

library(readtext)
library(tidyverse)
library(tidytext)
library(stringr)
library(zoo)

#"sentence_id","text","context_before","context_after","party"


partynames <- tribble(
  ~doc_id, ~partyabbrev,~party,~partycolor,~partyorder,
  "union.txt","CDU/CSU","41521","black",1,
  "spd.txt","SPD","red","41320",2,
  "linke.txt","LINKE","purple","41223",3,
  "gruene.txt","GRÜNE","darkgreen","41113",4,
  "fdp.txt", "FDP","gold","41420",5,
  "afd.txt", "AfD","blue","41953",6
)

replacement_char <- "XXXXX"
no_sent_endings <- c("Vgl\\.","z\\.B\\.","Abs\\.","Art\\.","u\\.a\\.","z\\.b\\.","Z\\.B\\.","S\\.","regex('(?<=[A-Z])\\.')")

no_sent_ending_xxx <- str_replace_all(no_sent_endings,"(\\.)",replacement_char)                   
replacement_list <- setNames(no_sent_ending_xxx,no_sent_endings)

program_lines <- readtext("programs/*.txt", ignore_missing_files = FALSE, encoding="UTF-8") %>%
  left_join(partynames) %>%
  unnest_tokens(lines,text,token="lines", to_lower = FALSE) %>%
  mutate(corpus_line_id = row_number()) %>%
  mutate(
    heading_order = str_count(lines,"#"),
    lines = ifelse(heading_order > 0, str_sub(lines,start = heading_order+2, end = -1),lines)
  ) %>%
  group_by(doc_id) %>%
  arrange(doc_id,corpus_line_id) %>%
  mutate(doc_line_id = row_number()) %>%
  ungroup() 

program_sentences <- program_lines %>%
  mutate(
    lines = str_replace_all(lines,replacement_list),
    lines = str_replace_all(lines,"(?<=[A-Z])\\.",replacement_char),
    lines = str_replace_all(lines,"(?<=[0-9]{1,2})\\.",replacement_char)
  ) %>%
  unnest_tokens(sentence, lines, token = "sentences",to_lower = FALSE) %>%
  mutate(
    sentence = str_replace_all(sentence,replacement_char,".")
  ) %>%
  group_by(doc_id) %>%
  mutate(doc_sentence_id = row_number()) %>% 
  ungroup() %>%
  arrange(doc_id,doc_line_id,doc_sentence_id) %>%
  mutate(corpus_sentence_id = row_number()) %>%
  mutate(
    heading = ifelse(heading_order > 0, sentence,NA),
    heading = zoo::na.locf(heading)
  ) %>%
  left_join(program_lines %>% select(lines,corpus_line_id),by=c("corpus_line_id"="corpus_line_id")) %>%
  rename(paragraph=lines)
  
## context after, context before
## seed setzen
## not yet ready
sample_sentences <- program_sentences %>% filter(heading_order < 1) %>%
  sample_n(20) %>% 
  write_csv("sample.csv")

