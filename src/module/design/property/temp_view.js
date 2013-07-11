var ready = function () {
	$('#sg-rule-list').delegate('.rule-remove-icon', 'click',  function (event)
	{
		$(this).parent().remove();
	});
	$('#sg-rule-list').delegate('.rule-edit-icon', 'click', function (event)
	{
		modal(MC.template.modalSGRule({isAdd:false}), true);
	});
	$('.sg-context-wrap').delegate('#sg-context-wrap', 'click', function (event)
	{
		modal(MC.template.modalSGRule({isAdd:true}), true);
	});
	$(document.body).on('change', '#radio_inbound', function (event)
	{
		$('#rule-modle-title2').text("Source");
	});
	$(document.body).on('change', '#radio_outbound', function (event)
	{
		$('#rule-modle-title2').text("Destination");
	});
	$(document.body).on('OPTION_CHANGE', '#modal-sg-rule', function(event, id)
	{
		$('#sg-protocol-select-result').find('.show').removeClass('show');
		$('#sg-protocol-' + id).addClass('show');
	});
	$('#sg-info-list').on('click', '.sg-toggle-show-icon', function (event)
	{
		event.stopPropagation();
		toggleicon.click.call($(this));
	});

}

define( [], function() {

	return {
		ready : ready
	}

});