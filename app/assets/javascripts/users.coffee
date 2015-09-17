# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



jQuery ->
  datepicker_update = -> $("input.datepicker").datepicker()
  options = 
    string: "<option value='eq'>equals</option><option value='not_eq'>not equal to</option><option value='cont' selected='selected'>contains</option><option value='not_cont'>doesn't contain</option><option value='start'>starts with</option><option value='not_start'>doesn't start with</option>"
   
    datetime: "<option value='eq'>equals</option><option value='not_eq'>not equal to</option><option value='lt'>less than</option><option value='lteq'>less than or equal to</option>"

  $(document).on 'change', '.field_values', ->
    if($(this).val() == "created_at")
      $('.datepicker').datepicker({startDate: "01-01-1950", endDate: "today", todayHighlight: true, todayBtn: "linked", autoclose: true})      
    else
      $('.datepicker').datepicker('remove')
    
  $('form').on 'click', '.remove_fields', (event) ->
    $(this).closest('.field').remove()
    event.preventDefault()
  
  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()