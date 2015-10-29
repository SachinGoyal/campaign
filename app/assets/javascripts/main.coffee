jQuery ->
  $(document).on 'click', '.anchor-block', (e)->
    f_index = $('.anchor-block').index(this)
    f_row_inline = $(".selected-row-inline").eq(f_index)
    $('.custom-table').find(":checkbox").prop("checked", false)
    $(".selected-row-bottom").hide()
    if((f_row_inline).is(':visible'))
      $(f_row_inline).slideUp(300)
    else
      $(".selected-row-inline").slideUp(300)
      $(f_row_inline).slideDown(300)
    e.stopPropagation()

  $(document).on 'click', ".check input:checkbox", (e) ->
    length    = $('.check input:checkbox').length
    unchecked = $('.check input:checkbox').not(":checked").length
    if(unchecked == 0)
      $(".selected-row-bottom").show()
      $(".selected-row-inline").hide()
      $("#select-all").prop('checked',true)
    else if (unchecked > 0 && unchecked < length)
      $(".selected-row-bottom").show()
      $(".selected-row-inline").hide()
      $("#select-all").prop('checked',false)
    else
      $(".selected-row-bottom").hide()
      $("#select-all").prop('checked',false)

  $('#select-all').on 'change', ->
    if $(this).is(":checked") && $('.check').find(":checkbox").length > 0
      $('.check').find(":checkbox").prop("checked", true)
      $(".selected-row-bottom").show()
      $(".selected-row-inline").hide()
    else
      $('.check').find(":checkbox").prop("checked", false)
      $(".selected-row-bottom").hide()


