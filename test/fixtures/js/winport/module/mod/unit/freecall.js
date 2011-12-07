/**
* 商务号码布点
* @param {Object|Array} els 单个callme节点或者callme节点数组 
* @param {Object} opts
* @author:chuangui.xiecg
* @date:2010-10-15
* @update Denis 2011.03.22 移植到旺工厂
*/
(function (w) {
    var L=YAHOO.lang;
    w.CallMe=function (els,opts) {
        if(els&&els.length&&els.length==0) return;
        if(els&&els.nodeType) els=[els];
        this.init(els,opts);
    };
    /*默认配置*/
    w.CallMe.defaults={
        apiUrl: "http://vas.china.alibaba.com/callme/permission/isAllow.do",
        callmepage: 'http://vas.china.alibaba.com/callme/webcall/index.htm',
        jsonName: 'callmeResult',
        cls: {
            on: 'callme-on'
        },
        height: 350,
        width: 440,
        trace: '',
        timeout: 10000
    };
    L.augmentObject(w.CallMe.prototype,{
        init: function (opts) {
		    var memberIdList=[];
            this.config=w.CallMe.defaults;
            this.opts=[];
			if(opts&&opts.length>0){
				for(var i=0,l = opts.length;i<l;i++){
					if(opts[i].isDataLazy){
						this.opts.push(opts[i]);
						continue;
					}
					if($(opts[i].el)){
						this.opts.push(opts[i]);
					}
				}
			}
           /*for(var i=0,len=this.nodes.length;i<len;i++) {
                o=eval('('+($D.getAttribute(this.nodes[i],'callme')||'{}')+')');
                this.cacheMemberIdList.push(o.id);
                memberIdList.push('m='+o.id);
            }*/
			//直接取页面的全局变量eService,这个变量是给ITU-企业在线使用的
			if(window.eService&&window.eService.adminMemberId){
				memberIdList.push('m='+window.eService.adminMemberId);
			}
            if(memberIdList.length==0) return;
			
			//全局对象已经存在，且记录了页面卖家是否显示“免费电话”的状态,则不必发送请求,直接执行渲染
			if(window.FreePhoneShowState && window.eService.adminMemberId in FreePhoneShowState){
				return this.render();
			}
            var callback={
                onSuccess: this.onSuccess,
                onFailure: this.onFailure,
                onTimeout: this.onTimeout,
                scope: this,
                charset: 'gb2312',
                timeout: this.config.timeout,
                data: {}
            };
            YAHOO.util.Get.script(this.config.apiUrl+'?'+memberIdList.join('&')+'&jsonname='+this.config.jsonName+'&t='+new Date().valueOf(),callback);
        },
        /*请求成功执行的方法*/
        onSuccess: function () {
			var jsonName=this.config.jsonName;
            window.FreePhoneShowState = window.FreePhoneShowState || {};
			// 失败直接返回
			if(!window[jsonName] || !window[jsonName].isSuccess){
				return;
			}
			window.FreePhoneShowState[ window.eService.adminMemberId ] = window[jsonName].data[window.eService.adminMemberId];
			this.render();
        },
		render:function(){
			var that=this,jsonName=this.config.jsonName,tempEl,tempItemObj;
			//给全局变量赋值,与ITU的约定这个变量，他们也会使用这个变量
			if(window.FreePhoneShowState[ window.eService.adminMemberId ]===true) {
				for(var i=0,len=this.opts.length;i<len;i++) {
					if(this.opts[i].isDataLazy===true){
						tempItemObj = that.opts[i];
						if(window.nowTopic) continue;
						$E.onAvailable(tempItemObj.el,function(){
							tempEl = $(tempItemObj.el);
							if(!tempEl) return;
							$D.addClass(tempEl,tempItemObj.cls.on);
							$D.setAttribute(tempEl,'callme','{id:\''+window.eService.adminMemberId+'\'}');
							$E.on(tempEl,'click',function (e) {
								$E.preventDefault(e);
								//如果是旺铺diy状态，链接不可点
								if(window.nowTopic) return;
								that.popwindow(this);
								that.clickTrace(tempItemObj);
							});
						});
					}else{
						tempEl = $(this.opts[i].el);
						tempcomfig = this.opts[i];
						$D.addClass(tempEl,this.opts[i].cls.on);
						$D.setAttribute(tempEl,'callme','{id:\''+window.eService.adminMemberId+'\'}');
						$E.on(tempEl,'click',function (e) {
							$E.preventDefault(e);
							//如果是旺铺diy状态，链接不可点
							that.popwindow(this);
							that.clickTrace(tempcomfig);
						});
					}
                }
            }
		},
        onFailure: function () {
            //to do
        },
        clickTrace: function (config) {
            if(typeof config=='undefined'||config.trace=='') return;
            var param='?tracelog='+config.trace;
            if(typeof window.dmtrack!="undefined") {
                dmtrack.clickstat("http://stat.china.alibaba.com/tracelog/click.html",param);
            } else {
                if(document.images)
                    (new Image()).src="http://stat.china.alibaba.com/tracelog/click.html"+param+"&time="+(+new Date);
            }
        },
        popwindow: function (el) {
            var self=this,o=eval('('+($D.getAttribute(el,'callme')||'{}')+')');
            //如果已存在callme的Dialog
            if(this.dialogId&&$(this.dialogId)) {
                //如果点了其他按钮，则去更新iframe的src
                if(this.memberId!=o.id) {
                    this.memberId=o.id;
                    var iframeNode=FYS('iframe',this.dialogId,true);
                    if(iframeNode) {
                        iframeNode.src=this.opts.callmepage+'?memberId='+o.id+'&iframe_delete=true&t='+new Date().valueOf();
                    }
                }
            } else {
                this.memberId=o.id;
				//Denis:改用新框架
				jQuery.use('ui-dialog',function(){
					var $ = jQuery,
						elem = $(self.create());
					elem.dialog({
						fixed: true,
						center: true,
						fadeIn: 1000,
						css: {
							width: '444px',
							height: '352px'
						},
						before: self.dialogBefore
					});
					$('#callme-dialog-btn').click(function(e){
						e.preventDefault();
						elem.dialog('close');
					});
				});
            }
        },
        /**
        * 浮层展现动画
        */
        dialogBefore: function () {
            //如果当前已打开反馈的收集窗口，则先关闭它
            //window.feedbackClose为feedback提供的对外关闭方法
            if(window.feedbackClose) window.feedbackClose();
        },
        /**
        * 创建callme浮层节点
        * @return {HTMLElement}
        */
        create: function () {
            var dialog=document.createElement('div');
            window.J_callmeDialogId=this.dialogId=dialog.id='DIALOG_'+new Date().valueOf();
            dialog.className='popup-window callme-window';
            var callme=document.createElement('div');
            callme.innerHTML='<div class="callme-mask"></div><div class="popup-window-wrapper">'
			+'<div class="hd"><a class="close-btn" href="#" taget="_self" id="callme-dialog-btn"></a></div>'
			+'<div class="bd"><iframe class="callme-innerpage" scrolling="no" height="'+this.config.height+'" frameborder="0" width="'+this.config.width+'" src="'+this.config.callmepage+'?memberId='+this.memberId+'&iframe_delete=true&t='+new Date().valueOf()+'"></iframe></div>'
			+'</div>';
            //if(YAHOO.env.ua.ie===6) {
                dialog.appendChild(this.getIframe());
            //}
            dialog.appendChild(callme);
            return dialog;
        },
        /**
        * 创建iframe节点
        */
        getIframe: function () {
            var iframeSrc=/^https/i.test(window.location.href||'')?'javascript:false':'about:blank';
            var lyr1=document.createElement('iframe');
            FYD.addClass(lyr1,'callme-mask-ifr');
            FYD.setStyle(lyr1,'border','0 none');
            FYD.setAttribute(lyr1,'src',iframeSrc);
            return lyr1;

        },
        end: 0
    });
})(FD.widget);

FYE.onDOMReady(function () {
    //detail页面的联系方式tab里的免费呼叫
	if(window.eService){
		if($('J_callmeD')) {
			new FD.widget.CallMe([{
				el:'J_callmeD',
				cls: {
					on: 'd-callme-on'
				},trace: 'itu_virtualNumber.offerDetailContact_freeCall_onClick'
			},{
				el:'oWebIM2FreePhoneButton',
				cls:{
					on:''
				},
				isDataLazy:true,
				trace:'jzyx_freephone_click'
			}]);
		}else{
			new FD.widget.CallMe([{
				el:'J_callme',
				cls:{
					on:'callme-on'
				},
				trace: 'itu_virtualNumber.offerDetailContact_freeCall_onClick'
			},{
				el:'oWebIM2FreePhoneButton',
				cls:{
					on:''
				},
				isDataLazy:true,
				trace:'jzyx_freephone_click'
			}]);
		}
	}
});
