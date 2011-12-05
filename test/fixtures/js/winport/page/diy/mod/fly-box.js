/**
 * fly-box
 * @author qijun.weiqj
 */
(function($, WP) {


var ModBox = WP.diy.ModBox;


var FlyBox = {

	init: function() {
		this.fly = $('div.winport-fly');
		this.flyBox = $(this.template);
		
		this.initModBox();
		this.handleFlyBoxDisplay();
		this.initFlyBar();
	},

	/**
	 * 由于后端渲染不能很好地在fly区渲染不同的modbox
	 * 所以需要对其中的mod-box进行处理，包括box-shim,box-bar,bof-fly-adder的移除
	 *
	 * beforereload时, 需要detach flayBox,因为如果flyBox如果存在mod内部会被删除
	 */
	initModBox: function() {
		var self = this,
			selector = 'div.box-shim,div.box-bar,a.box-fly-adder';

		$(selector, this.fly).remove();
		$('div.box-adder', this.fly).remove();

		this.fly.delegate('div.mod-box', 'reloaded loaded', function() {
			var mod = $('div.mod', this);

			$(selector, this).remove();
			self.flyBox.appendTo(mod);

			setTimeout(function() {
				self.loading = false;
			}, 100);
		});

		this.fly.delegate('div.mod-box', 'reloading', function() {
			self.flyBox.detach();
			self.loading = true;
		});
	},

	handleFlyBoxDisplay: function() {
		setTimeout($.proxy(this, '_handleFlyBoxDisplay'), 100);
	},

	_handleFlyBoxDisplay: function() {
		var self = this;

		this.fly.delegate('div.mod', 'mouseenter', function() {
			if (self.loading) {
				return;
			}
			var mod = $(this);
			self.showFlyBox(mod);
		});

		this.fly.delegate('div.mod', 'mouseleave', function() {
			self.hideFlyBox();
		});
	},

	showFlyBox: function(mod) {
		var box = this.flyBox,
			height = mod.height();
		
		height && box.height(height);
		if (!$('div.fly-box', mod).length) {
			mod.append(box);
		}
		box.addClass('fly-box-in');
	},

	hideFlyBox: function() {
		this.flyBox.removeClass('fly-box-in');
	},

	initFlyBar: function() {
		var bar = $('div.fly-bar', this.flyBox);

		bar.bind('click dblclick', false);

		this.handleFlyStateBtn(bar);
		this.handleFlyBarEdit(bar);
	},

	handleFlyStateBtn: function(bar) {
		var self = this,
			box = this.flyBox;

		bar.delegate('a.minimize', 'click', function() {
			self.getModBox().addClass('mod-box-minimize');
		});

		bar.delegate('a.normalize', 'click', function() {
			self.getModBox().removeClass('mod-box-minimize');
		});
	},

	handleFlyBarEdit: function(bar) {
		bar.delegate('a.edit', 'click', function() {
			var box = $(this).closest('div.mod-box');
			ModBox.edit(box);
		});
	},

	getModBox: function() {
		return this.flyBox.closest('div.mod-box');
	},

	template: 
'<div class="fly-box">\
	<div class="fly-shim"></div>\
	<div class="fly-bar">\
		<div class="b-body">\
			<a href="#" title="设置" class="edit"></a>\
			<a href="#" title="最小化" class="minimize"></a>\
			<a href="#" title="还原" class="normalize"></a>\
		</div>\
	</div>\
</div>'


};


WP.PageContext.register('~FlyBox', FlyBox);


})(jQuery, Platform.winport);
