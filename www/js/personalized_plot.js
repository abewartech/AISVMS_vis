$(document).ready(loadPage);

function loadPage() {

  //****** Materialize Design ******//

  $('select').material_select();
  //$('select').material_select('destroy');
  $(".button-collapse").sideNav();

  // noUiSlider - plot.html

  var sliderSinePhase = document.getElementById('sinePhase');
  noUiSlider.create(sliderSinePhase, {
    start: [0],
    connect: false,
    step: 10,
    range: {
      'min': -180,
      'max': 180
    },
    format: wNumb({
      decimals: 1
    })
  });

  var sliderSineAmplitude = document.getElementById('sineAmplitude');
  noUiSlider.create(sliderSineAmplitude, {
    start: [1],
    connect: false,
    step: 0.1,
    range: {
      'min': -2,
      'max': 2
    },
    format: wNumb({
      decimals: 1
    })
  });

  //Tooltip
  $('.tooltipped').tooltip({
    delay: 50
  });

  // Button menu events
  $('#btnInput').click(showInput);
  //$('#btnSettings').click(showSettings);

  // Eventos disparados por Actualizar
  $('#btnReplay').click(settings);
  //$('#btnReplay').click(input);
  $('#btnReplay').onclick = function() {
    var btnReplay = true;
    Shiny.onInputChange("btnReplay", btnReplay);
  };

}

// Action functions
function settings() {

  var sinePhase = $('#sinePhase span').html();
  var sineAmplitude = $('#sineAmplitude span').html();
  Shiny.onInputChange("sinePhase", sinePhase);
  Shiny.onInputChange("sineAmplitude", sineAmplitude);
}

// Button menu events
function showMapAllWidth() {

  $('#mainPanel').removeClass("");
  $('#sidebarPanel').removeClass("");
  $('#mainPanel').addClass("col s12 m12 l12");
}

function showMapOriginWidth() {

  $('#mainPanel').removeClass("");
  $('#sidebarPanel').removeClass("");
  $('#sidebarPanel').addClass("col s12 m4 l3 z-depth-2");
  $('#mainPanel').addClass("col s12 m8 l9");
}

function showInput() {

  var inputVisible = $('#input').is(":visible");
  var settingsVisible = $('#settings').is(":visible");

  if (settingsVisible) {
    $('#settings').hide();
  }

  // hide and show
  if (inputVisible) {
    $('#input').hide();
  } else {
    $('#input').show();
  }

  /*
    if (!settingsVisible && !inputVisible) {
      showMapAllWidth();
    } else {
      showMapOriginWidth();
    }
  */

}
