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
    close: 'Cerrar',
    // Dropdown selectors
    selectYears: true,
    selectMonths: true,
    firstDay: 'Lunes',
    min: new Date(2012, 05, 8),
    max: new Date(2014, 05, 17),
    format: 'dd mmmm, yyyy',
    formatSubmit: 'yyyy-mm-dd'
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
  
  var sliderThresholdPoints = document.getElementById('thresholdPoints');
  noUiSlider.create(sliderThresholdPoints, {
    start: [1000],
    padding: 1,
    connect: false,
    step: 1000,
    range: {
      'min': 0,
      'max': 100000
    },
    format: wNumb({
      decimals: 0,
      //thousand: ',', 
      suffix: ' '
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
  //$('#btnReplay').click(toast);

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
  var thresholdPoints = $('#thresholdPoints span').html();
  var opacity = $('#opacity span').html();
  var radius = $('#radius span').html();
  var color = $('#color select').val();
  var blur = $('#blur span').html();
  Shiny.onInputChange("thresholdPoints", thresholdPoints);
  Shiny.onInputChange("opacity", opacity);
  Shiny.onInputChange("radius", radius);
  Shiny.onInputChange("color", color);
  Shiny.onInputChange("blur", blur);
}

function input() {

  var aisCheck = $('#aisData').prop('checked');
  var vmsCheck = $('#vmsData').prop('checked');
  var dateFrom = $('input[name=dateFrom_submit]').closest('input').attr('value');
  var dateUntil = $('input[name=_submit]').closest('input').attr('value');
  var selectVesselType = $('select[name=selectVesselType]').val();
  var selectVesselName = $('select[name=selectVesselName2]').val();
  var vesselSpeedMin = $('#vesselSpeed span').html();
  var vesselSpeedMax = $('#vesselSpeed').children('.noUi-handle noUi-handle-upper').closest('span').html();

  //alert(vesselSpeedMax);

  Shiny.onInputChange("aisData", aisCheck);
  Shiny.onInputChange("vmsData", vmsCheck);
  Shiny.onInputChange("dateFrom", dateFrom);
  Shiny.onInputChange("dateUntil", dateUntil);
  Shiny.onInputChange("selectVesselType", selectVesselType);
  Shiny.onInputChange("selectVesselName", selectVesselName);
  Shiny.onInputChange("vesselSpeedMin", vesselSpeedMin);
  //Shiny.onInputChange("vesselSpeedMax", vesselSpeedMax);

}

// Materialize.toast(message, displayLength, className, completeCallback);
//function toast() {
//  return Materialize.toast('¡100,000 puntos!', 4000, 'rounded'); // 4000 is the duration of the toast
//}

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
