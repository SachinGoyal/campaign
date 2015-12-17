$( document ).ready(function() {  
	$('#campaign_id').on('change', function() {      
		  $.ajax({
		    url: '/campaigns/select_newsletter',
		    data: "campaign_id="+$('#campaign_id').val() 
		  })
	});
});
