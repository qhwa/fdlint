/**
 * @fileoverview简单切换组件
 * 
 * @author qijun.weiqj
 */
(function($, WP) {


/**
 * 切换组件支持, 由其它实现类mixin
 */
var Switchable = $.extend({
	
	/**
	 * @constractor 中需要调用此方法进行初始化
	 * @param elements 需要切换的节点, 参数同jQuery
	 * @param {object} options
	 *  - effect {string|function|{show: function, hide: function}} 切换效果
	 *  - index {number} 初始选中页, -1表示默认不选
	 */
	_initSwitchable: function(elements, options) {
		options = this.options = options || {};
				
		this.elements = $(elements);
		this.length = this.elements.length;
		this.effect = this._getEffect(options.effect);
		this.index = -1;
	},
	
	/**
	 * 切换效果
	 * @param {string|function|object} effect
	 */
	_getEffect: function(effect) {
		effect = effect || 'default';
		return typeof effect === 'string' ? this.Effect[effect] :
				$.isFunction(effect) ? { show: effect } : effect;
	},
	
	/**
	 * 切换到指定页
	 * @param {string|number} index 切换页码, 可以为'prev', 'next'或number
	 */
	switchTo: function(index) {
		if (!this.length) {
			return;
		}
		
		var self = this,
			elms = this.elements,
			lastIndex = this.index || 0,
			lastElm = lastIndex === -1 ? null : elms[lastIndex],
			nowIndex = this._getNewIndex(index || 0),
			nowElm = nowIndex === -1 ? null : elms[nowIndex],
			data = {
				lastIndex: lastIndex, 
				lastElm: lastElm,
				nowIndex: nowIndex,
				nowElm: nowElm
			},
			hide = this.effect.hide || this._empty;
		
		if (lastIndex === nowIndex || !this._confirm(data)) {
			return;
		}
		
		// 没有当前选中项, 直接展示
		if (!lastElm) {
			return this._showElm(data);
		}

		// 先隐藏后展示
		hide(lastElm, function() {
			$(lastElm).removeClass('selected');
			self._showElm(data);
		});
	},
	//~ switchTo
	
	_getNewIndex: function(index) {
		var i = this.index;
		if (index === 'prev') {
			i--;
		} else if (index === 'next') {
			i++;
		} else {
			i = parseInt(index, 10);
		}
		return index === -1 ? -1 : (i + this.length) % this.length;
	},
	
	_empty: function(elm, callback) {
		callback();
	},
	
	_confirm: function(data) {
		var options = this.options,
			onbefore = options.onbefore;
		if (onbefore && onbefore.call(options, data) === false) {
			return false;
		}
		return this.triggerHandler('before', data) !== false;
	},
	
	_showElm: function(data) {
		var self = this,
			onswitch = this.options.onswitch,
			show = this.effect.show || this._empty,
			nowIndex = data.nowIndex,
			nowElm = data.nowElm;
			
		if (nowIndex === -1) {
			return;
		}

		$.log('switch to ' + nowIndex);
		show(nowElm, function() {
			$(nowElm).addClass('selected');
			self.index = nowIndex;
			onswitch && onswitch.call(self.options, data);
			self.trigger('switch', data);
		});
	}
}, $.EventTarget);
//~ Switchable



/**
 * 为Switchable添加自动轮播功能
 */
$.extend(Switchable, {
	__initSwitchable: Switchable._initSwitchable,

	_initSwitchable: function() {
		this.__initSwitchable.apply(this, arguments);

		var autoSwitch = this.options.autoSwitch;
		
		if (!autoSwitch || this.length <= 1) {
			return;
		}
		this._initAutoSwitch(autoSwitch === true ? {} : autoSwitch);
	},

	_initAutoSwitch: function(config) {
		var self = this,
			interval = config.interval || 5000,
			hoverStop = config.hoverStop,
			next = config.next || 'default'

			flag = true;

		hoverStop && $(hoverStop).hover(function() {
			flag = false;
		}, function() {
			flag = true;
		});

		next = typeof next === 'function' ? next : Switchable.AutoSwitch[next];

		handler = function() {
			var index = next(self.index, self.length);
			flag && self.switchTo(index);
			setTimeout(handler, interval);
		};
		setTimeout(handler, interval);
	}
});

/**
 * 自动轮播内置类型
 */
Switchable.AutoSwitch = {
	/**
	 * 顺序插放
	 */
	'default': function(now, length) {
		now++;
		return now % length;
	},

	/**
	 * 随机播放
	 */
	'random': function(now, length) {
		var index = -1;
		while (now === 
			(index = Math.floor(Math.random() * length)));
		return index;
	}
};

/**
 * 切换组件效果库
 */
Switchable.Effect = {
	'default': {
		show: function(elm, callback) {
			$(elm).show();
			callback();
		},
		hide: function(elm, callback) {
			$(elm).hide();
			callback();
		}
	}
};
//~ Switchable.Effect


/**
 * 简单切换组件
 */
var SimpleSwitcher = function() {
	this._initSwitchable.apply(this, arguments);
};
$.extend(SimpleSwitcher.prototype, Switchable);
//~ Switcher



/**
 * 分页切换组件
 */
var PagingSwitcher = function() {
	this._init.apply(this, arguments);
};
$.extend(PagingSwitcher.prototype, Switchable, {
	
	_init: function(paging, elements, options) {
		options = options || {};
		this._initSwitchable(elements, options);
		this._handlePaging(paging, options);
	
		this.switchTo(options.index);
	},
	
	/**
	 * 处理分页事件
	 */
	_handlePaging: function(paging, options) {
		var self = this,
			delegate = options.delegate,
			event = options.event || 'click',
			handler = function(e) {
				e.preventDefault();
				
				var page = $(this).attr('data-paging');
				if (page === 'prev' && self.index === 0 ||
					page === 'next' && self.index === self.length - 1) {
					return;
				}
				
				self.switchTo(page);
			},
			navs = $(paging, delegate);
			
		if (delegate) {
			$(delegate).delegate(paging, event, handler);
		} else {
			navs.bind(event, handler);
		}
		
		this._handlePagingEffect(navs);
	},

	_handlePagingEffect: function(navs) {
		var self = this,
			prev = $(navs).filter('[data-paging=prev]'),
			next = $(navs).filter('[data-paging=next]');
		
		this.bind('switch', function(e, data) {
			var index = data.nowIndex,
				current = $(navs).filter('[data-paging=' + index + ']');
			navs.removeClass('disabled selected');
			index === 0 && prev.addClass('disabled');
			index === self.length - 1 && next.addClass('disabled');
			current.addClass('selected');
		});
	}
	
});
//~ PagingSwitcher


/**
 * 简单Tabs组件
 */
var Tabs = function() {
	this._init.apply(this, arguments);
};
$.extend(Tabs.prototype, Switchable, {
	_init: function(tabs, elements, options) {
		options = options || {};
		this._initSwitchable(elements, options);
		this._handleTabs(tabs, options);
		
		this.switchTo(options.index);
	},
	
	_handleTabs: function(tabs, options) {
		var self = this,
			delegate = options.delegate,
			event = options.event || 'click',
			handler = function(e) {
				var elm = $(this);
				elm.is('a') && e.preventDefault();
				if (elm.is(':radio,:checkbox') && !this.checked) {
					return;
				}
				self.switchTo(tabs.index(elm));
			};
			
		tabs = $(tabs, delegate);
			
		if (delegate) {
			$(delegate).delegate(tabs, event, handler);
		} else {
			tabs.bind(event, handler);
		}
		
		this._handleEffect(tabs);
	},
	
	_handleEffect: function(tabs) {
		this.bind('switch', function(e, data) {
			tabs.removeClass('selected');
			tabs.eq(data.nowIndex).addClass('selected');
		});
	}
});
//~ Tabs

$.extend(WP.widget, {
	Switchable: Switchable,
	Switcher: Switchable,
	PagingSwitcher: PagingSwitcher,
	Tabs: Tabs
});

$.add('wp-switchable');

})(jQuery, Platform.winport);
//~

