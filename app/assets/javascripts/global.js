var ready = function() {
  $('.ui.dropdown').dropdown();
  $('.ui.checkbox').checkbox();
  $('.ui.progress').progress();
};

$(document).on('ready turbolinks:load', ready)
