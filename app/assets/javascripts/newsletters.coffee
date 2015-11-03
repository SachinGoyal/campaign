# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('form').on 'click', '.contact_search_for_newsletter', (event) ->
  	city = $('#q_city_cont').val()
  	country = $('#q_country_eq').val()

  	$.get '/contacts/search', (data) ->
  		$('body').append "Successfully got the page."
  	event.preventDefault()

