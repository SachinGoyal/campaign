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
  # $('#extra_fields_display').load("/profiles/" + $("#template_profile_id option:selected").val() + "/extra_fields")
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



