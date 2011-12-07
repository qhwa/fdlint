/**
 * @fileoverview 旺铺自定义风格--布局
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Util = WP.Util,
	Msg = WP.diy.Msg,
	Diy = WP.diy.Diy,
	Parts = WP.diy.site.CustomStyles.Parts;

Parts.Layout = {
	
	init: function() {
		this.panel = $('li.custom-styles-layout', this.div);
		
		// 布局列表
		this.ul = $('div.setting-node-content>ul', this.panel);
		this.lis = $('li', this.ul);
		
		// 当前选中的布局li(和后端同步), 在数据提交成功后更新
		this.lastLi = $('li.selected', this.ul);
		
		this.layout = $('div.layout.p32-s5m0,div.layout.p32-m0s5', '#winport-content');
		this.layoutData = this.layout.closest('div.layout-box').data('box-config') || {};
		
		// 全局配置信息
		this.docCfg = $('#doc').data('doc-config');
		this.contentCfg = $('#content').data('content-config');
		
		this.handleEvents();
	},
	
	/**
	 * 处理布局切换事件
	 */
	handleEvents: function() {
		var self = this;
			
		this.lis.click(function(e) {
			e.preventDefault();
			
			// 在数据提交过程中, 不允许再切换布局
			if (self.running) {
				return;
			}
			
			var li = $(this),
				data = li.data('layout');
			
			// 当前为选中项, 则不处理
			if (li.hasClass('selected')) {
				return;
			}
			
			self.changeLayout(li, data);
			self.updateLayout(li, data);
		});
	},
	
	/**
	 * 切换(渲染)页面布局
	 */
	changeLayout: function(li, data) {
		var selectedLi = $('li.selected', this.ul),
			selectedClass = selectedLi.data('layout').classname;
		
		// 切换tab
		this.lis.removeClass('selected');
		li.addClass('selected');
		
		// 切换布局
		this.layout.addClass(data.classname).removeClass(selectedClass);
	},
	
	/**
	 * 更新服务端布局信息
	 */
	updateLayout: function(li, data) {
		var self = this,
			action = null,
			url = this.config.customizeLayoutUrl;
		
		action = function() {
			// 减少不必要的更新请求
			if (li[0] === self.lastLi[0]) {
				return;
			}
			
			self.running = true;
			
			Diy.authAjax(url, {
				type: 'POST',
				data: self.wrapUpdateData(data.cid),
				dataType: 'json',
				success: function(ret) {
					self.updateSuccess(ret, li, data);
				},
				error: function() {
					self.restoreLayout(li, data);
				},
				complete: function() {
					self.running = false;
				}
			});
		};
		
		Util.schedule('style-layout', action);
	},
	
	wrapUpdateData: function(cid) {
		return {
			layoutCid: cid,
			_csrf_token: this.docCfg._csrf_token,
			version: this.contentCfg.version,
			pageSid: this.contentCfg.sid
		};
	},
	
	updateSuccess: function(ret, li, data) {
		++(this.contentCfg.version);
		
		if (ret.success) {
			this.lastLi = li;
			// 需要更新mod-box data-box-config数据
			this.layoutData.cid = data.cid;
			
			$(window).trigger('diychanged', { type: 'custom-style-layout' });
			Msg.info('布局版式设置成功');
		} else if (ret.data === 'VERSION_EXPIRED') {
			window.location.reload();
		} else {
			this.restoreLayout(li, data);
			Msg.error('布局版式设置失败');
		}
	},
	
	/**
	 * 更新失败时, 恢复页面布局
	 */
	restoreLayout: function(li, data){
		var lastClass = this.lastLi.data('layout').classname;
		
		this.lis.removeClass('selected');
		this.lastLi.addClass('selected');
		
		this.layout.addClass(lastClass).removeClass(data.classname);
	}

};

	
})(jQuery, Platform.winport);
