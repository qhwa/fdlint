/**
 * @fileoverview 旺铺自定义内容板块
 * @author qijun.weiqj
 */
(function($, WP) {

var CustomContent = new WP.Class({

	init: function(div, config) {
		this.div = div;

		var self = this,
			url = config.requestUrl,
			detailInfoId = config.detailInfoId;

		this.isEdit = $('#doc').data('docConfig').isEdit;

		if (detailInfoId === '0') {
			this.renderHtml(false);
			return;
		}

		$.ajax(url, {
			dataType: 'jsonp',
			data: {
				detailInfoId: detailInfoId,
				cid: config.cid,
				_env_mode_: this.isEdit ? 'EDIT' : 'VIEW'
			},
			success: function(o) {
				self.renderHtml(o.success ? o.data : false);
			}
		});
	},

	renderHtml: function(html) {
		var content = $('div.m-content', this.div);
		html = html ? '<div class="custom-content-wrap">' + html + '</div>' : 
				this.getBlankHtml();
		content.html(html);
	},

	getBlankHtml: function() {
		return this.isEdit ? '<div class="no-content">点击右侧的设置按钮，即可通过编辑器添加文字、图片等自定义内容，展示公告或促销等信息。</div>' : '<div class="no-content">暂无内容</div>';
	}

});


WP.ModContext.register('wp-custom-content', CustomContent);


})(jQuery, Platform.winport);
