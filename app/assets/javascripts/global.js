var ready = function() {
  $('.ui.dropdown').dropdown();
  $('.ui.checkbox').checkbox();
};

$(document).on('ready turbolinks:load', ready)
