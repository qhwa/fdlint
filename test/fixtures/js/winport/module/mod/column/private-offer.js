/**
 * @fileoverview 二级栏目页 会员专区 ,和供应产品二级栏目页大部分一样..
 *
 * @author long.fanl
 */
(function($, WP){

var InstantValidator = WP.widget.InstantValidator,
	WPAlitalk = WP.mod.unit.WPAlitalk,
	Paging = WP.mod.unit.Paging,
	Offers = WP.mod.unit.Offers;


var PrivateOffer = {
	
	init: function(div, config) {
		this.div = div;
		
		this.initAlitalk();
		this.initFolding();
		this.initApplyForm();
		this.initFilters();
		this.initPaging();
	},
	
	initAlitalk: function() {
		var alitalk = $('a[data-alitalk]', this.div);
		WPAlitalk.init(alitalk);
    },

    initFolding: function() {
        var div = this.div,
			pathAndCat = $('div.wp-cat-path,div.wp-category-nav-unit', div),
			folding = $('a.offer-list-folding', div);
			
        folding.toggle(function() {
            pathAndCat.css('display', 'none');
            $(this).addClass('plus').removeClass('minus');
        }, function() {
            pathAndCat.css('display', 'block');
            $(this).removeClass('plus').addClass('minus');
        });
    },
	
	initApplyForm: function() {
		var form = $('form.winport-apply-partner-form', this.div);
		$('a.apply-partner', this.div).click(function(){
            form.submit();
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


WP.ModContext.register('wp-private-offer-column', PrivateOffer);


})(jQuery, Platform.winport);
