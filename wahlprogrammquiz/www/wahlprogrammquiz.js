$(document).ready(function() {
 $( ".partyButton" ).click(function() {
   Shiny.onInputChange("partyButton", this.id);
 });

 function randomBars() {
   var a = new Array(6);
   for (i = 0; i < 6; i++) { 
     a[i] = Math.random() * $("#linkeBarDiv").height();
   }
   animateBars(a);
 }
  $(document).on("keypress", function (e) {
   console.log(e.which);
   switch(e.which) {
     case 114:
       resetBars();
     break;
     case 32:
       randomBars();
     break;
     default:
     break;
   }
 });
 
 
 function resetBars() {
   $(".bar").animate({'height': "0"}, 200);
 }
 function animateBars(values) {
   $(".bar").each(function( i ) {
     $(this).animate({"height":  values[i] }, 500);
  });
 }
 


 
});