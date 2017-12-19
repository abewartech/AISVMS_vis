$(document).ready(loadPage);

function loadPage() {

  //****** Materialize Design ******//

  $('select').material_select();
  $(".button-collapse").sideNav();

  // noUiSlider - plot.html

  //Tooltip
  $('.tooltipped').tooltip({
    delay: 50
  });
  
  // Button menu events
  $('#btnInput').click(showPlotsFullScreen);

}

function showPlotsFullScreen() {

  var inputVisible = $('#input').is(":visible");

  // hide and show
  if (inputVisible) {
    $('#input').hide();
    $('#mainPanel').attr("class", "col s12 m12 l12");
    $('#sidebarPanel').attr("class", "col s0 m0 l0 z-depth-0");
  } else {
    $('#input').show();
    $('#mainPanel').attr("class", "col s12 m8 l9");
    $('#sidebarPanel').attr("class", "col s12 m4 l3 z-depth-0");
  }

}
