$(document).ready(loadPage);

function loadPage() {

  //****** Materialize Design ******//

  $('select').material_select();
  $(".button-collapse").sideNav();
  // Collapsible sections in sidebar
  $('.collapsible').collapsible();

  //Tooltip
  $('.tooltipped').tooltip({
    delay: 50
  });

  // datetime
  $('.datepicker').pickadate({
    labelMonthNext: 'Mes siguiente',
    labelMonthPrev: 'Mes anterior',
    labelMonthSelect: 'Elegir mes',
    labelYearSelect: 'Elegir un año',
    monthsFull: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    monthsShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Dic'],
    weekdaysFull: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    weekdaysShort: ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'],
    weekdaysLetter: ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
    today: 'Hoy',
    clear: 'Limpiar',
    close: 'OK',
    // Dropdown selectors
    selectYears: true,
    selectMonths: true,
    firstDay: 'Lunes',
    min: new Date(2012, 05, 8),
    max: new Date(2014, 05, 17),
    format: 'dd mmmm, yyyy',
    formatSubmit: 'yyyy-mm-dd',
    closeOnSelect: true,
    closeOnClear: true
  });

  $('#dateFromDatePicker').click(function(event) {
    event.stopPropagation();
    $("#dateFromDatePicker").first().pickadate("picker").open();
  });

  $('#dateUntilDatePicker').click(function(event) {
    event.stopPropagation();
    $("#dateUntilDatePicker").first().pickadate("picker").open();
  });
  
  // noUiSlider - plot.html
  var sliderVesselSpeed = document.getElementById('vesselSpeedSlider');
  noUiSlider.create(sliderVesselSpeed, {
    start: [0, 15],
    connect: true,
    step: 0.1,
    range: {
      'min': 0,
      'max': 30
    },
    format: wNumb({
      decimals: 0
    })

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

  Shiny.addCustomMessageHandler("myCallbackHandler",
    function(modal) {
      $('#modal1').modal(modal);
    });
    
  // Eventos disparados por Actualizar
  $('#btnReplay').click(sendDataToServer);

  // Button menu events
  $('#btnInput').click(showPlotsFullScreen);

}

// Global variables
var dateFrom = $('input[name=dateFrom_submit]').attr('value');
var dateUntil = $('input[name=_submit]').attr('value');
var vesselSpeedMin = $('#vesselSpeedSlider .noUi-handle-lower .range-label span').html();
var vesselSpeedMax = $('#vesselSpeedSlider .noUi-handle-upper .range-label span').html();

// Check for query parameters
function query() {

  // Return variable
  var differentSettings = false;

  // Get data from client
  //var thresholdPointsAux = $('#thresholdPointsInput').val();
  var dateFromAux = $('input[name=dateFrom_submit]').attr('value');
  var dateUntilAux = $('input[name=_submit]').attr('value');
  var vesselSpeedMinAux = $('#vesselSpeedSlider .noUi-handle-lower .range-label span').html();
  var vesselSpeedMaxAux = $('#vesselSpeedSlider .noUi-handle-upper .range-label span').html();

  // Check if client data is the same as previous state
  /*
  if (thresholdPoints != thresholdPointsAux) {
    differentSettings = true;
    thresholdPoints = thresholdPointsAux;
  }
  */

  if (dateFrom != dateFromAux) {
    differentSettings = true;
    dateFrom = dateFromAux;
  }

  if (dateUntil != dateUntilAux) {
    differentSettings = true;
    dateUntil = dateUntilAux;
  }

  if (vesselSpeedMin != vesselSpeedMinAux) {
    differentSettings = true;
    vesselSpeedMin = vesselSpeedMinAux;
  }

  if (vesselSpeedMax != vesselSpeedMaxAux) {
    differentSettings = true;
    vesselSpeedMax = vesselSpeedMaxAux;
  }

  // Get search data vessels
  /*
  var dataAux = $('#searchVesselNameInput').material_chip('data');
  var lenAux = dataAux.length;
  var searchVesselNameAux = "";

  for (var iAux = 0; iAux < lenAux; iAux = iAux + 1) {
    searchVesselNameAux += dataAux[iAux].tag + "\n";
  }

  if (searchVesselName != searchVesselNameAux) {
    differentSettings = true;
    searchVesselName = searchVesselNameAux;
  }
  */

  return differentSettings;
}

// Send data to server if data is different
function sendDataToServer() {

  //var differentSettings = settings();
  var differentSettings = false;
  var differentQuery = query();

  // Logs
  console.log("Different settings: " + differentSettings);
  console.log("Different query: " + differentQuery);
  //console.log("Search vessels: \n" + searchVesselName);
  //console.log("Vessels from categories: \n" + catVesselName);

  if (differentSettings) {

    // Send config data to server
    Shiny.onInputChange("opacityPlot", opacity);
    Shiny.onInputChange("radiusPlot", radius);
    Shiny.onInputChange("colorPlot", color);
    Shiny.onInputChange("blurPlot", blur);
  }

  if (differentQuery) {

    // Send query data to server
    //Shiny.onInputChange("thresholdPointsPlot", thresholdPoints);
    Shiny.onInputChange("dateFromPlot", dateFrom);
    Shiny.onInputChange("dateUntilPlot", dateUntil);
    Shiny.onInputChange("vesselSpeedMinPlot", vesselSpeedMin);
    Shiny.onInputChange("vesselSpeedMaxPlot", vesselSpeedMax);
    //Shiny.onInputChange("searchVesselNamePlot", searchVesselName);
  }

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
