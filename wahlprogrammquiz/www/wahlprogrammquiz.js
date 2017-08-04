$(document).ready(function() {
  $(".per").hide();
  
 $( ".partyButton" ).click(function() {
   Shiny.onInputChange("partyButton", this.id);
 });


/*TEMPORARY!!*/
 function randomBars() {
   var a = new Array(6);
   for (i = 0; i < 6; i++) { 
     a[i] = Math.random();
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
 /*END TEMPORARY!!*/
 
 Shiny.addCustomMessageHandler("barValuesCallbackHandler",     
  function(message) {
    console.log(message.percentages);
    console.log(message.opacities);
    animateBars(message.percentages, message.opacities);
  }
 );
 Shiny.addCustomMessageHandler("resetValuesCallbackHandler",     
  function(message) {
    resetBars();
    Shiny.onInputChange("partyButton", "none");
  }
 );
 
 
 function resetBars() {
   $(".per").hide(200);
   $(".bar").animate({'height': "0"}, 200);
   $(".partyButton").each(function( i ) {
    $(this).animate({"opacity": 1.0 });
   });

 }
 function animateBars(percentages, opacities) {
   $(".per").show();
   $(".partyButton").each(function( i ) {
     $(this).animate({"opacity": opacities[i] });
   });
   $(".bar").each(function( i ) {
     $(this).animate({"height":  (percentages[i] * $(this).parent().height()),
                      "opacity": opacities[i] },
         {duration: 800,
          easing:'swing',
          step: function() { // called on every step
          // Update the element's text with rounded-up value:
          var myHeight = $(this).height();
          var parentHeight = $(this).parent().height();
          console.log(i+"  "+ (myHeight/parentHeight));
          var percentage = Math.round(100*myHeight/parentHeight);
          console.log(i+" $(this).height() " + $(this).height());
          console.log(i+" parent.height() " + $(this).parent().height());
          console.log(i+" per " + percentage);
          $(this).parent().children(".per").text(percentage + "%");
          }
         }
  );
  });
 }
 
});

function toggleOverlay() {
  var element = document.getElementById("AboutOverlay");
  console.log("toggling")
  
    if (element) {
        var display = element.style.display;

        if (display == "none") {
            element.style.display = "block";
        } else {
            element.style.display = "none";
        }
    }
}