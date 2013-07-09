var ready = function () {

	//Property Panel
	$('#property-instance-keypairs').on('EDIT_EMPTY', function(event, id){ notification('error', 'KeyPair Empty', false); });

	//Property Panel
	/*
	$('.secondary-panel').on('click', '.back', function (event)
	{
		$(this).parent().parent().fadeOut(200);
		return false;
	});
	*/
	
	$('#property-panel').on('click', '.ami-wrap', function (event)
	{
		$('#aim-secondary-panel').fadeIn(200);
	});
	$('#property-panel').on('click', '#security-group-select', function(event)
		{
			fixedaccordion.show.call($($(this).parent().find('.fixedaccordion-head')[0]));
		});
	$('#show-newsg-panel').on('click', function(event)
	{
		$('#sg-secondary-panel').fadeIn(200);
		$('#sg-secondary-panel .sg-title input').focus();
	});
	$('#show-newsg-panel').on('click', function(event)
	{
		$('#sg-secondary-panel').fadeIn(200);
		$('#sg-secondary-panel .sg-title input').focus();
	});
	$('#security-group-select').on('OPTION_CHANGE', function(event, id)
	{
		if(id.length != 0) {
			$('#sg-info-list').append(MC.template.sgListItem({name: id}));
		}
	});
	/*
	$('#sg-info-list').on('click', 'li', function (event)
	{
		$('#sg-secondary-panel').fadeIn(200);
		$('#sg-secondary-panel .sg-title input').focus();
	});
	*/
	$('#sg-info-list').on('click', '.sg-remove-item-icon', function (event)
	{
		event.stopPropagation();
		$(this).parent().remove();
		notification('info', 'SG is deleted', false);
	});
	$('#property-network-list').on('click', '.network-remove-icon', function (event)
	{
		event.stopPropagation();
		$(this).parent().remove();
	});
	$('#sg-ip-add').on('click', function (event)
	{
		$('#property-network-list').append(MC.template.networkListItem());
		return false;
	});
	$('#sg-rule-list').on('click', '.rule-remove-icon', function (event)
	{
		$(this).parent().remove();
	});
	$('#sg-rule-list').on('click', '.rule-edit-icon', function (event)
	{
		modal(MC.template.modalSGRule({isAdd:false}), true);
	});
	$('#sg-add-rule-icon').on('click', function (event)
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