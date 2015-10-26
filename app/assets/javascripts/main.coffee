jQuery ->
  $(document).on 'click', '.anchor-block', (e)->
    $('.custom-table').find(":checkbox").prop("checked", false)
    $(".selected-row-bottom").hide()
    $(".selected-row-inline").hide()
    $(this).parent().parent().next().slideToggle()
    e.stopPropagation()

  $(document).on 'click', ":checkbox", (e) ->
    if($('.td').find(':checkbox').is(':checked'))
      $(".selected-row-bottom").show()
      $(".selected-row-inline").hide()
    else
      $(".selected-row-bottom").hide()
    if $('.td').find("input:checkbox").not(":checked").length > 0
      $("#select-all input").prop('checked',false)
    else
      $("#select-all input").prop('checked',true)

  $('#select-all').on 'change', ->
    if $(this).is(":checked") && $('.check').find(":checkbox").length > 0
      $('.check').find(":checkbox").prop("checked", true)
      $(".selected-row-bottom").show()
      $(".selected-row-inline").hide()
    else
      $('.check').find(":checkbox").prop("checked", false)
      $(".selected-row-bottom").hide()


