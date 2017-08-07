## read programs

library(readtext)
library(tidyverse)
library(tidytext)
library(stringr)
library(zoo)
library(xlsx)

#"sentence_id","text","context_before","context_after","party"


partynames <- tribble(
  ~doc_id, ~partyabbrev,~party,~partycolor,~partyorder,
  "union.txt","CDU/CSU","41521","black",1,
  "spd.txt","SPD","41320","red",2,
  "linke.txt","LINKEN","41223","purple",3,
  "gruene.txt","GRÜNEN","41113","darkgreen",4,
  "fdp.txt", "FDP","41420","gold",5,
  "afd.txt", "AfD","41953","blue",6
)

replacement_char <- "XXXXX"
no_sent_endings <- c("Nr\\.","bzw\\.","vgl\\.","Vgl\\.","z\\.B\\.","Abs\\.","Art\\.","u\\.a\\.","z\\.b\\.","Z\\.B\\.","S\\.","regex('(?<=[A-Z])\\.')")

no_sent_ending_xxx <- str_replace_all(no_sent_endings,"(\\.)",replacement_char)                   
replacement_list <- setNames(no_sent_ending_xxx,no_sent_endings)

## paragraphs

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

## sentences

sentences_lines <- program_lines %>%
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

## context

program_sentences <- map2_chr(sentences_lines$paragraph,
                              sentences_lines$sentence, 
                    ~ str_replace_all(.x,fixed(.y),"SENTENCEHERE")) %>%
  tibble(context=.) %>% 
  bind_cols(sentences_lines) %>%
  mutate(
    context_after = str_replace_all(context,".*SENTENCEHERE",""),
    context_before = str_replace_all(context,"SENTENCEHERE.*","")
  ) %>% 
  select(-context) %>%
  mutate(
    text=sentence,
    text = str_replace_all(text,"Wir Freie Demokraten|Wir GRÜNE","Wir"),
    text = str_replace(text,"^-",""),
    partyname_in_text = str_detect(text,"CDU|CSU|FDP|AfD|GRÜNE|LINKE|SPD|Union")
  )

## save 

program_sentences %T>% 
  write.csv("wahlprogrammquiz/all_sentences.csv",fileEncoding="UTF-8",row.names=FALSE) %>%
  as.data.frame() %>%
  write.xlsx("wahlprogrammquiz/all_sentences.xlsx",row.names=FALSE)

## sample
## set seed 
sample_seed <- 41
set.seed(sample_seed)

sample_sentences <- program_sentences %>% 
  filter(heading_order < 1 & partyname_in_text == FALSE) %>%
  filter(str_detect(text,"^Wir ")) %>%
  filter(!str_detect(text,"dabei|damit|deshalb|außerdem|solche|daher")) %>%
  group_by(partyabbrev) %>%
  sample_n(25) %>%
  mutate(
    exclude = 0
  ) %>% 
  ungroup() %>%
  select(include,partyabbrev,text,everything()) %T>%
  write.csv(paste("wahlprogrammquiz/sample",sample_seed,".csv",sep=""),fileEncoding="UTF-8",row.names=FALSE) %>%
  as.data.frame() %>%
  write.xlsx(paste("wahlprogrammquiz/sample",sample_seed,".xlsx",sep=""),sheetName = "Sample" ,row.names=FALSE)

read.xlsx("wahlprogrammquiz/sample41_edited.xlsx", sheetName="Sample") %>% 
  as_data_frame() %>% 
  filter(exclude==FALSE) %>%
  group_by(partyabbrev) %>%
  sample_n(10) %>%
  write_csv(paste("wahlprogrammquiz/sample_manualedited",sample_seed,".csv",sep=""))
  
  