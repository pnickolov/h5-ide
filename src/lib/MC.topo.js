// MC.topo
// Author: Angel
MC.topo = function (data, hasELB)
{
	var init_coordinate = function (data, parent, index, offsetX, hasELB)
	{
		var originalY = 1;

		data['coordinate'] = [offsetX, originalY];
		data['index'] = index;
		data['parent'] = parent;

		if (parent == null && data['name'] == undefined && hasELB)
		{
			offsetX = -2;
		}

		if (data['children'] != undefined)
		{
			$.each(data['children'], function (i, children)
			{
				init_coordinate(children, data, i, offsetX + 2, false);
			});
		}
	},

	parentMove = function (node, offset)
	{
		if (node.parent != null)
		{
			node.parent['coordinate'][1] += offset;

			if (node.parent.parent != null)
			{
				parentMove(node.parent, offset);
			}
		}
	},

	nodeSize = function (node)
	{
		var max = node['coordinate'][1];

		if (node.children != null)
		{
			max += node.children.length - 1;
			$.each(node.children, function (i, node)
			{
				var rang = nodeSize(node);
				if (rang >= max)
				{
					max = rang;
				}
			});
		}

		return max;
	},

	apportion = function (data)
	{
		if (data['parent'] != null && data['parent']['children'] != null && data['parent']['children'][data['index'] - 1] != null)
		{
			var previousNode = data['parent']['children'][data['index'] - 1];

			if (previousNode.children != null)
			{
				data['coordinate'][1] = nodeSize(previousNode) + 1;
			}
			else
			{
				data['coordinate'][1] = previousNode['coordinate'][1] + 1;
			}
		}
		if (data['children'] != undefined)
		{
			$.each(data['children'], function (i, children)
			{
				var name = children['name'];
				children['coordinate'][1] = data['coordinate'][1] + i;
				apportion(children);
			});
		}
	},

	center_node = function (data)
	{
		if (data['children'] != undefined)
		{
			if (data['children'].length > 1)
			{
				data['coordinate'][1] = Math.round((data['children'][0]['coordinate'][1] + data['children'][data['children'].length - 1]['coordinate'][1]) / 2);
			}
			$.each(data['children'], function (i, children)
			{
				center_node(children);
			});
		}
	},

	render = function (data)
	{
		if (data['children'] != undefined)
		{
			$.each(data['children'], function (i, children)
			{
				render(children);
			});
		}
		if (data['name'] != undefined)
		{
			layout[data['name']]['coordinate'] = data['coordinate'];
		}
	};

	init_coordinate(data, null, 0, 0, hasELB);
	apportion(data);
	center_node(data);
	render(data);

	return data;
};