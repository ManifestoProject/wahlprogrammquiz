$(document).ready(function() {
 $( ".partyButton" ).click(function() {
   Shiny.onInputChange("partyButton", this.id);
 });
});