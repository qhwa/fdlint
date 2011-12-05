/**
 * @fileoverview 旺铺tips
 * 
 * @author qijun.weiqj
 */
(function($, WP){

var Util = WP.Util;

/**
 * @param {element|string} parent   tips所属节点, tips将创建在该节点内部最前面
 *                                  创建的tips长和宽都为0, 所以不会影响布局
 * @param {string} html             tips内容
 * @param {object} options          配置项
 *      -attr
 */
var FloatTips = Util.mkclass({
	
	init: function(parent, html, options) {
		options = options || {};
		
		html = $.util.substitute(this.template, { 
			html: html, 
			arrow: options.arrow || 'no-arrow' 
		});
		
		var tips = $(html).prependTo(parent);
		options.className && tips.addClass(options.className);
		$('a.close', tips).click(function() {
			tips.remove();
			return false;
		});
		
		if ($.util.ua.ie6) {
			var box = $('div.tips-wrap', tips),
				bk = $('div.tips-bk', tips);
			bk.css('height', box.height());
		}

		this.node = tips;
	},
	
	template: 
		'<div class="float-tips">\
			<div class="tips-wrap">\
				<div class="tips-bk"></div>\
				<div class="tips-body">\
					<div class="icon"></div>\
					<div class="tips-text">{html}</div>\
					<a href="#" class="close"></a>\
				</div>\
				<div class="{arrow}"></div>\
			</div>\
		</div>'
		

});
//~ FloatTips

WP.widget.FloatTips = FloatTips;
$.add('wp-floattips');

})(jQuery, Platform.winport);
//~
