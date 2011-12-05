/**
 * @fileoverview DIY后台的特殊逻辑
 * 
 * @author long.fangl
 */
(function($, WP) {
	
var Msg = WP.diy.Msg;

var SpecialLogic = {
	init: function(){
		this.fixIE6Background();
		this.cancelTopNavShim();
		this.showPageSwitchTip();
		this.resetEmptyMod();
		this.handlePositionFixed();
	},
	
	fixIE6Background: function() {
		if ($.util.ua.ie6) {
			try {
				document.execCommand('BackgroundImageCache', false, true);
			} catch (e) {
				// ignore
			}
		}
	},
	
	/**
	 * 载入后需要去掉导横条的shim
	 */
	cancelTopNavShim: function() {
		var box = $('div.wp-top-nav').closest('div.mod-box');
		$('div.box-shim', box).remove();

		box.bind('reloaded', function() {
			$('div.box-shim', box).remove();
		});
	},
	
	/**
	 * 切换装修页面提示
	 */
	showPageSwitchTip: function() {
		var docCfg = $('#doc').data('doc-config'),
			contentCfg = $('#content').data('content-config'),
			showTip = docCfg.showPageSwitchTip,
			pageName = contentCfg.pageName;
			
		if (showTip) {
			Msg.info($.util.substitute('已进入{0}', [pageName]));
		} else if (pageName === '首页') {
			Msg.info('欢迎进入阿里巴巴旺铺装修平台');
		}
	},
	
	/**
	 * 由于后端技术原因, 有可能会出现空的box, 这会影响拖拽等逻辑, 所以对此进行特殊处理
	 */
	resetEmptyMod :  function() {
		$('div.mod-box').each(function() {
			var box = $(this);
			if ($('div.mod', box).length === 0) {
				(box.data('box-config') || {}).movable = false;
				box.hide();
			}
		});
	},
	
	/**
	 * 板块载入时会引起页面变化，需要触发scroll事件
	 * 以让UI.fixedPosition正常工作
	 * 1. 顶部setting bar
	 * 2. 布局模式按扭
	 */
	handlePositionFixed: function() {
		var win = $(window);
		$('div.mod-box').live('reloaded', function() {
			win.triggerHandler('position-fixed');
		});

		win.bind('diychanged', function(e, data) {
			data.type === 'del-box' && win.triggerHandler('position-fixed');
		});
	}
};

WP.PageContext.register('~DiySpecialLogic', SpecialLogic);

})(jQuery, Platform.winport);
