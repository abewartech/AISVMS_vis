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

  // noUiSlider - index.html
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
  
  var sliderOpacity = document.getElementById('opacitySlider');
  noUiSlider.create(sliderOpacity, {
    start: [0.8],
    connect: false,
    step: 0.01,
    range: {
      'min': 0,
      'max': 1
    },
    format: wNumb({
      decimals: 0
    })
  });

  var sliderRadius = document.getElementById('radiusSlider');
  noUiSlider.create(sliderRadius, {
    start: [1],
    connect: false,
    step: 0.1,
    range: {
      'min': 1,
      'max': 20
    },
    format: wNumb({
      decimals: 0
    })
  });

  var sliderBlur = document.getElementById('blurSlider');
  noUiSlider.create(sliderBlur, {
    start: [1],
    connect: false,
    step: 0.25,
    range: {
      'min': 1,
      'max': 15
    },
    format: wNumb({
      decimals: 0
    })
  });

  // Load vessels data
  var vesselsData = "";
  vesselsData = JSON.parse(vessels);

  // Search vessel by name
  $('#searchVesselNameInput').material_chip({
    data: [{tag: 'ALDEBARAN I'}],
    autocompleteOptions: {
      data: vesselsData,
      limit: 20,
      minLength: 1
    }
  });

  //$('.chips').on('chip.add', function(e, chip) {});
  //$('.chips').on('chip.delete', function(e, chip) {});
  //$('.chips').on('chip.select', function(e, chip) {});

  // Categories
  $('#checkCatA').click(changeVesselsNamesByCat);
  $('#checkCatB').click(changeVesselsNamesByCat);
  $('#checkCatC').click(changeVesselsNamesByCat);
  $('#checkCatD').click(changeVesselsNamesByCat);
  $('#checkAltura').click(changeVesselsNamesByCat);
  $('#checkCosteros').click(changeVesselsNamesByCat);

  $('select[name=selectVesselCountry]').change(showFormCat);

  // Button menu events
  $('#btnInput').click(showMapFullScreen);

  // Eventos disparados por Actualizar
  $('#btnReplay').click(sendDataToServer);

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
}

//*****************//

// Global variables
var opacity = $('#opacitySlider span').html();
var radius = $('#radiusSlider span').html();
var color = $('#colorSelect select').val();
var blur = $('#blurSlider span').html();
var thresholdPoints = $('#thresholdPointsInput').val();
var dateFrom = $('input[name=dateFrom_submit]').attr('value');
var dateUntil = $('input[name=_submit]').attr('value');
var vesselSpeedMin = $('#vesselSpeedSlider .noUi-handle-lower .range-label span').html();
var vesselSpeedMax = $('#vesselSpeedSlider .noUi-handle-upper .range-label span').html();
var checkCatA = $('#checkCatA').prop('checked');
var checkCatB = $('#checkCatB').prop('checked');
var checkCatC = $('#checkCatC').prop('checked');
var checkCatD = $('#checkCatD').prop('checked');
var checkAltura = $('#checkAltura').prop('checked');
var checkCosteros = $('#checkCosteros').prop('checked');
var searchVesselName = "ALDEBARAN I";
var catVesselName = "";

// Action functions
function changeVesselsNamesByCat() {

  checkCatA = $('#checkCatA').prop('checked');
  checkCatB = $('#checkCatB').prop('checked');
  checkCatC = $('#checkCatC').prop('checked');
  checkCatD = $('#checkCatD').prop('checked');
  checkAltura = $('#checkAltura').prop('checked');
  checkCosteros = $('#checkCosteros').prop('checked');

  var vesselsCat = "{";
  var arrayOfCat = [];

  if (checkCatA) {

    // Load catA vessels data
    var vesselsCatA = JSON.parse(catA);

    for (var keyA in vesselsCatA) {
      var valA = vesselsCatA[keyA];
      var objA = {};
      objA.tag = keyA;
      arrayOfCat.push(objA);
      vesselsCat = vesselsCat + '\"' + keyA + '\":\"' + valA + '\",';

    }

  }
  if (checkCatB) {

    // Load catB vessels data
    var vesselsCatB = JSON.parse(catB);

    for (var keyB in vesselsCatB) {
      var valB = vesselsCatB[keyB];
      var objB = {};
      objB.tag = keyB;
      arrayOfCat.push(objB);
      vesselsCat = vesselsCat + '\"' + keyB + '\":\"' + valB + '\",';

    }

  }
  if (checkCatC) {

    // Load catC vessels data
    var vesselsCatC = JSON.parse(catC);

    for (var keyC in vesselsCatC) {
      var valC = vesselsCatC[keyC];
      var objC = {};
      objC.tag = keyC;
      arrayOfCat.push(objC);
      vesselsCat = vesselsCat + '\"' + keyC + '\":\"' + valC + '\",';

    }

  }
  if (checkCatD) {

    // Load catC vessels data
    var vesselsCatD = JSON.parse(catD);

    for (var keyD in vesselsCatD) {
      var valD = vesselsCatD[keyD];
      var objD = {};
      objD.tag = keyD;
      arrayOfCat.push(objD);
      vesselsCat = vesselsCat + '\"' + keyD + '\":\"' + valD + '\",';

    }

  }
  if (checkAltura) {

    // Load catC vessels data
    var vesselsAltura = JSON.parse(altura);

    for (var keyAltura in vesselsAltura) {
      var valAltura = vesselsAltura[keyAltura];
      var objAltura = {};
      objAltura.tag = keyAltura;
      arrayOfCat.push(objAltura);
      vesselsCat = vesselsCat + '\"' + keyAltura + '\":\"' + valAltura + '\",';

    }

  }
  if (checkCosteros) {

    // Load catC vessels data
    var vesselsCosteros = JSON.parse(costeros);

    for (var keyCosteros in vesselsCosteros) {
      var valCosteros = vesselsCosteros[keyCosteros];
      var objCosteros = {};
      objCosteros.tag = keyCosteros;
      arrayOfCat.push(objCosteros);
      vesselsCat = vesselsCat + '\"' + keyCosteros + '\":\"' + valCosteros + '\",';

    }

  }

  vesselsCat = vesselsCat + '\" \":\ null\}';
  objVesselsCat = JSON.parse(vesselsCat);

  // Clear chips
  $('#catVesselNameInput').material_chip({});
  $('#searchVesselNameInput').material_chip({});

  // Search vessel by name
  $('#catVesselNameInput').material_chip({
    data: arrayOfCat,
    autocompleteOptions: {
      data: objVesselsCat,
      limit: 20,
      minLength: 1
    }
  });

}

// Check for settings in heatmap
function settings() {

  // Return variable
  var differentSettings = false;

  // Get client data
  var opacityAux = $('#opacitySlider span').html();
  var radiusAux = $('#radiusSlider span').html();
  var colorAux = $('#colorSelect select').val();
  var blurAux = $('#blurSlider span').html();

  // Check if client data is the same as previous state
  if (opacity != opacityAux) {
    differentSettings = true;
    opacity = opacityAux;
  }

  if (radius != radiusAux) {
    differentSettings = true;
    radius = radiusAux;
  }

  if (color != colorAux) {
    differentSettings = true;
    color = colorAux;
  }

  if (blur != blurAux) {
    differentSettings = true;
    blur = blurAux;
  }

  return differentSettings;

}

// Check for query parameters
function query() {

  // Return variable
  var differentSettings = false;

  // Get data from client
  var thresholdPointsAux = $('#thresholdPointsInput').val();
  var dateFromAux = $('input[name=dateFrom_submit]').attr('value');
  var dateUntilAux = $('input[name=_submit]').attr('value');
  var vesselSpeedMinAux = $('#vesselSpeedSlider .noUi-handle-lower .range-label span').html();
  var vesselSpeedMaxAux = $('#vesselSpeedSlider .noUi-handle-upper .range-label span').html();

  // Check if client data is the same as previous state
  if (thresholdPoints != thresholdPointsAux) {
    differentSettings = true;
    thresholdPoints = thresholdPointsAux;
  }

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

  // Fishing vessels categories
  if (checkCatA | checkCatB | checkCatC | checkCatD | checkAltura | checkCosteros) {

    // Get data from categories
    var catDataAux = $('#catVesselNameInput').material_chip('data');
    var catLenAux = catDataAux.length;
    var catVesselNameAux = "";

    for (var jAux = 0; jAux < catLenAux; jAux = jAux + 1) {
      catVesselNameAux += catDataAux[jAux].tag + "\n";
    }

    if (catVesselName != catVesselNameAux) {
      differentSettings = true;
      catVesselName = catVesselNameAux;
    }
  }

  return differentSettings;
}

// Send data to server if data is different
function sendDataToServer() {

  var differentSettings = settings();
  var differentQuery = query();

  // Logs
  console.log("Different settings: " + differentSettings);
  console.log("Different query: " + differentQuery);
  console.log("Search vessels: \n" + searchVesselName);
  console.log("Vessels from categories: \n" + catVesselName);

  if (differentSettings) {

    // Send config data to server
    Shiny.onInputChange("opacity", opacity);
    Shiny.onInputChange("radius", radius);
    Shiny.onInputChange("color", color);
    Shiny.onInputChange("blur", blur);
  }

  if (differentQuery) {

    // Send query data to server
    Shiny.onInputChange("thresholdPoints", thresholdPoints);
    Shiny.onInputChange("dateFrom", dateFrom);
    Shiny.onInputChange("dateUntil", dateUntil);
    Shiny.onInputChange("vesselSpeedMin", vesselSpeedMin);
    Shiny.onInputChange("vesselSpeedMax", vesselSpeedMax);
    Shiny.onInputChange("catA", checkCatA);
    Shiny.onInputChange("catB", checkCatB);
    Shiny.onInputChange("catC", checkCatC);
    Shiny.onInputChange("catD", checkCatD);
    Shiny.onInputChange("catAltura", checkAltura);
    Shiny.onInputChange("catCosteros", checkCosteros);
    Shiny.onInputChange("searchVesselName", searchVesselName);
    Shiny.onInputChange("catVesselName", catVesselName);
  }

  //var aisCheck = $('#aisDataCheck').prop('checked');
  //Shiny.onInputChange("aisData", aisCheck);
  //var selectVesselType = $('select[name=selectVesselType]').val();
  //var selectVesselName = $('select[name=selectVesselName2]').val();
  //Shiny.onInputChange("selectVesselType", selectVesselType);
  //Shiny.onInputChange("selectVesselName", selectVesselName);

}

// Show and Hide UI events
function showFormCat() {

  var selectVesselCountry = $('select[name=selectVesselCountry]').val();

  if (selectVesselCountry == "ury" | selectVesselCountry == "argury") {
    $('#formCatUry').attr('class', 'show');
  } else {
    $('#formCatUry').attr('class', 'hide');
  }

  if (selectVesselCountry == "arg" | selectVesselCountry == "argury") {
    $('#formCatArg').attr('class', 'show');
  } else {
    $('#formCatArg').attr('class', 'hide');
  }
}

function showMapFullScreen() {

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