/**
 * @fileoverview 点击链接时以AJAX方式载入内容到指定DOM
 *   并且阻止快速的单击一个链接
 * 
 * @author qijun.weiqj
 */
(function($, WP) {


var Util = WP.Util;


/**
 * 点击链接, 以ajax方式载入内容
 * @param links
 * @param {object} options, 同jQuery.ajax(options)参数, 并附加以下参数
 *  - update {selector|dom}  DOM节点, 载入的内容会在此DOM节点处渲染
 *  - confirm {function} 
 *  - before {function}
 */
var AjaxLink = function(links, options) {
	links = $(links);
	options = options || {};

	links.data('ajaxLinkOptions', options);	

	links.click(function(e) {
		e.preventDefault();

		var link = $(this);
		if (link.data('ajaxLinkRunning')) {
			return 	
		}
		if (options.confirm && options.confirm.call(this)) {
			AjaxLink.load(this);
		}
	});
};
	

AjaxLink.load = function(link, params) {
	link = $(link);
	var options = link.data('ajaxLinkOptions');
	if (!options) {
		throw 'ajaxOptions not exists';
	}

	var url = link.data(options.urlField || 'linkUrl'),
		opts = prepareOptions(link, options);

	url = params ? Util.formatUrl(url, params) : url;

	link.data('ajaxLinkRunning', true);
	options.before && options.before.apply(link[0]);
	$.ajax(url, opts);
};

function prepareOptions(link, options) {
	var opts = $.extend({}, options),
		success = options.success,
		complete = options.complete;
	
	if (opts.update) {
		opts.success = function(data) {
			$(options.update).html(data);
			success && success.apply(link[0], arguments);
		};
		delete opts.update;
	}

	opts.complete = function() {
		link.removeData('ajaxLinkRunning');
		complete && complete.apply(link[0], arguments);	
	};

	delete opts.confirm;
	delete opts.before;
	return opts;
}


WP.widget.AjaxLink = AjaxLink;
$.add('wp-ajaxlink');
	
})(jQuery, Platform.winport);

