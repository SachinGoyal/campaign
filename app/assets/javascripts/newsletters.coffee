# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#q_gender_true_1').change ->
  	$('#q_gender_false_1').prop('checked', false)
  $('#q_gender_false_1').change ->
  	$('#q_gender_true_1').prop('checked', false)

  $('form').on 'click', '.contact_search_for_newsletter', (event) ->
  	search_params = {q:{}}
  	search_params['q']['auth_object'] = true
  	search_params['q']['city_cont'] = $('#q_city_cont').val()  	
  	search_params['q']['country_eq'] = $('#q_country_eq').val()  	 
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
    arr = $.unique($('.contact_emails').val().replace(/ /g,'').split(','))
    $('.contact_emails').val arr.join(',')
  $('.datepicker').datepicker
    format: "dd/mm/yyyy"
    startDate: "today"
    endDate: "31-12-2016"
    todayHighlight: true 
    todayBtn: "linked"
    autoclose: true
    useStrict: true