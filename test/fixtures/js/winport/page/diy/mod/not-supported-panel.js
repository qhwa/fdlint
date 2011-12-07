/**
 * @fileoverview 旺铺降级后, 不可用板块升级提醒
 * @author qijun.weiqj
 */
(function($, WP) {


var Dialog = WP.widget.Dialog,
	Diy = WP.diy.Diy;


var NotSupportedPanel = {

	init: function() {
		var tpl = $('textarea.template-mod-not-supported-panel').val();
		if (!tpl) {
			return;
		}
		
		this.showDialog(tpl);
		this.initUpgradeGuidePanel();
		this.initUpgradeConfirmPanel();
	},

	/**
	 * 显示板块不能使用对话框
	 */
	showDialog: function(tpl) {
		var config = {
			header: '重要提醒',
			className: 'mod-not-supported-dialog',
			hasClose: false,
			draggable: true,
			content: tpl
		};
		this.dialog = Dialog.open(config);
		this.panel = $('div.mod-not-supported-panel', this.dialog.node);

		this.guidePart = $('div.upgrade-guide-part', this.panel);
		this.confirmPart = $('div.upgrade-confirm-part', this.panel);
	},
	
	/**
	 * 初始化升级面板
	 */
	initUpgradeGuidePanel: function() {
		this.initModList();
		this.handleUpgradeConfirm();
		this.handleUpgradeCancel();
	},

	/**
	 * 点击板块图标按扭, 取消链接默认行为
	 */
	initModList: function() {
		var modlist = $('ul.mod-list', this.guidePart);
		modlist.delegate('li a', 'click', function(e) {
			e.preventDefault();
		});
	},

	/**
	 * 处理确认订购按扭事件,需要切换到"升级完毕确认"面板
	 */
	handleUpgradeConfirm: function() {
		var self = this,
			confirm = $('a.confirm', this.guidePart);

		confirm.click(function() {
			// 由于需要同时打开升级引导页, 所以不需要preventDefault
			self.guidePart.hide();
			self.confirmPart.show();
		});
	},

	/**
	 * 处理"不再使用"按扭事件
	 */
	handleUpgradeCancel: function() {
		var self = this,
			cancel = $('a.cancel', this.guidePart),
			loading = $('div.loading', this.panel),
			url = this.panel.data('node-config').cleanUnGrantedUrl,
			docCfg = $('#doc').data('doc-config');

		cancel.click(function(e) {
			e.preventDefault();
			self.guidePart.hide();
			loading.show();
			Diy.authAjax(url, {
				type: 'POST',
				data: {
					_csrf_token: docCfg._csrf_token
				},
				success: function(o) {
					window.location.reload();
				}
			});
		});
	},


	/**
	 * 初始化升级完成面板
	 */
	initUpgradeConfirmPanel: function() {
		var self = this,
			links = $('a.confirm,a.cancel', this.confirmPart);
		links.click(function(e) {
			e.preventDefault();
			
			self.dialog.close();
			window.location.reload();
		});
	}
};


WP.PageContext.register('~NotSupportedPanel', NotSupportedPanel);


})(jQuery, Platform.winport);
//~
