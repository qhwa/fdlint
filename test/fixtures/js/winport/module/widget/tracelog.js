/**
 * @fileoverview 打点类
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Util = WP.Util;

/**
 * 有以下使用方法
 * 1. 	new TraceLog([
 * 			[selector1, tracelog1] // 打点配置信息, selector 可以为{string|element|jquery}
 *  		[selector2, tracelog2] 
 * 		], options); 	// 可选配置项
 * 
 * 2. 	new TraceLog([
 * 			[selector1, function(e, data) {	// 第二个参数可为function
 * 				// 根据节点返回需要的tracelog
 * 				var page = $(this).data('page-type');
 * 				...
 * 				return tracelog;
 * 			}],
 * 			...
 * 		]);
 * 
 * 3. 	new TraceLog('selector', 'tracelog', ...); 	// 如果只有一个打点数据, 可使用这种方式
 * 
 * 4. 	new TraceLog([...], { when: 'inputtext' };	// 输入域变化时才打点
 * 
 * 5. 	new TraceLog([...], { event: 'mouseenter', once: true };	// 鼠标进入时打点, 并且只打一次
 * 
 * 6. 	new TraceLog(element, { // 曝光打点
 * 			when: 'exposure', 
 * 			url: 'http://ctr.china.alibaba.com/ctr.html',
 * 			param: { ctr_type: 32, keyword: ... }
 * 		});
 *
 * @param fields	打点配置信息
 * @param options 	可选配置项
 * 	- when {string|function(elm, callback, options)} 打点时机 
 * 			default: 默认打点
 * 			exposure: 曝光打点
 * 			inputtext: 输入域变化时才打点
 * 			{function}: 自定义打点时机
 * 
 *  - event 当采用默认打点方式(when=default)时， 可以指定打点事件, exp; mousedown
 *  
 *  - delegate {string|true} 采用默认打点方式或inputtext打点时, 可指定使用delegate事件处理方式
 *  		若为true, 相当于 delegagte: 'body'
 * 			 
 * 	- how {function(name, elm, options)} 如何打点
 * 			默认采用aliclick打点
 * 			{function}: 可以指定自定义打点方式
 *  - url {string} 如果是默认打点(how=default)时， 可以指定此url而不使用aliclick打点
 * 	- param {function(elm)} 如果为url打点时, 此为附加参数
 * 
 * 具体使用方法, 可参考旺铺的tracelog文件
 * 	1. module/mod/core/rec-advertisment.js  曝光打点, 和指定url打点
 *  2. page/default/tracelog/*, page/diy/tracelog/*  
 *  
 */
var TraceLog = function(fields, options) {
	if (!$.isArray(fields)) {
		fields = [fields];
		if (!$.isPlainObject(options)) {
			fields.push(options)
			options = arguments[2];
		}
	}
	if (!$.isArray(fields[0])) {
		fields = [fields];
	}
	options = options || {};
	
	var when = option('When', options.when),
		how = option('How', options.how);
	
	$.each(fields, function() {
		var field = this,
			selector = field[0],
			name = field[1];
		when(selector, function() {
			var tracelog = typeof name === 'function' ? 
					name.apply(this, arguments) : name;
			tracelog !== false && how(tracelog, this, options, arguments);
		}, options);
	});
	
	function option(type, name) {
		name = name || 'default';
		return typeof name === 'string' ? 
				$.proxy(TraceLog[type], name) :
				$.proxy(name, options);
	}

};

/**
 * 打点时机
 */
TraceLog.When = {
	/**
	 * 默认打点, 事件由options.when指定, 默认为click
	 */
	'default': function(selector, callback, options) {
		var once = options.once,
			delegate = options.delegate,
			handler = function() {
				var elm = $(this);
				if (once && elm.data('tracelog-once')) {
					return;
				}
				callback.apply(this, arguments);
				once && elm.data('tracelog-once', true);
			};
					
		if (delegate) {
			delegate = delegate === true ? 'body' : delegate;
			$(delegate).delegate(selector, 
					options.event || this._getDelegateEvent(selector), handler)
		} else {
			var elm = $(selector);
			if (elm.length > 5) {
				$.log('TraceLog warn: more than 5 element matches with selector: ' + selector);
			}
			elm.bind(options.event || this._getDefaultEvent(elm), handler);
		}
	},
	
	_getDefaultEvent: function(elm) {
		if (elm.is('a,button')) {
			return 'mousedown';
		}
		if (elm.is('select')) {
			return 'change';
		}
		return elm.is('input') && 
				elm.attr('type') === 'text' ? 'blur' : 'mousedown';
	},
	
	_getDelegateEvent: function(selector) {
		if (typeof selector !== 'string') {
			$.error('argument error, should be an string.');
		}
			
		var // selector tag.class || selector tag[name=value..] || selector tag.class[name=value]
			tag = (/\b([\w-]+)(?:\.[\w-]+)*(?:\[[^\]]+\])*$/.exec(selector) || {})[1];

		return tag === 'input' ? 'click' :
			tag === 'select' ? 'change' : 'mousedown';
	},
	
	/**
	 * 输入框打点(有变化时)
	 */
	inputtext: function(selector, callback, options) {
		var delegate = options.delegate,
			focusin = function() {
				var elm = $(this);
				elm.data('tracelog-last', elm.val());
			},
			focusOut = function() {
				var elm = $(this);
				if (elm.data('tracelog-last') !== elm.val()) {
					callback.apply(this, arguments);
				}
			};
		
		delegate = delegate === true ? 'body' : delegate;
		
		if (delegate) {
			$(delegate).delegate(selector, 'focusin', focusin);
			$(delegate).delegate(selector, 'focusout', focusOut);
		} else {
			selector = $(selector);
			selector.bind('focus', focusin);
			selector.bind('blur', focusOut);
		};
	},
	
	/**
	 * 曝光打点
	 */
	exposure: function(selector, callback, options) {
		var self = this,
			elm = $(selector),
			handler = function() {
				if (elm.data('tracelog-exposure')) {
					return;
				}
				if (self._isVisible(elm)) {
					callback.call(elm);
					elm.data('tracelog-exposure', true);
				};
			};
		$(window).bind('scroll resize', handler);
		handler();
	},
	
	/**
	 * 判断元素是否可见
	 * 1.元素可见
	 * 2.滚动偏移<元素top
	 * 3.滚动偏移+屏幕高度 > 元素top
	 */
	_isVisible: function(elm) {
		var win = $(window),
			eTop = elm.offset().top,
			sTop = win.scrollTop();
		return elm.is(':visible') && sTop < eTop && eTop < sTop + win.height();
	}
};

/**
 * 打点方式
 */
TraceLog.How = {
	/**
	 * 如何打点：
	 * 1. 指定 options.url打点
	 * 2. 默认为aliclick打点
	 */
	'default': function(name, elm, options) {
		var params = typeof options.param === 'function' ? 
				options.param(elm) : options.param;
		if (options.url) {
			var img = new Image();
			img.src = Util.formatUrl(options.url, params || {});
		} else if (name) {
			aliclick(null, '?tracelog=' + name);
		}
	}
};


WP.widget.TraceLog = TraceLog;
$.add('wp-tracelog');

})(jQuery, Platform.winport);
