# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  datepicker_update = -> $('.datepicker').datepicker({startDate: "01-01-1950", endDate: "today", todayHighlight: true, todayBtn: "linked", autoclose: true})

  options = 
    string: "<option value='eq'>equals</option><option value='not_eq'>not equal to</option><option value='cont' selected='selected'>contains</option><option value='not_cont'>doesn't contain</option><option value='start'>starts with</option><option value='not_start'>doesn't start with</option>"
   
    datetime: "<option value='eq'>equals</option><option value='not_eq'>not equal to</option><option value='lt'>less than</option><option value='lteq'>less than or equal to</option>><option value='gt'>greater than</option><option value='gteq'>greater than or equal to</option>"

    in: "<option value='in'>in</option><option value='eq_any'>equals any</option>"
    integer: "<option value='in'>in</option><option value='eq'>in</option>"

  $(document).on 'change', '.field_values', ->
    if($(this).val() == "created_at")
      datepicker_update()          
    else
      $('.datepicker').datepicker('remove')
    if($(this).val() == "interest_area_ids")
      row = $(this).parent().parent().find('.ajax_result')
      $.get "/attributes.js", (data) -> 
        console.log(data)

    $(this).find(':selected').data('id')  

  $('form').on 'click', '.remove_fields', (event) ->
    $(this).closest('.field').remove()
    event.preventDefault()
  
  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $('.add_link').before($(this).data('fields').replace(regexp, time))
    $( ".add_fields_fieldset" ).trigger( "click" );
    event.preventDefault()

  $('form').on 'click', '.add_fields_fieldset', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).parent().before($(this).data('fields').replace(regexp, time))
    event.preventDefault()