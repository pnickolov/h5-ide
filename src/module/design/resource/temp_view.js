var ready = function () {

	//Browse Community AMI, show modal
	//$('#btn-browse-community-ami').on('click', function (event)
	//{
		modal(MC.template.browseCommunityAmi(''), false);
		$($('#selectbox-ami-platform').find('.cur-value')[0]).html($($('#selectbox-ami-platform').find('.selected')[0]).html());
		$('#community-ami-input').on('keyup', function(event)
			{
				filter.update($('#community-ami-filter'), {
					value: $(this).val(),
					type:{
						publicprivate: radiobuttons.data($('#filter-ami-public-private')),
						ebs: radiobuttons.data($('#filter-ami-EBS-Instance')),
						bit: radiobuttons.data($('#filter-ami-32bit-64bit')),
						platform: $($('#selectbox-ami-platform').find('.selected a')[0]).data('id')
					}
				});
			});
		$('#filter-ami-public-private').on('RADIOBTNS_CLICK', function(event, cur_radion)
			{
				var result_set = {
					value:$('#community-ami-input').val(),
					type:{
						publicprivate:cur_radion,
						ebs: radiobuttons.data($('#filter-ami-EBS-Instance')),
						bit: radiobuttons.data($('#filter-ami-32bit-64bit')),
						platform: $($('#selectbox-ami-platform').find('.selected a')[0]).data('id')
				} };

				filter.update($('#community-ami-filter'), result_set);
			});
		$('#filter-ami-EBS-Instance').on('RADIOBTNS_CLICK', function(event, cur_radion)
			{
				var result_set = {
					value:$('#community-ami-input').val(),
					type:{
						publicprivate: radiobuttons.data($('#filter-ami-public-private')),
						ebs: cur_radion,
						bit: radiobuttons.data($('#filter-ami-32bit-64bit')),
						platform: $($('#selectbox-ami-platform').find('.selected a')[0]).data('id')
				} };

				filter.update($('#community-ami-filter'), result_set);
			});
		$('#filter-ami-32bit-64bit').on('RADIOBTNS_CLICK', function(event, cur_radion)
			{
				var result_set = {
					value:$('#community-ami-input').val(),
					type:{
						publicprivate: radiobuttons.data($('#filter-ami-public-private')),
						ebs: radiobuttons.data($('#filter-ami-EBS-Instance')),
						bit: cur_radion,
						platform: $($('#selectbox-ami-platform').find('.selected a')[0]).data('id')
				} };
				filter.update($('#community-ami-filter'), result_set);
			});
		$('#selectbox-ami-platform').on('OPTION_CHANGE', function(event, id){
			var result_set = {
				value:$('#community-ami-input').val(),
				type:{
					publicprivate: radiobuttons.data($('#filter-ami-public-private')),
					ebs: radiobuttons.data($('#filter-ami-EBS-Instance')),
					bit: radiobuttons.data($('#filter-ami-32bit-64bit')),
					platform: id
				} };

			filter.update($('#community-ami-filter'), result_set);
		})
	//});

}

define( [], function() {

	return {
		ready : ready
	}

});