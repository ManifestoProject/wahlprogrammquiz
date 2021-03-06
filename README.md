# wahlprogrammquiz

This quiz asks respondents which party made a specific (more or less randomly sampled) statement in its manifestos. 
Respondents are presented with a statement that is randomly drawn (or somehow selected) from one of the six established German parties' electoral programs. 
Respondents are asked to indicate which party made the statement. 

After indicating their guess they the context of the statement is presented along with the right answer. 
Moreover, a small graph indicates the distribution of answers from previous respondents.

Implemented in shiny.

The quiz was running here: https://visuals.manifesto-project.wzb.eu/prototypes/wahlprogrammquiz/ but is currently broken on our server. You can still run it locally on your machine. 

# Installation and Running

Clone repo, open in rstudio and Click on "Run App"

Shiny certainly is not the best choice to implement such a quiz as it is not good in balance loading. When deployed on a server, the quiz performs badly when requested from many users at the same time. 


# More information on the quiz (sorry, German only)

## Was ist das?

Ein Quiz zu den Inhalten der Wahlprogramme der sechs Parteien, welche laut aktuellen Umfragen in den Bundestag einziehen würden. 

## Wie funktioniert es?

Rate welche Partei den angezeigten Satz in ihrem Programm stehen hat indem du auf den Button mit dem jeweiligen Partei-Logo klickst. Nach dem Klick wird der ganze Abschnitt angezeigt indem der Satz zu finden ist. Außerdem wird auf die Überschrift des entsprechenden Abschnitts verwiesen. Das Logo der Partei, welche das Zitat im Programm stehen hat wird hervorgehoben. Die Balken unter den Logos geben die Verteilung der bisherigen Antworten an. 

## Wer steckt dahinter?

Die Seite wurde von Jirka Lewandowski, Nicolas Merz und Paul Muscat realisiert. Wir sind Mitarbeiter am [Wissenschaftszentrum Berlin für Sozialforschung](https://www.wzb.eu) und arbeiten in einem [Forschungsprojekt zur Analyse von Wahlprogrammen - dem Manifesto Projekt](https://manifesto-project.wzb.eu). 

Die Idee zu diesem Projekt entstand auf einem [Wahlsalon der Open Knowledge Foundation](https://okfn.de/blog/2017/04/wahlsalons/).

Dieses Angebot ist politisch neutral. 

![WZB Logo](/images/wzb-logo.png)

## Warum macht ihr das?

Wir wollen mit dieser Seite spielerisch über die Inhalte der Wahlprogramme informieren. Außerdem werden die Antworten gespeichert und können uns Erkenntnisse zur Wahrnehmung und Kenntnis der Wahlprogramme liefern. 

## Wie wurden die Sätze ausgewählt?

Die Sätze wurden den sechs Wahlprogrammen der etablierten Parteien zur Bundestagswahl 2017 entnommen. Die Auswahl der Sätze erfolgte in einem zweistufigen Verfahren. Zuerst wurden zufällig Sätze von allen Parteien ausgewählt. Dabei wurden nur solche Sätze berücksichtigt, welche mit "Wir" beginnen um Sätze mit konkreten politischen Forderungen zu erhalten. Zudem wurden Sätze ausgeschlossen, welche den Namen der Partei oder einer anderen Partei beinhalten. In Fällen wo der Parteiname leicht aus dem Satz entfernt werden konnte, ohne dass eine Umformulierung des Satzes notwendig ist, wurde der Parteiname automatisch entfernt (z.B. "Wir Freie Demokraten fordern, dass..." wurde zu "Wir fordern, dass..."). Außerdem wurden Sätze ausgelassen, welche mit Wörtern wie "damit", "deshalb" auf einen vorherigen Satz verweisen und als Einzelsatz nicht verständlich sind. In einem zweiten Schritt wurden einige wenige Sätze von Hand ausgeschlossen, welche keinerlei politische Forderungen oder Erklärungen beinhalten oder Stilmittel beinhalten, welche sehr eindeutig auf eine bestimmte Partei hinweisen (z.B. der Gender-Star bei den GRÜNEN).

## Fragen, Kommentare, Feedback

... am besten per email an [nicolas.merz@wzb.eu](mailto:nicolas.merz@wzb.eu)
