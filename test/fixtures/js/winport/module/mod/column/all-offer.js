/**
 * @fileoverview 供应产品栏目页
 * 
 * @author long.fanl
 */
(function($, WP) {
	
var InstantValidator = WP.widget.InstantValidator,
	Paging = WP.mod.unit.Paging,
	Offers = WP.mod.unit.Offers;


var AllOfferColumn = {
	
	init: function(div) {
		this.div = div;
		
		this.initSearch();
		this.initFolding();
		this.initFilters();
		this.initPaging();
	},
	
	initSearch: function() {
		var priceWrap = $('input.price-low , input.price-high', this.div);
		InstantValidator.validate(priceWrap, 'price');
	},

	initFolding: function() {
		var div = this.div,
			pathAndCat = $('div.wp-cat-path,div.wp-category-nav-unit', div),
			folding = $('a.offer-list-folding', div);
			
		folding.toggle(function() {
			pathAndCat.css('display', 'none');
			$(this).addClass('plus').removeClass('minus');
			return false;
		}, function() {
			pathAndCat.css('display', 'block');
			$(this).removeClass('plus').addClass('minus');
			return false;
		});
	},
	
	initFilters: function() {
		var viewSetting = $("div.wp-offerlist-view-setting", this.div);
		Offers.initFiltersPanel(viewSetting);
	},
	
	initPaging: function() {
		var paging = $('div.wp-paging-unit', this.div);
		new Paging(paging);
	}
};


WP.ModContext.register('wp-all-offer-column', AllOfferColumn);


})(jQuery, Platform.winport);
//~
