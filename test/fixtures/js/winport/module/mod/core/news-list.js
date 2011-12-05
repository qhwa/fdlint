/**
 * @fileoverview 公司动态
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Util = WP.Util,
	UI = WP.UI;
	
var NewsList = Util.mkclass({
	
	template: 
		'<% if (articles.length) { %>\
		<ul>\
			<% jQuery.each(articles, function(index, article) { %>\
			<li><a href="<%= article.arturl %>" title="<%= util.escape(article.subject) %>" target="_blank" class="subject"><%= util.formatSubject(article.subject) %></a>\
				<div class="props">阅读<%= article.viewCountText %> 评论<%= article.comCountText %> <%= article.postTime %></div>\
			</li>\
			<% }) %>\
		</ul>\
		<div class="m-content-footer"><a href="<%= moreUrl %>" target="_blank" class="more">更多 &gt;&gt;</a></div>\
		<% } else { %>\
		<div class="no-content">暂无公司动态</div>\
		<% } %>',
		
	init: function(div, config) {
		this.div = div;
		
		var self = this,
			url = config.requestUrl;
			
		$.ajax(url, {
			dataType: 'script',
			success: function() {
				self.render(window.article || [], config);
			}
		});
	},
	
	render: function(articles, config) {
		var content = $('div.m-content', this.div),
			isGridSub = $(this.div).closest('div.grid-sub').length > 0;
			
		articles = config.showCount ? 
				articles.slice(0, config.showCount) : articles;
		this.filter(articles);
		UI.sweetTemplate(content, this.template, {
			articles: articles,
			moreUrl: config.moreUrl,
			util: {
				// 侧栏需要处理长标题
				formatSubject: function(subject) {
					subject = Util.escape(subject); 
					return isGridSub && Util.lenB(subject) > 24 ?
							Util.cut(subject, 23) + '..' : subject;
				},
				
				escape: Util.escape
			}
		});
	},
	
	filter: function(articles) {
		var self = this,
			t = { viewCount: 0, comCount: 0 };
		$.each(articles, function() {
			for (var k in t) {
				var len = ('' + this[k]).length;
				t[k] < len && (t[k] = len);
			}
		});
		$.each(articles, function() {
			for (var k in t) {
				this[k + 'Text'] = self.format('' + this[k], t[k]);
			}
		});
	},
	
	format: function(text, len) {
		var k = len - text.length,
			t = [];
		for (var i = 0; i < k; i++) {
			t.push('&nbsp;&nbsp;');
		}
		return '(' + text + ')' + t.join('');
	}
});


/**
 * 为了兼容原结构, 需要定义以下全局方法
 */
window.displayCompanyInfo = $.noop;


WP.ModContext.register('wp-news-list', NewsList);


})(jQuery, Platform.winport);
