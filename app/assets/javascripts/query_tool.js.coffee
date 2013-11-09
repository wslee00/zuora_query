# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('.loading-indicator').hide()

  $('#connector_id').change (event) ->
    $("#chosen_connector").text($(this).val())
    window.location.href = "?connector_id=" + $(this).val()

  $('#query_editor').keydown (event) -> 
    if ((event.which == 115 && event.ctrlKey) || (event.which == 13 && event.metaKey)) 
      $('.loading-indicator').show()
      $('#selected_query').val($('#query_editor').getSelectedText())
      $('#results').prepend('Getting results...')      
      $(this).parent('form').submit()
      event.preventDefault()

  $(document).ajaxStop ->
    $('.loading-indicator').hide()