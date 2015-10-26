jQuery ->
  $(document).on 'click', '.anchor-block', (e)->
    f_index = $('.anchor-block').index(this)
    f_row_inline = $(".selected-row-inline").eq(f_index)
    $('.custom-table').find(":checkbox").prop("checked", false)
    $(".selected-row-bottom").hide()
    if((f_row_inline).is(':visible'))
      $(f_row_inline).slideUp(500)
    else
      $(".selected-row-inline").slideUp(500)
      $(f_row_inline).slideDown(500)
    e.stopPropagation()

  $(document).on 'click', ":checkbox", (e) ->
    if($('.td').find(':checkbox').is(':checked'))
      $(".selected-row-bottom").show()
      $(".selected-row-inline").hide()
    else
      $(".selected-row-bottom").hide()
    if $('.td').find("input:checkbox").not(":checked").length > 0
      $("#select-all").prop('checked',false)
    else
      $("#select-all").prop('checked',true)

  $('#select-all').on 'change', ->
    if $(this).is(":checked") && $('.check').find(":checkbox").length > 0
      $('.check').find(":checkbox").prop("checked", true)
      $(".selected-row-bottom").show()
      $(".selected-row-inline").hide()
    else
      $('.check').find(":checkbox").prop("checked", false)
      $(".selected-row-bottom").hide()


