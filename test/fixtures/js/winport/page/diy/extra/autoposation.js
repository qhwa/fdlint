/**
 * 自动定位编辑板块，添加板块
 * 
 * @author deming.wei
*/


(function($,WP){
		  
		  
var autoposation = function(){
		this.init(this.param());   
	}
	
autoposation.prototype={
	init:function(config){
		this.config = config;
		this.render();
	},
	render:function(){
		var SELF = this,
			operate = SELF.config;
		if(operate&&operate.widgetop === "edit"){
			SELF.edit();
		}else if(operate&&operate.widgetop === "add"){
			SELF.add();
		}else{
			return false;
		}
	},
	add:function(){
		var SELF = this;
		SELF.addOperate();
		var segment = $('.segment');
		
		$.each(segment,function(i,n){
			var region = $(n).attr('data-segment-config'),
				regioncid = $.parseJSON(region).cid;
			if(regioncid === SELF.addOperate){
				
				if(SELF.addOperate === "TOP"){
					SELF.doadd($(this).find('div.region'));
				}else if(SELF.addOperate === "CONTENT"){
					
					SELF.addRegion(this)
				}
			}
		});
	},
	doadd:function(region){
		var SELF = this,
			index = SELF.addIndex();
		new WP.diy.ModListDialog(region, -1, {
			success: function(dialog) {
				var node = dialog.node,
					tabs = $('ul.mod-tabs li', node),
					lab = index[0];
					if(0<lab&&lab<=tabs.length){
						lab = lab -1;
					}else{
						lab = 0;
					}
				tabs.eq(lab).click();
				
				var group = $('div.mod-list-group', node).eq(lab),
					grouplab = $('ul.group-tabs li', group),
					glab = index[1];
					if(0<glab&&glab<=grouplab.length){
						glab = glab-1;
					}else{
						glab = 0;
					}
					grouplab.eq(glab).click();
			}
		});
	},
	addOperate:function(){
		var SELF = this;
		if(SELF.config&&SELF.config.region){
			var site = SELF.config.region;
			if(site === "head"){
				SELF.addOperate = "TOP";
			}else if(site === "side" || site === "main"){
				SELF.addOperate = "CONTENT";
			}
		}
	},
	addRegion:function(elm){
		var SELF = this,
			cid = $(elm).find('div.region');
		$.each(cid,function(i,n){
			var data = $(n).attr('data-region-config'),
				josndata = $.parseJSON(data).cid,
				_region = SELF.config.region,
				site = _region.toLocaleUpperCase();
			if( josndata === site){
				
				SELF.doadd($(this));
			}
		});
	},
	addIndex:function(){
		var SELF = this;
		var config = SELF.config;
		if(config&&config.widgetlevel){
			var level = config.widgetlevel,
				index = level.split('-');
				return(index);
		}
	},
	edit:function(){
		var SELF = this;
		var editbox = $($('.mod-box'));
		$.each(editbox,function(i,n){
			var data = $(n).attr('data-box-config'),
				josndata = $.parseJSON(data).cid;
			if(SELF.config&&josndata === SELF.config.widgetid){
				
				var elm = editbox.eq(i),
					wHeight = $(window).height(),
					eTop = elm.offset().top;
				if(wHeight/2 >= eTop){
					
					$(document).scrollTop(0);
				}else if(eTop <=wHeight){
					
					$(document).scrollTop(eTop-(wHeight/2));
				}else{
					$(document).scrollTop(eTop-((wHeight-300)/2));
				}
				WP.diy.ModBox.edit(elm)
				return false;
			}
		})
	},
	param:function(){
		var pam = window.location.hash;
		str = pam.replace('#','').split('&');
		var b = [];
		b.push('{');
		$.each(str,function(i,n){
			if(i === 0){
				b.push('"'+n.replace('=','":"')+'"');
			}else{
				b.push(',"'+n.replace('=','":"')+'"');
			}
		})
		b.push('}');
		if(b.join('')==='{""}'){
			return false;
		}else{
			var cid = $.parseJSON(b.join(''));
			return cid;
		}
	}
}
$(function($){
	new autoposation();
});
})(jQuery,Platform.winport);

