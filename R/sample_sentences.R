## read programs

#library(manifestorita)
library(readtext)
library(tidyverse)
library(tidytext)


partynames <- tribble(
  ~doc_id, ~partyabbrev,~partycolor,~partyorder,
  "union.txt","CDU/CSU","black",1,
  "spd.txt","SPD","red",2,
  "linke.txt","LINKE","purple",3,
  "gruene.txt","GRÜNE","darkgreen",4,
  "fdp.txt", "FDP","gold",5,
  "afd.txt", "AfD","blue",6
)


de2017  <- readtext("programs/*.txt", ignore_missing_files = FALSE, encoding="UTF-8") %>%
  left_join(partynames) %>%
  unnest_tokens(lines,text,token="lines", to_lower = FALSE) %>%
  group_by(doc_id) %>%
  mutate(
    heading_order = str_count(lines,"#"),
    lines = ifelse(heading_order > 0, str_sub(lines,start = heading_order+2, end = -1),lines)
  ) %>%
  group_by(doc_id) %>%
  mutate(
    line_id = row_number()
  ) %>%
  ungroup() %>%
  arrange(doc_id,line_id) %>%
  unnest_tokens(sentence, lines, token = "sentences",to_lower = FALSE) %>%
  group_by(doc_id) %>%
  mutate(
    sentence_id = row_number()
  ) %>% arrange(doc_id,sentence_id) 


## not yet ready
sample_sentences <- de2017 %>% filter(heading_order < 1) %>%
  sample_n(10) 
  

### exportformat "sentence_id","text","context_before","context_after","party"

