/**
 * 简单模块分离包装
 * 
 * @param {object} o 模块对象
 * @param {array} args
 */
(function($, WP) {


var Parts = function() {
	this.init.apply(this, arguments);
};

Parts.prototype = {
	init: function(name, o, args) {
		if (typeof name !== 'string') {
			args = o;
			o = name;
			name = o.name || 'anony-part'
		}
		
		this._mixPartsProto(o);
		this._mixPartsMember(o);
		this._executeParts(name, o, args);
	},

	_mixPartsProto: function(o) {
		if (o['__partsMixed__']) {
			return;
		}

		var proto = this._getPartsProto(o);
		$.each(o.Parts, function() {
			$.extendIf(this, proto);
		});

		o['__partsMixed__'] = true;
	},

	_getPartsProto: function(o) {
		var proto = {};
		$.each(o, function(k, v) {
			if (typeof v === 'function' && 
					k !== 'init' && k !== 'Parts' && k.indexOf('_') !== 0) {
				proto[k] = $.proxy(v, o);	
			}
		});

		return proto;
	},

	_mixPartsMember: function(o) {
		var mix = {};
		$.each(o, function(k, v) {
			if (k !== 'init' && k !== 'Parts' && k.indexOf('_') !== 0 && 
					typeof v !== 'function') 
				mix[k] = v;
		});
		$.each(o.Parts, function() {
			$.extend(this, mix);
		});
	},

	_executeParts: function(name, o, args) {
		var start = $.now();
		$.each(o.Parts, function(k) {
			try {
				this.init.apply(this, args || []);
				$.log('Parts ' + name + '.' + k + ' init complete');
			} catch (e) {
				$.error('Parts init failed:' + e);
			}
		});
		
		$.log('Parts ' +  name + ' init complete, cost: ' + ($.now() - start) + ' ms');
	}

};


WP.Parts = Parts;


})(jQuery, Platform.winport);

