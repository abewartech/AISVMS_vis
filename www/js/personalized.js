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
  var slider1 = document.getElementById('vesselSpeed');
  noUiSlider.create(slider1, {
    start: [3, 10],
    connect: true,
    step: 0.5,
    range: {
      'min': 0,
      'max': 40
    }
  });

  var sliderOpacity = document.getElementById('opacity');
  noUiSlider.create(sliderOpacity, {
    start: [0.5],
    connect: false,
    step: 0.1,
    range: {
      'min': 0,
      'max': 1
    }
  });

  var sliderRadius = document.getElementById('radius');
  noUiSlider.create(sliderRadius, {
    start: [5],
    connect: false,
    step: 1,
    range: {
      'min': 0,
      'max': 100
    }
  });

  var sliderBlur = document.getElementById('blur');
  noUiSlider.create(sliderBlur, {
    start: [10],
    connect: false,
    step: 1,
    range: {
      'min': 0,
      'max': 50
    }
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

}

// Materialize.toast(message, displayLength, className, completeCallback);
function toast() {
  return Materialize.toast('10.000 puntos ploteados!', 4000, 'rounded'); // 4000 is the duration of the toast
}
