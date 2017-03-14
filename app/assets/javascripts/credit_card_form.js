/* global $ */


// function to get params from URL
function GetURLParameter(sParam) {
    var sPageURL = window.location.search.substring(1); //returns url string, ?plan=premium
    var sURLVariables = sPageURL.split('&'); //split it up on the &

    for (var i = 0; i < sURLVariables.length; i++) { //iterate through the & splits to hunt for =
        var sParameterName = sURLVariables[i].split('='); //aray of two elements

        if (sParameterName[0] === sParam) { //congrats, you found the sParam, 'plan'
            return sParameterName[1] === undefined ? true : sParameterName[1]; //should be 'free' or 'premium'
        }
    }
};



$(document).ready(function(){
    //served as a tree DOM, this DOC ready func ensures whole page loads, prevents conflicts
    //JS waits until total load
    
    var show_error, stripeResponseHandler, submitHandler;



// function to handle the submit of the form and intercept the default event
    submitHandler = function(event){
        var $form = $(event.target);
      
        //need to fine the submit button to disable multiple clicks
        $form.find("input[type=submit]").prop("disabled", true);
                //prop sets value of the element, disabled after first submit
                
        if(Stripe){
            Stripe.card.createToken($form, stripeResponseHandler);
        } else {
            //it wasn't valid
            show_error("Failed to load credit card processing. Please reload page.");
        }
        
        //prevent default rails/html action
        return false;
        
    };

//init a submit handler listener for nay forms which have class: cc_form
    $(".cc_form").on('submit', submitHandler);

//set up plan change event listen @tenant_plan id in the forms for class cc_form
    var handlePlanChange = function(plan_type, form) {
        var $form = $(form);
        
        if (plan_type == undefined) {
            plan_type = $('#tenant_plan :selected').val();
        }
        
        if (plan_type === 'premium') {
            $('[data-stripe]').prop('required', true); //make stripe data required
            $form.off('submit'); //turn off event handler
            $form.on('submit', submitHandler); //use the submit handler cause premium
            $('[data-stripe]').show();
            
        } else {
            $('[data-stripe]').hide(); //hide the stripe data
            $form.off('submit'); 
            $('[data-stripe]').removeProp('required');
        }
    };


// set up plna change event listener #tenant_plan id in the forms for class cc_form
    $("#tenant_plan").on('change', function(event) {
        handlePlanChange($('#tenant_plan :selected').val(), ".cc_form");    
    });


//call plan changehandler so that plan is correcntly in drop down when loads
    handlePlanChange(GetURLParameter('plan'), ".cc_form");


//function to handle the token
    stripeResponseHandler = function (status, response) {
        var token, $form;
        
        $form = $('.cc_form'); //the class for the form from the erb file
        
        if (response.error) {
            console.log(response.error.message);
            show_error(response.error.message);
            $form.find("inputs[type=submit]").prop("disabled", false); //result of error
        } else { //no errors
            token = response.id; //response is from strip server
            $form.append($("<input type=\"hidden\" name=\"payment[token]\" />").val(token));
            //from stripe
            
            //standard stripping code from stripe
            $("[data-stripe=number]").remove();
            $("[data-stripe=cvv]").remove();
            $("[data-stripe=exp-year]").remove();
            $("[data-stripe=exp-month]").remove();
            $("[data-stripe=label]").remove();
            
            //send in the form after stripping
            $form.get(0).submit();
        }
        return false; //stops default event from happening
        
    };


//function to show errors when stripe functionality returns an error
    show_error = function (message) {
        if($("#flash-messages").size() < 1){
            $('div.container.main div:first').prepend("<div id='flash-messages'></div>");
        }
        $("#flash-messages").html('<div class="alert alert-warning"><a class="close" data-dismiss="alert">×</a><div id="flash_alert">' + message + '</div></div>');
        $('.alert').delay(5000).fadeOut(3000);
        return false;
    };


});