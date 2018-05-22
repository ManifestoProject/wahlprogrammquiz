# wahlprogrammquiz

This quiz asks respondents which party made a specific (more or less randomly sampled) statement in its manifestos. 
Respondents are presented with a statement that is randomly drawn (or somehow selected) from one of the six established German parties' electoral programs. 
Respondents are asked to indicate which party made the statement. 

After indicating their guess they the context of the statement is presented along with the right answer. 
Moreover, a small graph indicates the distribution of answers from previous respondents.

Implemented in shiny.


# Installation and Running

Clone repo, open in rstudio and Click on "Run App"

Shiny certainly is not the best choice to implement such a quiz as it is not good in balance loading. When deployed on a server, the quiz performs badly when requested from many users at the same time. 
