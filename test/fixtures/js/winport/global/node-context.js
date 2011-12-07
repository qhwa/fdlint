/**
 * NodeContext用于管理节点的初始化
 * @author qijun.weiqj
 */
(function($, WP) {


/**
 * 统一管理页面节点的初始化工作
 * @param {string} name Context名称, 不同的Context需要有不同的名称, 如ModContext, PageContext等
 * @param {object} defaultOptions 默认配置信息
 *      - entityName {string} 模块初始化时, 会调用的方法名称, 默认为init
 *      - configField {string} 节点的该名称的html5 data属性值会传给初始化方法, 默认为 node-config(data-node-config)
 *      						ModeContext为mod-config(data-mod-config)
 *		- lazy {boolean} 是否延迟初始化
 *      - once {boolean} 默认为true, 多次调用NodeContext::refresh()是否只对节点初始化一次
 *      - root {selector} Context相关节点所属父结点selector, queryNodes中使用
 *      
 */
var NodeContext = function(name, defaultOptions) {
	this._defaultOptions = $.extend({
		entryName: 'init',
		configField: 'nodeConfig',
		lazy: false,
		once: true,
		root: null
	}, defaultOptions);
	
	this.name = name;
	this.length = 0;

	this._nodes = {};
	this._guid = 0;
	
	this._handleDomReady();
};

$.extend(NodeContext.prototype, {
	
	/**
	 * 注册需要初始化的节点
	 * @param {string} name 名称, Context在初始化时会根据此名称取得实际DOM结点
	 *      如 ModContext 会取得class = name的DOM节点进行初始化
	 *         PageContext 会以 jQuery(name) 的方式取得 DOM节点进行初始化
	 *         
	 *      可以为空, 表示此初始化不针对特定节点
	 *      PageContext.register(function() {...});  // 用此方式代替domready, 这样就可能对所有入口进行统一处理
	 *         
	 * @param {object|function} config 配置信息
	 * 			其中初始化方法签名为： function(context, config) 
	 *      
	 */
	register: function(name, config, options) {
		// 可省略参数name
		if (typeof name !== 'string') {	
			options = config;
			config = name;
			name = '~' + this.name.toLowerCase() + this._guid++;	// 节点为body
		}
		
		// 避免重复注册
		if (this._nodes[name]) {
			$.log('warn: ' + this.name + ' ' + name + ' already exist, ignore it.');
			return;
		}
		
		options = $.extend({}, this._defaultOptions, options);
		
		// config是function, 则此模块为多实例模块
		options.context = $.isFunction(config);
		if (options.context) {
			config = { init: this._wrapProtoInit(name, config) };
		} else {
			config.init = this._wrapStaticInit(name, config);
		}
		
		var self = this,
			data = { name: name, config: config, options: options };
		this._nodes[name] = data;
		this.length++;
		$.log(this.name + ' ' + name + ' registered.');
		
		// 如果在domready后注册, 并且不是延迟初始化, 则直接初始化
		if (this._isDomReady && !options.lazy) {
			this.init(name);
		}
		
		return this;
	},

	/**
	 * 处理DomReady事件, 初始化非lazy节点
	 */
	_handleDomReady: function() {
		var self = this;
		$(function() {
			self.init();
			self._isDomReady = true;
		});	
	},

	isNodeAllReady: function() {
		return this._isDomReady;
	},
	
	/**
	 * 初始化context, 由框架调用, 有两种情况见注释
	 * @param {string|element} name (可选)需要初始化的node名称或dom
	 */
	init: function(name) {
		var self = this;
		
		// 1. 指定name
		if (typeof name === 'string') {
			var node = this._nodes[name];
			if (!node) {
				$.error(this.name + ' ' + name + ' is not exists.');
			}
			return this._initNode(node);
		}
		
		// 2. 对节点进行初始化
		if (name) {
			$(name).each(function() {
			  	var node = self._resolveNode(this);
			  	if (!node) {
				  	$.log(self.name + ' can not resolve node');
				  	$.log(this);	// for debug easy in firefox
					return;
			  	}
				self._initElement(this, node);
			});
		} else {
		  $.each(this._nodes, function() {
			  var node = this;
			  if (!node.options.lazy) {
				  self._initNode(node);
			  }
		  });
		  this.trigger('nodeallready');
		  $.log(self.name + ' nodeallready');
		}
	},
	
	
	refresh: function(name, data) {
		this._refreshData = data === undefined ? true : data;
		this.init(name);
		this._refreshData = null;
	},
	
	/**
	 * 创建多实例模块init的包装对象, 让每次执行init时都有独立的context(this独立)
	 * @param {string} name 模块名称
	 * @param {function} init
	 */
	_wrapProtoInit: function(name, init) {
		var self = this,
			delegate = function() {};
		delegate.prototype = init.prototype;
		return function(elm, params, refreshData) {
			elm = $(elm);
			var proxy = self._getElementInstance(elm, name);
			if (!proxy) {
				proxy = new delegate();
				self._setElementInstance(elm, name, proxy);
			}

			return self._beforeInit(elm, params, refreshData, proxy) &&
					init.apply(proxy, arguments);
		};
	},

	/**
	 * 创建单实例模块包装对象, this指向config
	 */
	_wrapStaticInit: function(name, config) {
		var self = this,
			init = config.init; // 需要保存init引用, 因为之后config.init会被替换
		return function(elm, params, refreshData) {
			return self._beforeInit(elm, params, refreshData, config) &&
					init.apply(config, arguments);
		};
	},

	/**
	 * 触发beforeinit事件由初始化包装对象调用
	 */
	_beforeInit: function(element, params, refreshData, context) {
		data = { 
			element: element, 
			config: params,
			refreshData: refreshData,
			context: context
		};
		return this.triggerHandler('beforeinit', data) !== false
	},


	/**
	 * 取得节点实例对象
	 */
	_getElementInstance: function(elm, name) {
		var cache = this._getElementCache(elm, 'nodeContextInstance'),
			instanceName = this.name + '.' + name;
		return cache[instanceName];
	},

	/**
	 * 设置节点的实例对象
	 */
	_setElementInstance: function(elm, name, proxy) {
		var cache = this._getElementCache(elm, 'nodeContextInstance'),
			instanceName = this.name + '.' + name;
		cache[instanceName] = proxy;
	},
	
	/**
	 * 取得节点关联数据
	 * @param {jquery} elm 节点对象
	 * @name 名称
	 */
	_getElementCache: function(elm, name) {
		var cache = elm.data(name);
		if (!cache) {
			cache = {};
			elm.data(name, cache);
		}
		return cache;
	},

	
	/**
	 * 初始化已注册的一个节点
	 * @param {object} node
	 */
	_initNode: function(node) {
		var self = this,
			elms = this._queryNodes(node.name);
		elms && $(elms).each(function() {
			self._initElement(this, node);
		});
	},
	
	/**
	 * 根据注册的名称取得对应dom节点
	 * 忽略前缀为'~'的名称, 返回body
	 * 非id和class形式名称当成class处理
	 * 
	 * @param {string} name 注册的名称
	 * @return {array<element>} 返回DOM节点数组
	 */
	_queryNodes: function(name) {
		name = name.indexOf('~') === 0 ? 'body' : 
				/^#|\./.test(name) ? name : '.' + name;
		return $(name, this.root);
	},
	
	/**
	 * 根据DOM节点取得注册信息
	 * 按以下顺序逻辑取得注册信息
	 * 	1. data context-name域, attr data-context-name
	 * 	2. className
	 * 	3. 已注册的nodes name, 使用$(elm).is(node.name)
	 * @param (element) DOM节点
	 */
	_resolveNode: function(elm) {
		elm = $(elm);

		var cache = this._getElementCache(elm, 'nodeContextName'),
			contextName = this.name;

		// 1 from data and attr
		var name = cache[contextName];
		if (name) {
			return this._nodes[name];
		}
		
		// 2 from class name
		var cns = (elm[0].className || '').split(/\s+/);
		for (var i = 0, c = cns.length; i < c; i++) {
			var node = this._nodes[cns[i]];
			if (node) {
				cache[contextName] = node.name;
				return node;
			}
		}
		
		// 3 from registers
		for (var k in this._nodes) {
			var node = this._nodes[k];
			if (node.name.indexOf('~') !== -1 && elm.is(node.name)) {
				cache[contextName] = node.name;
				return node;
			}
		}
	},
	
	/**
	 * 对节点elm进行初始化
	 * @param {element} elm 需要初始化的节点
	 * @param {object} node 节点信息数据结构 { name, config, options }
	 */
	_initElement: function(elm, node) {
		var elm = $(elm),
			
			config = node.config,
			options = node.options,
			
			name = options.entryName,
			entry = config[name],
			params = elm.data(options.configField),
			data = null,
			
			// 一个节点可能注册多个初始化context
			guard = this._getElementCache(elm, 'nodeContextGuard'),					
			guardName = this.name + '.' + node.name,

			start = $.now();

		if (!entry) {
			$.error('entry function [' + name + '] for ' + elm[0] + ' is no exist.');
		}
		// 如果需要, 保证每个node只初始化一次
		if (options.once && guard[guardName]) {
			return;
		}
		
		// 在try catch中调用初始化方法, 以保持一个节点初始化失败不影响其他节点的初始化
		try {
			// 初始化方法返回false, 表示此次初始化失败(在refresh时会再次初始化)
			// 可用此特性进行延迟加载
			if (entry(elm[0], params, this._refreshData) === false) {
				return;
			}

			data = { element: elm[0], config: params };
			data.context = options.context ? 
					this._getElementInstance(elm, node.name) : config;
			this.triggerHandler('afterinit', data);
			options.once && (guard[guardName] = true);
			
			$.log(guardName + ' initialized, cost: ' + ($.now() - start) + ' ms');
		} catch (e) {
			$.log(node.name + ' init failed: ');
			$.error(e);
		}
	},

	getContext: function(elm) {
		var node = this._getElementNode(elm);
		if (!node) {
			return null;
		}
		return node.options.context ? 
				this._getElementInstance($(elm), node.name) : node.config;
	},

	/**
	 * 取得node结构
	 * @param {string|element} elm 模块名称或节点
	 */
	_getElementNode: function(elm) {
		return typeof elm === 'string' ? 
				this._nodes[elm] : this._resolveNode(elm);
	},

	/**
	 * 查询模块或节点是否已初始化
	 * @param {element} elm 待查询的节点
	 */
	isInited: function(elm) {
		elm = $(elm);

		var guard = this._getElementCache(elm, 'nodeContextGuard'),	
			node = this._resolveNode(elm);

		return guard[this.name + '.' + node.name] || false;
	},

	/**
	 * 执行模块中的方法
	 * @param {element|string} elm 节点或者名称
	 * @param {string} 方法名
	 * @param {array} args 参数
	 */
	execute: function(elm, name, args/*...*/) {
		var node = this._getElementNode(elm); 
		if (!node) {
			$.log(this.name + '.exeute(' + name +  '): node not exist, return undefined');
			return;	
		}

		var config = node.config,
			instance = null;

		args = [].slice.call(arguments, 2);

		if (node.options.context === true) {
			if (typeof elm === 'string') {
				elm = this._queryNodes(elm);
			}
			instance = this._getElementInstance($(elm), node.name);
			if (!instance) {
				$.error('instance not exist');
			}

			$.log(this.name + '.execute: ' + node.name + '#' + name);
			return instance[name].apply(instance, args);
		} else {
			$.log(this.name + '.execute: ' + node.name + '.' + name);
			return config[name].apply(config, args)
		}
	}


}, $.EventTarget);
//~ NodeContext


WP.NodeContext = NodeContext;


})(jQuery, Platform.winport);

