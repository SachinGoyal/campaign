# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#q_gender_true_1').change ->
  	$('#q_gender_false_1').prop('checked', false)
  $('#q_gender_false_1').change ->
  	$('#q_gender_true_1').prop('checked', false)

  $('form').on 'click', '.auto_response_toggle', (event) ->
    $('#newsletter_auto_response').toggle()
  $('form').on 'click', '.send_at_toggle', (event) ->
    $('#newsletter_send_at').toggle()
      
  $('form').on 'click', '.contact_search_for_newsletter', (event) ->
    search_params = {q:{}}
    search_params['q']['auth_object'] = 'newsletter'
    search_params['q']['city_cont'] = $('#q_city_cont').val()
    search_params['q']['country_eq'] = $('#q_country_eq').val()
    a = []
    $("input[name='q[matches_all_attributes][]']:checked").each (index) ->
      if @checked
        a[index] = $(this).val()

    search_params['q']['matches_all_attributes'] = a
    if $('#q_gender_true_1').is(':checked')
  	  search_params['q']['gender_true'] = 1
    if $('#q_gender_false_1').is(':checked') 
  	  search_params['q']['gender_false'] = 1

    $.ajax
      type: 'GET'
      url: '/contacts.js'
      data: search_params
	
    event.preventDefault()

  $('.newsletter_form').submit (e) ->
    #e.preventDefault()
  $('.datepicker').datepicker()