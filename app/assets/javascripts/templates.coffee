sendFile = (file) ->
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
  $(".summernote").summernote
    height: 360
    codemirror:
      lineNumbers: true
      tabSize: 2
      theme: "solarized light"
    onImageUpload: (files) ->
      sendFile files[0]