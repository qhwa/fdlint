/**
 * @fileoverview 您可能感兴趣(侧边栏广告位)
 * @see http://b2b-doc.alibaba-inc.com/pages/viewpage.action?pageId=45015978
 * 
 * @author qijun.weiqj
 */
(function($, WP){

var Util = WP.Util,
	UI = WP.UI,
	TraceLog = WP.widget.TraceLog;
	

var RecAdvertisement = Util.mkclass({
	
	template: 
		'<ul class="offer-list-sub">\
			<% jQuery.each(offers, function(index, offer) { %>\
			<li <% if (index === offers.length - 1) { %>class="last" <% } %>>\
				<div class="image"><a href="<%= offer.url %>" title="<%= offer.title %>" target="_blank"><img src="<%= offer.img %>" alt="<%= offer.title %>" width="64" height="64" /></a></div>\
				<div class="title"><a href="<%= offer.url %>" title="<%= offer.title %>" target="_blank"><%= offer.shortTitle %></a></div>\
				<% if (offer.price) { %><div class="price"><span class="cny">&yen;</span> <em><%= offer.price %></em></div><% } %>\
			</li>\
			<% }); %>\
		 </ul>',
	
	init: function(div, config){
        this.div = div;
        this.config = config;
		
		var url = config.requestUrl,
			type = config.requestType || 'default',
			action = RecAdvertisement.Action[type];
			
		action.request(url, $.proxy(this, 'render'));
    },
	
	render: function(offers) {
		var self = this;
		
		this.filter(offers);
		
		UI.sweetTemplate($('div.m-content', this.div), this.template, {
        	offers: offers
        }, function() {
			self.afterRender(offers);
		});	
	},
    
    filter: function(offers){
        var self = this,
			noImg = 'http://img.china.alibaba.com/images/app/winport/layout/sidebar/nopic_64.gif';
			
        $.each(offers, function(i, offer){
			offer.title = $.util.escapeHTML(offer.title);
			offer.shortTitle = self.formatTitle(offer.title);
        });
    },
	
	formatTitle: function(title) {
		return Util.lenB(title) > 42 ? Util.cut(title, 40) + '..' : title;
	},
    
    afterRender: function(offers){
        var imgs = $('div.image img', this.div);
        UI.resizeImage(imgs, 64);

		$('li', this.div).each(function(index) {
			$(this).data('offer', offers[index]);
		});
		
		this.handleClickTrace();
		this.handleExposureTrace(offers);
    },
	
	handleClickTrace: function() {
		var self = this,
			page = RecUtil.getPageParams();
		new TraceLog('li div.image,li div.title a', {
			delegate: this.div,
			url: 'http://stat.china.alibaba.com/bt/1688_click.html',
			param: function(elm) {
				var item = $(elm).closest('li').data('offer') || {};
				return {
					page: 		32, // same as ctr_type, which is 32 in free wp
					pid:		page.pid,
					objectId: 	item.id,
					recId: 		page.recid,
					alg: 		item.alg || 0,
					objectType: 'offer',
					st_page_id: page.pageid,
					ver: 		30, // default 30
					time: 		$.now()
				}
			}
		});
	},
	
	handleExposureTrace: function(offers) {
		var page = RecUtil.getPageParams(),
			objectIds = $.map(offers, function(item) {
	            return item.id + ',' + (item.alg || 0);
	        }).join(';');
		
		new TraceLog(this.div, {
			when: 'exposure',
			url: 'http://ctr.china.alibaba.com/ctr.html',
			param: {
				ctr_type:       32,
	            page_area:      page.recid,
	            page_id:        page.pageid,
	            category_id:    '',
	            object_type:    'offer',
	            object_ids:     objectIds,
	            keyword:        '',
	            page_size:      '',
	            page_no:        '',
	            time:           $.now()
			}
		});
	}
	
});
//~ RecAdvertisement


RecAdvertisement.Action = {};

RecAdvertisement.Action['default'] = {
	
	request: function(url, success) {
		var self = this,
			params = this.getParams();
		
		$.ajax(url, {
	        dataType: 'jsonp',
	        data: params,
			success: function(ret) {
				var ret = ret.data || {};
		        if (ret.returnCode !== 0) {
		            $.log('error: ' + ret.returnMsg);
		            return;
		        }
				success(self.filter(ret.data));
			}
	    });
	},
	
	getParams: function() {
		var page = RecUtil.getPageParams();
		return {
			uid: page.uid,
			recid: page.recid,
			pageid: page.pageid,
			memberid: page.memberId,
			querywords: this.getQueryWords()
		};
	},

	/**
	 * 取得30分钟内最近的搜索词
	 */
	getQueryWords: function() {
		var date = this.getLastSearchDate(),
			span = null,
			query = null;
		if (!date) {
			return;
		}

		span = (new Date()).getTime() - date.getTime();
		if (span < 30 * 60 * 1000) { // 30 min
			query = ($.util.cookie('h_keys', false, { raw: true }) || '').split('#')[0];
			return query && unescape(query);
		}
	},

	/**
	 * 取得最后一次搜索时间
	 */
	getLastSearchDate: function() {
		var date = $.util.cookie('ad_prefer'),
			re = /(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+)/,
			match = null,
			span = null;
		if (!date || !(match = re.exec(date))) {
			return;
		}

		date = new Date();
		date.setFullYear(match[1], parseInt(match[2], 10) - 1, match[3]);
		date.setHours(match[4], match[5], match[6]);
		return date;
	},
	
	filter: function(offers){
        var self = this,
			noImg = 'http://img.china.alibaba.com/images/app/winport/layout/sidebar/nopic_64.gif';
			
		return $.map(offers, function(offer) {
			return {
				id: offer.offerId,
				url: offer.eURL || offer.offerDetailUrl,
				img: offer.offerImageUrl ? offer.offerImageUrl + '.summ.jpg' : noImg,
				title: offer.subject,
				price: offer.rmbPrice ? parseFloat(offer.rmbPrice).toFixed(2) : '',
				alg: offer.alg
			};
		});
    }
};


RecAdvertisement.Action['p4p'] = {
	
	request: function(url, success) {
		var self = this,
			params = this._getParams();
		
		$.ajax(url, {
			data: params,
			dataType: 'script',
			success: function() {
				var offers = window.p4pOffers;
		        if (!offers) {
		            return; // error
		        }
				offers = self._filter(offers);
		        success(offers);
			}
		});
	},
	
	_getParams: function() {
		var page = RecUtil.getPageParams(),
			detail = page.detail || {},
			dcatid = detail.dcatid || 3; // 如果类目dcatid为空, 则使用服装类目的dcatid 3代替
			
		if (detail.parentdcatid) {
			dcatid = dcatid + ',' + detail.parentdcatid + ',' + dcatid;
		}
		return {
			count: 5,
			offset:	5,
			pid: page.pid,
			p4p: 'p4pOffers',
			mt: 'ec',
			dcatid: dcatid,
			pageid: page.pageid,
			t: (new Date()).getTime()
        };
	},
	
	_filter: function(offers) {
		return $.map(offers, function(offer) {
			return {
				id: offer.RESOURCEID,
				url: offer.EURL || offer.CLICKURL,
				img: offer.OFFERIMGURL,
				title: offer.TITLE,
				price: $.trim('' + offer.OFFERPRICE)
			};
		});
	}
	
};


var RecUtil = {
	
	getPageParams: function() {
		var detail = window.iDetailConfig,
			memberId = $('#doc').data('docConfig').uid;
		return {
			detail: detail,
			uid: FE.util.loginId || -1,
			recid: detail ? 1030 : 1110,
			pageid: window.dmtrack_pageid,
			pid: detail ? '819095_1008' : '819094_1008',
			memberId: memberId
		}
	}
	
};

WP.ModContext.register('wp-rec-advertisement', RecAdvertisement);
    
})(jQuery, Platform.winport);
//~


