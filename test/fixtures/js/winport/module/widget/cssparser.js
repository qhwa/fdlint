/**
 * @fileoverview 简单解析/反解析css字符串
 * 
 * @author qijun.weiqj
 */
(function($, WP) {


var CssParser = {

	/**
	 * 解析css字符串生成json
	 * @return {array}
	 * 	[
	 * 		{ 
	 * 			selector: 'div.custom-bg', 
	 * 			styles:  [
	 * 				{
	 * 					property: 'background-color',
	 * 					value: '#FFFFFF'
	 * 				},
	 * 				{
	 * 					property: 'background-image',
	 * 					value: url(...)
	 * 				},
	 * 			]
	 * 		},
	 * 		...
	 * 	]
	 */
	parseCss: function(css) {
		var self = this,
			ret = [],
			regexp = /([^\{\}]+)\{([^\}]+)\}/gm,
			match = null,
			reComment = /\/\*[^*]*\*+([^/][^*]*\*+)*\//gm;
			
		css = css.replace(reComment, '');
		
		while ((match = regexp.exec(css))) {
			ret.push({
				selector: $.trim(match[1]),
				styles: self._parseStyleBody(match[2])
			});
		}
		
		return ret;
	},
	
	/**
	 * 解析样式体
	 */
	_parseStyleBody: function(body) {
		var styles = [],
			regexp = /([^:]+):([^;]+);/gm,
			match = null;
		
		while ((match = regexp.exec(body))) {
			styles.push({
				property: $.trim(match[1]),
				value: $.trim(match[2])
			});
		}
		
		return styles;
	},
	
	/**
	 * 根据json生成css字符串
	 * @return {string}
	 */
	toCss: function(json) {
		var css = [];
		$.each(json, function() {
			var o = this;
			css.push(o.selector + ' { ');
			$.each(o.styles, function() {
				var style = this;
				if (style.value) {
					css.push(style.property + ': ' + style.value + '; ');
				}
			});
			css.push(' }\n');
		});
		return css.join('');
	},
	
	/**
	 * 从样式json结构中取得指定样式
	 * @return {object}
	 * 	- property
	 * 	- value
	 */
	getStyle: function(json, selector, property) {
		for (var i = 0, c = json.length; i < c; i++) {
			var o = json[i],
				styles = o.styles;
			if (o.selector === selector) {
				return this._getStyle(o, property);
			}
		}
	},
	
	_getStyle: function(o, property) {
		var styles = o.styles,
			style = null;
		if (!property) {
			return o;
		}
		
		for (var i = 0, c = styles.length; i < c; i++) {
			style = styles[i];
			if (style.property === property) {
				return style;
			}
		}
	},
	
	/**
	 * 设置样式到样式json结构, 返回添加的或修改的样式数据
	 * @return {object}
	 * 	- property
	 * 	- value
	 */
	setStyle: function(json, selector, property, value) {
		var o = this.getStyle(json, selector);
		if (!o) {
			o = { selector: selector, styles: [] };
			json.push(o);
		}
		
		var styles = o.styles,
			style = null;
		for (var i = 0, c = styles.length; i < c; i++) {
			style = styles[i];
			if (style.property === property) {
				style.value = value;
				return style;
			}
		}
		
		style = { property: property, value: value };
		styles.push(style);
		return style;
	},
	
	/**
	 * 解析背景css字符串, 返回图片地址
	 * @return {string}
	 */
	getBkImgUrl: function(css) {
		var pattern = /url\(([^)]+)\)/;
		return (pattern.exec(css) || {})[1];
	}
};

WP.widget.CssParser = CssParser;
$.add('wp-cssparser');

})(jQuery, Platform.winport);
