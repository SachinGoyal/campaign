$(document).ready( function() {
  $(".accordion-section").find("p.select-roles").children("input").change(function () {
  var checked = $(this).is(":checked");
  if(checked){
   $(this).parent().parent().find("input").prop("checked", true);
  }
  else{
   $(this).parent().parent().find("input").prop("checked", false);

  }
  
  
        
  
 });
});
