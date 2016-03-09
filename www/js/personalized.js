$(document).ready(loadPage);


function loadPage() {

  //****** Materialize Design ******//

  $('select').material_select();
  //$('select').material_select('destroy');
  $(".button-collapse").sideNav();

  // datetime
  $('.datepicker').pickadate({
    labelMonthNext: 'Mes siguiente',
    labelMonthPrev: 'Mes anterior',
    labelMonthSelect: 'Elegir mes',
    labelYearSelect: 'Elegir un año',
    monthsFull: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    monthsShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Dic'],
    weekdaysFull: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    weekdaysShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    weekdaysLetter: ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
    today: 'Hoy',
    clear: 'Limpiar',
    close: 'Cerrar'
  });

  $('#dateFrom').click(function(event) {
    event.stopPropagation();
    $("#dateFrom").first().pickadate("picker").open();
  });

  $('#dateUntil').click(function(event) {
    event.stopPropagation();
    $("#dateUntil").first().pickadate("picker").open();
  });

  // noUiSlider

  var sliderVesselSpeed = document.getElementById('vesselSpeed');
  noUiSlider.create(sliderVesselSpeed, {
    start: [3, 10],
    connect: true,
    step: 0.1,
    range: {
      'min': 0,
      'max': 50
    },
    format: wNumb({
      decimals: 0
    })

  });

  var sliderOpacity = document.getElementById('opacity');
  noUiSlider.create(sliderOpacity, {
    start: [0.8],
    connect: false,
    step: 0.1,
    range: {
      'min': 0,
      'max': 1
    },
    format: wNumb({
      decimals: 0
    })
  });

  var sliderRadius = document.getElementById('radius');
  noUiSlider.create(sliderRadius, {
    start: [1],
    connect: false,
    step: 1,
    range: {
      'min': 1,
      'max': 30
    },
    format: wNumb({
      decimals: 0
    })
  });

  var sliderBlur = document.getElementById('blur');
  noUiSlider.create(sliderBlur, {
    start: [1],
    connect: false,
    step: 1,
    range: {
      'min': 1,
      'max': 20
    },
    format: wNumb({
      decimals: 0
    })
  });

  // accordion
  $('.collapsible').collapsible({
    accordion: false // A setting that changes the collapsible behavior to expandable instead of the default accordion style
  });

  // Toast event
  $('#btnReplay').click(toast);

  //Tooltip
  $('.tooltipped').tooltip({
    delay: 50
  });

  // Button menu events
  $('#btnInput').click(showInput);
  $('#btnSettings').click(showSettings);

  // Eventos disparados por Actualizar
  $('#btnReplay').click(settings);
  $('#btnReplay').click(input);


}


function settings() {
  var opacity = $('#opacity span').html();
  var radius = $('#radius span').html();
  var color = $('#color select').val();
  var blur = $('#blur span').html();
  Shiny.onInputChange("opacity", opacity);
  Shiny.onInputChange("radius", radius);
  Shiny.onInputChange("color", color);
  Shiny.onInputChange("blur", blur);
}

function input() {
  var aisCheck = $('#aisData').prop('checked');
  var vmsCheck = $('#vmsData').prop('checked');
  var dateFrom = $('#dateFrom span').html();
  alert(dateFrom);


  //Shiny.onInputChange("aisData", aisCheck);
  //Shiny.onInputChange("vmsData", vmsCheck);

  /*

    var dateFrom = $('#opacity span').html();
    var dateUntil = $('#radius span').html();
    var vesselSpeed = $('#color select').val();
    var vesselType = $('#blur span').html();
    var vesselName = $('#blur span').html();
    Shiny.onInputChange("opacity", opacity);
    Shiny.onInputChange("radius", radius);
    Shiny.onInputChange("color", color);
    Shiny.onInputChange("blur", blur);
    */
}



// Materialize.toast(message, displayLength, className, completeCallback);
function toast() {
  return Materialize.toast('¡100,000 puntos ploteados!', 4000, 'rounded'); // 4000 is the duration of the toast
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

function showSettings() {

  var inputVisible = $('#input').is(":visible");
  var settingsVisible = $('#settings').is(":visible");

  if (inputVisible) {
    $('#input').hide();
  }

  // hide and show
  if (settingsVisible) {
    $('#settings').hide();
  } else {
    $('#settings').show();
  }
  /*
    if (!settingsVisible && !inputVisible) {
      showMapAllWidth();
    } else {
      showMapOriginWidth();
    }
  */

}
