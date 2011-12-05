/**
 * @fileoverview jQuery InplaceEditor Plugin - jQuery即时编辑插件
 * 
 * @author qijun.weiqj
 */

/**
 * jQuery#inplaceEditor(options | function);	 // 初始化inplaceEditor
 * jQuery#inplaceEditor(method, args); // 调用inplaceEditor方法
 * 
 * 1. 使用对象, 表示初始化inplaceEditor
 *  - event: 'click' | 'dblclick'
 *  - autosubmit: true | false
 *  
 *  - type	: editor type, 'input' | 'textarea' | 'select'
 *  - name	: name for editor, used in submit, default 'inplace-editor'
 *  - value	: initialize value for editor, if is different from text
 *  
 *  - items	: used in 'select' type. 
 *  		  exp: 
 *  			['Item1', 'Item2', 'Item3']
 *  			{ 'key1': 'value1', 'key2': 'value2' }
 *  			[{'key1': 'valu1', 'key2': 'value2'}, { 'key1': 'value1' }]
 *  
 *  - attr	: editor attributes
 *  - css	: editor styles
 *  
 *  - url	: ajax submit url
 *  - data	: extra ajax data
 *  
 *  - validate	: function(newValue, lastValue, element) 验证方法
 *  
 *  - submit	: 提交逻辑
 *  			 	function(value, callback(data), editor)
 *  				data: { 
 *  					'status': 'success' | 'error' | 'cancel',
 *  					'text': will render in text if specified
 *  					'html': will render in text if specified
 *  				}
 *  
 *  - success	: function(data)
 *  - error		: function(message)
 *  
 *  - onstart	: function() 编辑器打开时调用
 *  - onsubmit	: function() 编辑器提交时调用
 *  - oncancel	: function() 编辑器退出时调用
 *   
 *  - editor	: self ediotr create routine 编辑器创建逻辑
 *  
 *  2. 字符串表示方法调用
 *   jQuery#inplaceEditor(method, args)
 *    - start
 *    - submit
 *    - cancel
 *    - isActive
 *  
 */
(function($) {
	
$.fn.inplaceEditor = function(options) {
	options = options || {};
		
	var type = typeof options;
	
	// 处理jQuery#inplaceEditor(method, args) 调用
	if (type === 'string') {
		var method = options,
			args = arguments[1];
			
		this.each(function() {
			var elm = $(this),
				opts = null;
				
			// 如果是start, 则args当作options保存到节点上
			if (args && method === 'start') {
				args = typeof args === 'function' ? args(this) : args;
				elm.data('inplace-editor-options', args);
			}
			
			opts = elm.data('inplace-editor-options');
			opts && Methods[method](elm, opts);
		});
		return;
	} 
	
	// 如果是函数, 则针对每个节点生成不同options
	if (type === 'function') {
		this.each(function() {
			var elm = $(this),
				opts = options(this);
				
			elm.data('inplace-editor-options', opts);
			opts.event && handleEvent(elm, opts);
		});
	} else if (type === 'object') {
		this.data('inplace-editor-options', options);
		options.event && this.each(function() {
			handleEvent($(this), options);
		});
	} else {
		throw new Error('argument error.');
	}
};
//~ inplaceEditor


var Methods = {
	start: function(elm, options) {
		if (this.isActive(elm)) {
			return;
		}
		this._setActive(elm, true);
		
		setup(elm);
		
		var editor = elm.data('inplace-editor');
		if (!editor) {
			editor = option(elm, options, 'editor', new Editor(elm, options));
			elm.data('inplace-editor', editor);
		}
		
		var value = getEditorInitValue(elm, options),
			ret = editor.open(value);
		
		options.onstart && options.onstart.call(elm.get(0));
		
		ret === true ? this.submit(elm, options) :
			ret === false ? this.cancel(elm, options) : null;
	},
		
	submit: function(elm, options) {
		if (!this.isActive(elm)) {
			return;
		}
		
		if (elm.data('inplace-editor-submitting')) {
			return;
		}
		
		var self = this,
			editor = elm.data('inplace-editor'),
			lastValue = elm.data('inplace-editor-value'),
			newValue = editor.value(),
			called = false,
			callback = null;
		
		if (options.validate && 
				!options.validate.call(elm.get(0), newValue, lastValue)) {
			return;
		}
		
		elm.data('inplace-editor-submitting', true);
		
		callback = function(data) {
			if (called) {
				return;
			}
			called = true;
			
			if (complete(elm, options, data)) {
				self._setActive(elm, false);
			}
			elm.data('inplace-editor-submitting', false);
		};
			
		(options.submit || ajaxSubmit).call(elm.get(0), 
				newValue, callback, editor, options);
		
		options.onsubmit && options.onsubmit.call(elm.get(0));
		
	},
		
	cancel: function(elm, options) {
		if (!this.isActive(elm)) {
			return;
		}
		this._setActive(elm, false);

		complete(elm, options, { status: 'cancel' });
		options.oncancel && options.oncancel.call(elm.get(0));
	},
	
	isActive: function(elm) {
		return elm.data('inplace-editor-active');
	},
	
	_setActive: function(elm, active) {
		elm.data('inplace-editor-active', active);
	}
};
//~ Methods


/**
 * 挂接编辑事件
 */
function handleEvent(elm, options) {
	var event = option(elm, options, 'event', 'click');
	elm.bind(event, function() {
		Methods.start(elm, options);
	});
}


/**
 * 规整化文本节点(inplace-edtior-text)
 */
function setup(elm) {
	var text = elm.find('.inplace-editor-text');
	if (text.length == 0) {
		text = elm.find('div:first,span:first');
		text.length ? text.addClass('inplace-editor-text') :
				elm.wrapInner('<span class="inplace-editor-text" />');
	}
}

/**
 * 取得文本节点
 */
function getText(elm) {
	return elm.find('.inplace-editor-text');
}

/**
 * 取得编辑器初始化文本
 */
function getEditorInitValue(elm, options) {
	var value = elm.data('inplace-editor-value');
	if (value === undefined) {
		value = option(elm, options, 'value', getText(elm).text());
		elm.data('inplace-editor-value', value);
	}
	return value;
}

/**
 * 取得参数工具方法
 * @param elm 节点
 * @param options 参数对象
 * @param name 参数名称
 * @param value 默认值
 */
function option(elm, options, name, value) {
	var ret = options[name];
	ret = (typeof ret === 'function') ? ret.call(elm.get(0)) : ret;
	return ret === undefined ? value : ret;
}

/**
 * 编辑完成逻辑
 */
function complete(elm, options, data) {
	data = data || {};
	
	var text = getText(elm),
		editor = elm.data('inplace-editor');
	
	if (data.status === 'success') {
		elm.data('inplace-editor-value', editor.value());
		if (data.text) {
			text.text(data.text);
		} else if (data.html) {
			text.html(data.html);
		} else {
			var t = (editor.text || editor.value).call(editor);
			t ? text.text(t) : text.html('&nbsp;');
		}
		options.success && options.success.call(elm.get(0), data);
	} else if (data.status === 'error') {
		var message = data.message || 'submit error, please retry.';
		options.error && options.error.call(elm.get(0), message);
		return false;
	}
	
	editor.close && editor.close();
	return true;
}
//~

/**
 * 编辑器
 */
var Editor = function(elm, options) {
	this.elm = elm;
	this.options = options;
};
$.extend(Editor.prototype, {
	open: function(value) {
		var text = getText(this.elm),
			editor = this.editor;

		if (!editor) {
			editor = this.editor = this._create(this.elm, this.options);
			this._handleAutosubmit();
			this.name = editor.attr('name');
			editor.css('display', 'none'); // we show editor later
			text.after(editor);
		}
		
		editor.val(value);
		text.hide();
		editor.show().focus().select();
	},
	
	close: function() {
		this.editor.hide();
		getText(this.elm).show();
	},
	
	value: function() {
		return $.trim(this.editor.val());
	},
	
	text: function() {
		if (this.editor.is('select')) {
			var editor = this.editor.get(0),
				option = editor.options[editor.selectedIndex];
			return option && option.text;
		} else {
			return this.editor.val();
		}
	},
	
	_create: function(elm, options) {
		var type = option(elm, options, 'type'),
			editor = null,
			width = elm.width() - 5;
			
		width = (width < 20 ? 20 : width) + 'px';
			
		if (type == 'textarea') {
			editor = $('<textarea class="inplace-editor-textarea" />').css('width', width);
		} else if (type == 'select') {
			editor = $('<select class="inplace-editor-select" />');
			var items = option(elm, options, 'items', []);
			this._appendItems(editor, items);
		} else {
			editor = $('<input type="text" class="inplace-editor-input" />').css('width', width);
		}
		editor.addClass('inplace-editor');
		editor.attr('name', option(elm, options, 'name', 'inplace-editor'));
		editor.attr(option(elm, options, 'attr', {}));
		editor.css(option(elm, options, 'css', {}));
			
		return editor;
	},
	
	_appendItems: function(editor, items) {
		var self = this;
		$.each(items, function(key, value) {
			if (typeof value === 'object') {
				self._appendItems(editor, value);
			} else {
				editor.append($('<option value="' + key + '">' + value + '</option>'));
			}
		});
	},
	
	_handleAutosubmit: function() {
		var self = this,
			elm = this.elm,
			options = this.options,
			autosubmit = option(elm, options, 'autosubmit', !!options.event);
			
		autosubmit && this.editor.blur(function() {
			var lastValue = elm.data('inplace_editor_value'),
				newValue = self.value();
			Methods[lastValue == newValue ? 'cancel' : 'submit'](elm, options);
		});
	}
});
//~ Editor

/**
 * AJAX方式提交内容
 * @param {string} name
 * @param {string} value   
 * @param {function} complete
 * @param {element} elm
 */
function ajaxSubmit(value, complete, editor, options) {
	var elm = $(this),
		url = option(elm, options, 'url');
		
	if (!url) {
		throw new Error('please specify the url for ajax submit.');
	}
	
	var data = $.extend({}, option(elm, options, 'data', {}));
	data.name = $(editor).attr('name');
	data.value = value;
	
	$.ajax(url, {
		type: 'POST',
		data: data,
		success: function(text) {
			var data = $.parseJSON(text);
			(data && data.status) ? complete(data) 
					: complete({ status: 'error', message: 'ajax response data format error.' });
		},
		error: function() {
			complete({ status: 'error', message: 'connect to remote server error.' });
		}
	});
}
//~ ajaxSubmit

$.add('wp-inplaceeditor');

})(jQuery);
