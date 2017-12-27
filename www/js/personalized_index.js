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

  // Eventos disparados al hacer check en capas
  $('#checkLimURY').click(addShapefile);

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

  // Set session storage
  setSessionStorage();

  Shiny.addCustomMessageHandler("searchVessels",
    function(searchVessels) {

      var searchVesselsData = [];

      for (var i = 0; i < searchVessels.length; i++) {
        var obj = {};
        obj.tag = searchVessels[i];
        searchVesselsData.push(obj);
      }

      // Search vessel by name
      $('#searchVesselNameInput').material_chip({
        data: searchVesselsData,
        autocompleteOptions: {
          data: vesselsData,
          limit: 20,
          minLength: 1
        }

      });

    });

  // Modal query Info
  $('#btnQueryInfo').click(showModalQueryInfo);


}


//****************************************************************************//


// Action functions
function changeVesselsNamesByCat() {

  // Get client data
  var checkCatA = $('#checkCatA').prop('checked');
  var checkCatB = $('#checkCatB').prop('checked');
  var checkCatC = $('#checkCatC').prop('checked');
  var checkCatD = $('#checkCatD').prop('checked');
  var checkAltura = $('#checkAltura').prop('checked');
  var checkCosteros = $('#checkCosteros').prop('checked');

  var vesselsCat = "{";
  var arrayOfCat = [];

  if (checkCatA) {

    // Load catA vessels data
    var vesselsCatA = JSON.parse(catA);
    var keyA;

    for (keyA in vesselsCatA) {
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
    var keyB;

    for (keyB in vesselsCatB) {
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
    var keyC;

    for (keyC in vesselsCatC) {
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
    var keyD;

    for (keyD in vesselsCatD) {
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
    var keyAltura;

    for (keyAltura in vesselsAltura) {
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
    var keyCosteros;

    for (keyCosteros in vesselsCosteros) {
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

  // Set session storage
  sessionStorage.setItem("checkCatA", checkCatA);
  sessionStorage.setItem("checkCatB", checkCatB);
  sessionStorage.setItem("checkCatC", checkCatC);
  sessionStorage.setItem("checkCatD", checkCatD);
  sessionStorage.setItem("checkAltura", checkAltura);
  sessionStorage.setItem("checkCosteros", checkCosteros);

}

// Check for settings in heatmap
function settings() {

  // Return variable
  var differentSettings = false;

  // Get client data
  var opacity = $('#opacitySlider span').html();
  var radius = $('#radiusSlider span').html();
  var color = $('#colorSelect select').val();
  var blur = $('#blurSlider span').html();

  // Get session data 
  var opacityOld = sessionStorage.getItem("opacity");
  var radiusOld = sessionStorage.getItem("radius");
  var colorOld = sessionStorage.getItem("color");
  var blurOld = sessionStorage.getItem("blur");

  // Check if client data is the same as previous state
  if (opacity != opacityOld) {
    differentSettings = true;
    sessionStorage.setItem("opacity", opacity);
  }

  if (radius != radiusOld) {
    differentSettings = true;
    sessionStorage.setItem("radius", radius);
  }

  if (color != colorOld) {
    differentSettings = true;
    sessionStorage.setItem("color", color);
  }

  if (blur != blurOld) {
    differentSettings = true;
    sessionStorage.setItem("blur", blur);
  }

  return differentSettings;

}

// Check for query parameters
function query() {

  // Return variable
  var differentSettings = false;

  // Get data from client
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

  // Get session data 
  var thresholdPointsOld = sessionStorage.getItem("thresholdPoints");
  var dateFromOld = sessionStorage.getItem("dateFrom");
  var dateUntilOld = sessionStorage.getItem("dateUntil");
  var vesselSpeedMinOld = sessionStorage.getItem("vesselSpeedMin");
  var vesselSpeedMaxOld = sessionStorage.getItem("vesselSpeedMax");

  // Check if client data is the same as previous state
  if (thresholdPoints != thresholdPointsOld) {
    differentSettings = true;
    sessionStorage.setItem("thresholdPoints", thresholdPoints);
  }

  if (dateFrom != dateFromOld) {
    differentSettings = true;
    sessionStorage.setItem("dateFrom", dateFrom);
  }

  if (dateUntil != dateUntilOld) {
    differentSettings = true;
    sessionStorage.setItem("dateUntil", dateUntil);
  }

  if (vesselSpeedMin != vesselSpeedMinOld) {
    differentSettings = true;
    sessionStorage.setItem("vesselSpeedMin", vesselSpeedMin);
  }

  if (vesselSpeedMax != vesselSpeedMaxOld) {
    differentSettings = true;
    sessionStorage.setItem("vesselSpeedMax", vesselSpeedMax);
  }

  // Get search data vessels
  var data = $('#searchVesselNameInput').material_chip('data');
  var len = data.length;
  var searchVesselName = "";
  var searchVesselNameOld = sessionStorage.getItem("searchVesselName");

  var i = 0;

  for (i; i < len; i = i + 1) {
    searchVesselName += data[i].tag + "\n";
  }

  if (searchVesselName != searchVesselNameOld) {
    differentSettings = true;
    sessionStorage.setItem("searchVesselName", searchVesselName);
  }

  // Fishing vessels categories
  if (checkCatA | checkCatB | checkCatC | checkCatD | checkAltura | checkCosteros) {

    // Get data from categories
    var catData = $('#catVesselNameInput').material_chip('data');
    var catLen = catData.length;
    var catVesselName = "";
    var catVesselNameOld = sessionStorage.getItem("catVesselName");

    var j = 0;

    for (j; j < catLen; j = j + 1) {
      catVesselName += catData[j].tag + "\n";
    }

    if (catVesselName != catVesselNameOld) {
      differentSettings = true;
      sessionStorage.setItem("catVesselName", catVesselName);
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

  if (differentSettings) {

    // Get session data 
    var opacity = sessionStorage.getItem("opacity");
    var radius = sessionStorage.getItem("radius");
    var color = sessionStorage.getItem("color");
    var blur = sessionStorage.getItem("blur");

    // Send config data to server
    Shiny.onInputChange("opacity", opacity);
    Shiny.onInputChange("radius", radius);
    Shiny.onInputChange("color", color);
    Shiny.onInputChange("blur", blur);
  }

  if (differentQuery) {

    // Get session data 
    var thresholdPoints = sessionStorage.getItem("thresholdPoints");
    var dateFrom = sessionStorage.getItem("dateFrom");
    var dateUntil = sessionStorage.getItem("dateUntil");
    var vesselSpeedMin = sessionStorage.getItem("vesselSpeedMin");
    var vesselSpeedMax = sessionStorage.getItem("vesselSpeedMax");
    var catA = (sessionStorage.getItem("checkCatA") == 'true');
    var catB = (sessionStorage.getItem("checkCatB") == 'true');
    var catC = (sessionStorage.getItem("checkCatC") == 'true');
    var catD = (sessionStorage.getItem("checkCatD") == 'true');
    var catAltura = (sessionStorage.getItem("checkAltura") == 'true');
    var catCosteros = (sessionStorage.getItem("checkCosteros") == 'true');
    var searchVesselName = sessionStorage.getItem("searchVesselName");
    var catVesselName = sessionStorage.getItem("catVesselName");

    // Send query data to server
    Shiny.onInputChange("thresholdPoints", thresholdPoints);
    Shiny.onInputChange("dateFrom", dateFrom);
    Shiny.onInputChange("dateUntil", dateUntil);
    Shiny.onInputChange("vesselSpeedMin", vesselSpeedMin);
    Shiny.onInputChange("vesselSpeedMax", vesselSpeedMax);
    Shiny.onInputChange("catA", catA);
    Shiny.onInputChange("catB", catB);
    Shiny.onInputChange("catC", catC);
    Shiny.onInputChange("catD", catD);
    Shiny.onInputChange("catAltura", catAltura);
    Shiny.onInputChange("catCosteros", catCosteros);
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

// Session Storage
function setSessionStorage() {

  // Check browser support
  if (typeof(Storage) !== "undefined") {

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

    // Store
    sessionStorage.setItem("opacity", opacity);
    sessionStorage.setItem("radius", radius);
    sessionStorage.setItem("color", color);
    sessionStorage.setItem("blur", blur);
    sessionStorage.setItem("thresholdPoints", thresholdPoints);
    sessionStorage.setItem("dateFrom", dateFrom);
    sessionStorage.setItem("dateUntil", dateUntil);
    sessionStorage.setItem("vesselSpeedMin", vesselSpeedMin);
    sessionStorage.setItem("vesselSpeedMax", vesselSpeedMax);
    sessionStorage.setItem("checkCatA", checkCatA);
    sessionStorage.setItem("checkCatB", checkCatB);
    sessionStorage.setItem("checkCatC", checkCatC);
    sessionStorage.setItem("checkCatD", checkCatD);
    sessionStorage.setItem("checkAltura", checkAltura);
    sessionStorage.setItem("checkCosteros", checkCosteros);
    sessionStorage.setItem("searchVesselName", searchVesselName);
    sessionStorage.setItem("catVesselName", catVesselName);

    // Retrieve
    //alert(sessionStorage.getItem("lastname"));

  } else {
    alert("Disculpas, tú navegador no soporta Almacenamiento Web... =(");
  }
}

function showModalQueryInfo() {
  
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
  
  $('#modal2').modal("open");
  $('#modal2DbInput').html('<i class="fa fa-database fa-fw" aria-hidden="true"></i>&nbsp; <b>Base de Datos:</b> AIS / <b>Límite de posiciones:</b> ' + thresholdPoints)
  $('#modal2TimeInput').html('<i class="fa fa-calendar fa-fw" aria-hidden="true"></i>&nbsp; <b>Fechas:</b> ' + dateFrom + ' / ' + dateUntil)
  $('#modal2SearchInput').html('<i class="fa fa-search fa-fw" aria-hidden="true"></i>&nbsp; <b>Búsqueda:</b> ' + searchVesselName)

 
}


// Cookies
/*
function setCookie(cname, cvalue, exdays) {
var d = new Date();
d.setTime(d.getTime() + (exdays*24*60*60*1000));
var expires = "expires=" + d.toGMTString();
document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
var name = cname + "=";
var decodedCookie = decodeURIComponent(document.cookie);
var ca = decodedCookie.split(';');
for(var i = 0; i < ca.length; i++) {
var c = ca[i];
while (c.charAt(0) == ' ') {
c = c.substring(1);
}
if (c.indexOf(name) == 0) {
return c.substring(name.length, c.length);
}
}
return "";
}

function checkCookie() {
var user = getCookie("username");
if (user != "") {
alert("Welcome again " + user);
} else {
user = prompt("Please enter your name:","");
if (user != "" && user != null) {
setCookie("username", user, 30);
}
}
}
*/