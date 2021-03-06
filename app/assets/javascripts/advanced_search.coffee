class  SearchbyDateType
  constructor: (@attributes, @name_select_value = null, @attribute_select_val = null, @predicate_select = null, @row = null, @no_load = null) ->
    $('form').on 'change','.search_attribute .select_attributes', (event, no_load = true) =>      
      @no_load = no_load
      @row = $(event.currentTarget).closest('.field')
      @name_select_value = $(event.currentTarget).prop('name').replace('name','value').replace('[a]','[v]')
      @attribute_select_val = $(event.currentTarget).val()
      @predicate_select = @row.find('.predicate_select')
      @predicateSelectDisabled()

  Load: ->
    $('form').find('.search_attribute .select_attributes').each (i) ->
      $(@).trigger('change', [false])

  predicateSelectDisabled: ->
    all_data_types = ['eq', 'not_eq', 'not_in', 'null', 'not_null']
    strings = ['cont', 'not_cont', 'start', 'not_start', 'end', 'not_end']
    numbers = ['gt', 'gteq', 'lt', 'lteq']
    dates = ['date_gt', 'date_gteq', 'date_lt', 'date_lteq', 'date_eq', 'date_not_eq']
    booleans_association = ['eq']
    not_booleans = ['present', 'blank']
    attr = @attributes[@attribute_select_val]
    switch attr.type
      when 'boolean'
        @renderDropDownBoolean(@name_select_value)
        @selectPredicateDisabled(booleans_association)
      when 'string', 'text'
        if attr.association
          @renderDropDownAssociation(attr.association, @name_select_value)
          @selectPredicateDisabled(booleans_association)
        else
          @render_input_search({'placeholder': 'Enter value', "required", "true", 'type': "text", 'class': 'value_search form-control'})
          @selectPredicateDisabled(strings.concat(all_data_types))
      when 'integer', 'decimal'
        if attr.association
          @renderDropDownAssociation(attr.association, @name_select_value)
          @selectPredicateDisabled(booleans_association)
        else
          @render_input_search({'placeholder': 'Enter numeric value', "required", "true", 'type': "number"})
          @selectPredicateDisabled(numbers.concat(all_data_types))
      when 'datetime', 'date'
        @render_input_search({'placeholder': 'Enter Date', "required", "true", 'type': "text", 'class': 'datepicker form-control'})
        @selectPredicateDisabled(dates)
      when 'custom'
        @renderDropDown(attr.values, null, @row, @name_select_value)
        @selectPredicateDisabled(booleans_association)
      else 'No tiene tipo'

  selectPredicateDisabled: (attributes_enabled, selected = null) ->
    @predicate_select.html("<option value='eq'>Equal</option><option value='not_eq'>Not equal to</option><option value='lt'>Less than</option><option value='lteq'>Less than</option><option value='gt'>Greater than</option><option value='gteq'>Greater than</option><option value='in'>In</option><option selected='selected' value='cont'>Contains</option><option value='not_cont'>Not contains</option><option value='start'>Starts with</option><option value='not_start'>Doesn't start with</option><option value='end'>Ends with</option><option value='not_end'>Doesn't end with</option><option value='date_eq'>Date Equal To</option><option value='date_not_eq'>Date not equal to</option><option value='date_lt'>Date less than</option><option value='date_lteq'>Date greater than equal to</option><option value='date_gt'>Date greater than</option><option value='date_gteq'>Date greater than equal to</option>")
    if @no_load
      if selected then @predicate_select.val(selected) else @predicate_select.val(attributes_enabled[0])

    @predicate_select.find('option').each (i) ->
      this.remove() unless this.value in attributes_enabled
      return true

  renderDropDownBoolean: (name_select_value) ->
    row_current = @row
    elem = $('input[name='+ "'" + name_select_value + "'" +']')
    
    selected = row_current.find(".box_search").find('input').val()
    row_current.find(".box_search").hide()
    row_current.find(".box_select").empty()
    select_row = $("<select class='form-control'><option value=''>- Select - </option>")    
    select_row.prop({'name': name_select_value, 'id': elem.attr('id')})    
    select_row.append("<option value='true'> Enabled </option>")
    select_row.append("<option value='false'> Disabled </option>")
    select_row.val(selected)
    row_current.find(".box_select").append(select_row)
    row_current.find(".box_select").show()


  renderDropDownAssociation: (model, name_select_value) ->
    url = "/apis/index?model=#{model}"
    row_current = @row
    @AjaxOptions(url, model, row_current, name_select_value)

  render_input_search: (args = {})->
    @reset() if @no_load
    @row.find('.box_search').find('input').prop(args)
    if @row.find('.box_search').find('input').hasClass('datepicker')
      @row.find('.box_search').find('input.datepicker').datepicker
        format: "dd/mm/yyyy"
        startDate: "01-01-1950"
        endDate: "today"
        todayHighlight: true 
        todayBtn: "linked"
        autoclose: true
    else
      @row.find('.box_search').find('input').datepicker('remove')

  reset: ->
    @row.find('.box_select').empty()
    @row.find('.box_search').show()
    @row.find('.box_search').find('input').val('').removeAttr('required').removeAttr('type').removeClass('datepicker', 'hasDatepicker')

  renderDropDown: (data, model, row_current, name_select_value)->    
    selected = row_current.find(".box_search").find('input').val()
    row_current.find(".box_search").hide()
    row_current.find(".box_select").empty()
    select_row = $("<select class='form-control'><option value=''>- Select - </option>")
    name_select_value = name_select_value + "[]"
    select_row.prop({'name': name_select_value, 'id': name_select_value})
    #setter val for Project select like
    $.each data, (i, j) ->
      switch model
        when 'Project'
          select_row.append("<option value='#{j.name}'> #{j.name} </option>")
        when 'User'
          select_row.append("<option value='#{j.username}'> #{j.username} </option>")
        else
          select_row.append("<option value='#{j.id}'> #{j.name} </option>")
    select_row.val(selected)
    row_current.find(".box_select").append(select_row)

  AjaxOptions: (url, model, row_current, name_select_value) ->
    $.ajax
      url: url
      authenticity_token: window._token
      success: (data, status, xhr) =>        
        @renderDropDown(data, model, row_current, name_select_value)

window.search_init =
  selectSearch: (attributes) ->
    selectDynamic = new SearchbyDateType attributes
    selectDynamic.Load()