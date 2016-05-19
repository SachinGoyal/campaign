sendFile = (file, callback) ->
  data = new FormData
  data.append 'template_image[image]', file
  $.ajax
    data: data
    type: 'POST'
    url: '/uploads/create'
    cache: false
    contentType: false
    processData: false
    success: (data) ->
      $(".summernote").summernote "insertImage", data.url
$ ->
  profile_selected = $("#template_profile_id option:selected").val()
  if profile_selected
    $('#extra_fields_display').load("/profiles/#{profile_selected}/extra_fields").show()

  $(".summernote").summernote
    height: 360
    codemirror:
      lineNumbers: true
      tabSize: 2
      theme: "solarized light"
    onImageUpload: (files, editor, welEditable) ->
      sendFile files[0]

  $('#template_profile_id').change ->
    $('#extra_fields_display').load("/profiles/" + $(this).val() + "/extra_fields").show()



