# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->

  $('form').on 'click', '.auto_response_toggle', (event) ->
    $('#newsletter_auto_response').toggle()
  $('form').on 'click', '.scheduled_at_toggle', (event) ->
    $('#newsletter_scheduled_at').toggle()
      
  $('form').on 'click', '.contact_search_for_newsletter', (event) ->
    search_params = {q:{}}
    search_params['q']['auth_object'] = 'newsletter'
    search_params['q']['email_cont'] = $('#q_email_cont').val()

    $.ajax
      type: 'GET'
      url: '/contacts.js'
      data: search_params
	
    event.preventDefault()

  $('.datetimepicker').datetimepicker({
    minDate: 0,
    step: 30
  })
