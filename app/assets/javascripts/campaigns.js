$( document ).ready(function() {  
	$('#report_campaign_id').on('change', function() {      
		  $.ajax({
		    url: '/campaigns/select_newsletter',
		    data: "campaign_id="+$('#report_campaign_id').val() 
		  })
	});
});
