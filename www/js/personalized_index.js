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

  $('#dateFrom').click(function(event) {
    event.stopPropagation();
    $("#dateFrom").first().pickadate("picker").open();
  });

  $('#dateUntil').click(function(event) {
    event.stopPropagation();
    $("#dateUntil").first().pickadate("picker").open();
  });

  // noUiSlider - index.html
  
  var sliderVesselSpeed = document.getElementById('vesselSpeed');
  noUiSlider.create(sliderVesselSpeed, {
    start: [0, 20],
    connect: true,
    step: 0.1,
    range: {
      'min': 0,
      'max': 20
    },
    format: wNumb({
      decimals: 0
    })

  });
  
  var sliderThresholdPoints = document.getElementById('thresholdPoints');
  noUiSlider.create(sliderThresholdPoints, {
    start: 1,
    padding: 0.1,
    connect: false,
    step: 0.2,
    range: {
      'min': 0,
      'max': 20
    },
    format: wNumb({
      decimals: 0,
      //thousand: ',', 
      suffix: 'M'
    })
  });

  var sliderOpacity = document.getElementById('opacity');
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

  var sliderRadius = document.getElementById('radius');
  noUiSlider.create(sliderRadius, {
    start: [1],
    connect: false,
    step: 0.1,
    range: {
      'min': 1,
      'max': 10
    },
    format: wNumb({
      decimals: 0
    })
  });

  var sliderBlur = document.getElementById('blur');
  noUiSlider.create(sliderBlur, {
    start: [1],
    connect: false,
    step: 0.1,
    range: {
      'min': 1,
      'max': 5
    },
    format: wNumb({
      decimals: 0
    })
  });
  
  // Load vessels data
  var vesselsData = "";
  
  function loadJSON() {
    vesselsData = JSON.parse(vessels);
    console.log("Vessels data loaded.");
  }

  loadJSON();
  
  // Search vessel by name
  $('#searchVesselName').material_chip({
    placeholder: '',
    autocompleteOptions: {
      data: vesselsData,
      limit: 20,
      minLength: 1
    }
  });
  
  $('.chips').on('chip.add', function(e, chip){});
  $('.chips').on('chip.delete', function(e, chip){});
  $('.chips').on('chip.select', function(e, chip){});
  
  // Categories
  $('#catA').click(changeSearchVesselsNames);
  $('#catB').click(changeSearchVesselsNames);
  $('#catC').click(changeSearchVesselsNames);
        
  // Collapsible sections in sidebar
  $('.collapsible').collapsible();

  //Tooltip
  $('.tooltipped').tooltip({
    delay: 50
  });

  // Button menu events
  $('#btnInput').click(showInput);

  // Eventos disparados por Actualizar
  $('#btnReplay').click(settings);
  $('#btnReplay').click(input);
  $('#btnReplay').onclick = function() {
    var btnReplay = true;
    Shiny.onInputChange("btnReplay", btnReplay);
  };

}

// Action functions
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
  var dateFrom = $('input[name=dateFrom_submit]').attr('value');
  var dateUntil = $('input[name=_submit]').attr('value');
  var vesselSpeedMin = $('#vesselSpeed .noUi-handle-lower .range-label span').html();
  var vesselSpeedMax = $('#vesselSpeed .noUi-handle-upper .range-label span').html();
 
  // recorrer data para cada vessel
  var data = $('#searchVesselName').material_chip('data');
  var searchVesselName = "";
  var len = data.length;
  
  for (var i = 0; i < len; i = i + 1) {
    searchVesselName +=  data[i].tag + "\n";
  }
  
  Shiny.onInputChange("aisData", aisCheck);
  Shiny.onInputChange("dateFrom", dateFrom);
  Shiny.onInputChange("dateUntil", dateUntil);
  Shiny.onInputChange("vesselSpeedMin", vesselSpeedMin);
  Shiny.onInputChange("vesselSpeedMax", vesselSpeedMax);
  Shiny.onInputChange("searchVesselName", searchVesselName);
  
  //var selectVesselType = $('select[name=selectVesselType]').val();
  //var selectVesselName = $('select[name=selectVesselName2]').val();
  //Shiny.onInputChange("selectVesselType", selectVesselType);
  //Shiny.onInputChange("selectVesselName", selectVesselName);
  
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
  $('#sidebarPanel').addClass("col s12 m4 l3");
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

function changeSearchVesselsNames() {

// Fishing vessels categories
var checkCatA = $('#catA').prop('checked');
var checkCatB = $('#catB').prop('checked');
var checkCatC = $('#catC').prop('checked');
var checkCatD = $('#catD').prop('checked');

var vesselsCat = "{";
var arrayOfCat = [];

if(checkCatA) {

// Load catA vessels data
var vesselsCatA = JSON.parse(catA);

for (var keyA in vesselsCatA) {
  var valA = vesselsCatA[keyA];
  var objA = {};
  objA.tag = keyA;
  arrayOfCat.push(objA);
  vesselsCat = vesselsCat +  '\"' + keyA + '\":\"' + valA + '\",';   
}

} 
if(checkCatB) {

// Load catA vessels data
var vesselsCatB = JSON.parse(catB);

for (var keyB in vesselsCatB) {
  var valB = vesselsCatB[keyB];
  var objB = {};
  objB.tag = keyB;
  arrayOfCat.push(objB);
  vesselsCat = vesselsCat +  '\"' + keyB + '\":\"' + valB + '\",'; 

}

}
if(checkCatC) {

// Load catA vessels data
var vesselsCatC = JSON.parse(catC);

for (var keyC in vesselsCatC) {
  var valC = vesselsCatC[keyC];
  var objC = {};
  objC.tag = keyC;
  arrayOfCat.push(objC);
  vesselsCat = vesselsCat +  '\"' + keyC + '\":\"' + valC + '\",'; 

}

}

vesselsCat = vesselsCat + '\" \":\ null\}';
objVesselsCat = JSON.parse(vesselsCat);

// Clear chips
$('#catVesselName').material_chip({});

// Search vessel by name
$('#catVesselName').material_chip({
  data: arrayOfCat,
  autocompleteOptions: {
    data: objVesselsCat,
    limit: 20,
    minLength: 1
    }
  });

// recorrer data para cada vessel en categorías
var catData = $('#catVesselName').material_chip('data');
var catVesselName = "";
var catLen = catData.length;
  
for (var i2 = 0; i2 < catLen; i2 = i2 + 1) {
  catVesselName +=  catData[i2].tag + "\n";
  
}
  
Shiny.onInputChange("catA", checkCatA);
Shiny.onInputChange("catB", checkCatB);
Shiny.onInputChange("catC", checkCatC);
Shiny.onInputChange("catD", checkCatD);
Shiny.onInputChange("catVesselName", catVesselName);
  
}