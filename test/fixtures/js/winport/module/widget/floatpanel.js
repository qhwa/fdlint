/**
 * @fileoverview 浮动信息层
 *	1. 点击其他地方自动隐藏
 *	2. 指定时间后自动隐藏
 
 * @author qijun.weiqj
 */
(function($, WP) {

/**
 * @constractor
 * @param {selector|element} panel 浮层节点
 * @param {object} options
 * 	- handler {element|string} 点击此节点, 会打开panel
 * 	- event {string} 打开panel的事件, 默认为click
 *  - autoClose {boolean|integer} 自动关闭超时时间(ms), 默认为3000ms
 *  - closeOnBlur {boolean} 点击其他地方是否自动关闭, 默认为true
 *  - toggle {boolean} 如果果为true, 当浮层显示时, 单击handler时隐藏
 */
var FloatPanel = function(panel, options) {
	this._init.apply(this, arguments);
};
FloatPanel.prototype = {
	
	_init: function(panel, options) {
		this.panel = $(panel).eq(0);
		this.options = options || {};
		this.link = $(this.options.handler);
		
		this._handleLink();
		this._handleClose();
		this._handleCloseOnBlur();
		this._handleAutoClose();
	},
	
	/**
	 * 处理handler事件
	 * 点击(或其他)时需要显示浮层
	 */
	_handleLink: function() {
		var self = this;
		
		this.link.bind(this.options.event || 'click', function() {
            self.clear();
			if (!self.isShow) {
				self.show();
			} else if (self.options.toggle) {
				self.hide();
			}
        });
		
		this.link.click(function(e) {
			var elm = $(this);
			if (elm.is('a') && elm.attr('href') === '#') {
				e.preventDefault();
			}
		});
		
        this.hide();
	},
	
	/**
	 * 点击close关闭浮层
	 */
	_handleClose: function() {
		var self = this;
		$('.close', this.panel).click(function(){
			self.hide();
			return false;
		});
    },
	
	/**
	 * 点击其他地方关闭浮层
	 */
	_handleCloseOnBlur: function() {
		if (this.options.closeOnBlur === false) {
			return;
		}
		var self = this;
		$(document).click(function(e) {
			if (!self.isShow) {
				return;
			}
			var target = e.target;
			if (target !== self.link[0] && target !== self.panel[0] &&
					self.link.has(target).length === 0 && self.panel.has(target).length === 0) {
				self.hide();
			}
		}); 
	},

	/**
	 * 鼠标移开时自动关闭浮层
	 */
    _handleAutoClose: function () {
        var autoClose = this.options.autoClose;
        if (autoClose === false) {
            return;
        }
        
        var self = this,
			elms = $(this.panel).add(this.link),
			time = parseInt(autoClose, 10) || 3000,
			clear = $.proxy(this, 'clear'),
			hide = $.proxy(this, 'hide');
			
		elms.mouseleave(function() {
			self.clear();
			self._timer = setTimeout(hide, time);
			elms.one('mousemove', clear);
		});
    },
	
	clear: function() {
		this._timer && clearTimeout(this._timer);
		this._timer = null;
	},
	
	show: function() {
		if (this.isShow) {
			return;
		}
		if (this.options.beforeShow && this.options.beforeShow() === false || 
				this.panel.triggerHandler('before') === false) {
			return;
		}
		
		this.isShow = true;
		this._op('show');
		this.options.onshow && this.options.onshow();
		this.panel.triggerHandler('show');
		$.log('floatpanel show ');
		$.log(this.panel[0]);
	},
	
	hide: function() {
		if (!this.isShow) {
			return;
		}
		
		this.isShow = false;
		this._op('hide');
		this.options.onhide && this.options.onhide();
		this.panel.triggerHandler('hide');
		$.log('floatpanel hide ')
		$.log(this.panel[0]);
	},
	
	_op: function(name) {
		var elm = this.panel[0],
			op = this.options[name];
		return op ? op.call(elm, elm) : this.panel[name]();
	}
	
};
//~ FloatPanel

WP.widget.FloatPanel = FloatPanel;
$.add('wp-floatpanel');


})(jQuery, Platform.winport);

