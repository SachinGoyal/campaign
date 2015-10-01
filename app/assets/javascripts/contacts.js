$(document).ready( function() {
	$("#select-all").change(function () {
		var checked = $("#select-all").find(":checkbox").is(":checked")
		if(checked){
			$('.custom-table').find(":checkbox").prop("checked", true);
		}

		else{
			$('.custom-table').find(":checkbox").prop("checked", false); 
		}
	});

	$(":checkbox").on('click',function (e) {
		if ($('input[type=checkbox]').is(':checked')){
			$(".selected-row-bottom").show();
			$(".selected-row-inline").hide();
		}
		else{
			$(".selected-row-bottom").hide();
		}
	});


	$('.anchor-block').click(function(e){ 
		$('.custom-table').find(":checkbox").prop("checked", false); 
		$(".selected-row-bottom").hide();
		$(".selected-row-inline").hide();
		$(this).parent().parent().next().slideToggle();
		e.stopPropagation();
	});

	$('.profile-enable').click(function(e){ 
	    var a = [];
	    $('input[type=checkbox]').each(function (index) {
	       if (this.checked) {
	           a[index] = $(this).val()
	       }
	        console.log(a); 
		    $.ajax({
			  method: "GET",
			  url: "some.php",
			  data: { name: "John", location: "Boston" }
			})
		    .done(function( msg ) {
		        alert( "Data Saved: " + msg );
		    });
	    });

	});


	function myFunction(){
       console.log("hello");

	}
	myFunction();



});
