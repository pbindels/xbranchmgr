$(document).ready(function() { 	
    hosts= $('#dep_host_name').html();

    $('.branch_text_box').hide();
    $('.select_project').show();
    $('.select_branch').hide();

    $('.enter_branch').on('change', function() {
        $('.branch_text_box').toggle();
        $('.select_project').toggle();
    })

    $('.select_project').on('change', function() {
        console.log("here11")
        $('.select_branch').show();
    })

	$("#task_name").bind("change", function() {
	  // $("form").trigger("submit");
	  $('#task_spinner').show();
	  $("form:first").trigger("submit");
	});

	$('#dep_host_name').hide();
	//$('#dep_env_name').bind("change", function() {
	$('#dep_env_name').on("change", function() {
	  var env = $('.field99 :selected').text();
	  console.log(env)
	  console.log(hosts)
	  str = "optgroup[label=" + env + "]"
      options =  $(hosts).filter(str).html();
      options2 = "<option>Select a Host</option>" + options

	  if (options) {
       $('#dep_host_name').html(options2);
	   $('#dep_host_name').show();
      }
 	  else {
		$('#dep_host_name').html(options);
		$('#dep_host_name').show();
      }
	});
	
	$('#repo_name').hide();
	$('.field2 label').hide();
	$('.field5').hide();
	$('.field99').hide();

//	$("#submitButtonId5").attr('disabled', 'true');

    $("#spinner").hide();
    $("#spinner1").hide();

    $("#task_spinner").hide();

    repos = $('#repo_name').html()
    proj_envs = $('#dep_host_name').html()

    $("#submitButtonId3").hide();
	$("#submitButtonId3").attr('disabled', 'true');
	$("#submitButtonId1").attr('disabled', 'true');
	$("#submitButtonId1").hide();

    $('.field_enter_branch').hide();
    $('.field_select_proj').on('change', function() {
        $('.field_enter_branch').show();
        $('.field_enter_branch').focus();
    })

	$('.field44').on('change', function(){
      console.log("here");
      $("#submitButtonId3").removeAttr('disabled');
	  $("#submitButtonId3").show();
    });

  //  $('.field0').on('change', function() {
//	  $("#submitButtonId5").removeAttr('disabled');
  //  });

    $('.checkbox5').on('change', function() {
      $('.field5').toggle();
    })

    $('.checkbox6').on('change', function() {
      $('.field99').toggle();
	  $('div.linkto-container').show();
	  $('div.linkto-container2').show();
    })

    $("#submitButtonId4").click(function() {
	  $('#spinner2').show()
    });

    $("#submitButtonId5").click(function() {
	  $('#spinner').show()
    });

    $("#submitButtonId1").click(function() {
	  console.log("here")
	  $('#spinner1').show()
    });

    $('#mybutton1').on('click', function() {
	  $('#spinner1').show
    });

    $("#submitButtonId2").click(function() {
	  //$( "#progressbar").progressbar({value: false});
      $("#project_name" )
	  $('#spinner').show()
	  $('.field').hide()
    });

    $('#repo_name').on('change', function() {
      console.log("here88")
	  $("#submitButtonId1").show();
	  $("#submitButtonId1").removeAttr('disabled');
    });

    $("#submitButtonId2").click(function() {
	  $('#spinner').show()
    });

    $('.mybutton3').click(function() {
	  $('#spinner').show()
    });


    $('.field66').on('change', function() {
        var proj = $('.field66 :selected').text();
        str = "optgroup[label=" + proj + "]"
        options_envs = $(proj_envs).filter(str).html();
        options_envs2 = "<option>Select a Reservation (environment - service - owner)</option>" + options_envs
        var label = $('#dep_host_name :selected').attr('label');
        if (options_envs2) {
            $('#dep_host_name').show();
            $('.field99 label').show();
            $('#dep_host_name').html(options_envs2);
        }
    });

    $('.field1').on('change', function() {
	  $("#submitButtonId3").removeAttr('disabled');
	  var proj = $('.field1 :selected').text();
	  str = "optgroup[label=" + proj + "]"
      options =  $(repos).filter(str).html();
      options2 = "<option>Select A Repository</option>" + options
      var label =  $('#repo_name :selected').attr('label');

	  if (options2) {
	    $('#repo_name').show(); 
		$('.field2 label').show();
    	$('#repo_name').html(options2);
      }
 	  else {
	    $('#repo_name').html(options2);
      }
    });

    $('.mybutton2').hide();
    $('.field676').hide();
    $('.field677').hide();

    $('div.linkto-container').hide();

    $('.field66').on('change', function() {
	  selector =$("#branch_project_name").val();

      var p = $('.field66 :selected').html();

      var str1=	"<a href=\"#\" onclick=\"javascript:window.open(&#x27;https://deploy.newokl.com/php/deployment.php?action=status&amp;service="
      var str2= "&amp;domain="
	  var str3= "&#x27;,&#x27;popup&#x27;,&#x27;scrollbars=1,width=600,height=600&#x27;);\"><b><font color=DF0101><ul>Check Current Deployments For Project \"" + p + "\"</ul></font></b></a>"
      var str4= "<ul>"  + str1 + selector + str2 + selector + str3 + "</ul>"
	
	  $('div.linkto-container').html(str4);

	  $('.field676').show();
	  $('.field677').show();
    })

    $('.field676').on('change', function() {
	  $('.mybutton2').show();
    })


    $('div.linkto-container2').hide();

    $('.field66').on('change', function() {
        selector =$("#branch_project_name").val();

        var str1= "<a href=\"#\" onclick=\"javascript:window.open(&#x27;http://localhost:3000/deploy_envs"
        var str2= "&amp;domain="
        var str3= "&#x27;,&#x27;popup&#x27;,&#x27;scrollbars=1,width=900,height=600&#x27;);\"><b><font color=DF0101><ul>See All Deployment Reservations</ul></font></b></a>"
        var str4= "<ul>" + str1 + str3 + "</ul>"

        $('div.linkto-container2').html(str4);
    })


});




