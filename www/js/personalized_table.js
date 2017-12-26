$(document).ready(loadPage);

function loadPage() {

  //****** Materialize Design ******//

  //Tooltip
  $('.tooltipped').tooltip({
    delay: 50
  });

  // Modal
  $('.modal').modal({
    dismissible: false, // Modal can be dismissed by clicking outside of the modal
    opacity: 0.6, // Opacity of modal background
    inDuration: 300, // Transition in duration
    outDuration: 200, // Transition out duration
    startingTop: '4%', // Starting top style attribute
    endingTop: '10%', // Ending top style attribute
    ready: function(modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
      //console.log(modal, trigger);
    },
    complete: function() {} // Callback for Modal close
  });

  Shiny.addCustomMessageHandler("modal",
    function(modal) {
      $('#modal1').modal(modal);
    });
    
    //var searchVessels = [];
  
  function alertA(data) {
    alert(data);
  }
  
  Shiny.addCustomMessageHandler("searchVessels", 
  function(searchVessels) {
    
    alertA(searchVessels);
    
  });
}