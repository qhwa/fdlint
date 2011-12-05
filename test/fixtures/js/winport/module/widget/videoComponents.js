/*
* 视频插入通用组件
* 获取视频数据
* @param {url,callback}  url视频请求地址 callback回调
* @author deming.wei
*/
(function($, WP) {
var VasVideoData = function(){
	}
	VasVideoData.prototype = {
		// TOOD rename
		RequestData:function(url,callback){
		jQuery.ajax({
				url:url+"?t="+new Date().getTime(),
				dataType:'script',
				type:'get',
				complete:function(){
					callback && callback(window.resultdata);
				},
				error: function(){
				}
			});
		 
		}
	}
var VasVideoDataList = new VasVideoData();
/**
 * 视频插入通用组件
 * @param {num}  视频展示个数
 * @param {url}  视频请求地址
 * @param {data} 视频数据
 * @param {type} 已经视频数据类型 id,vid(Default)
 * @param {videoUsed}  已经使用视频videoUsed
 * @param  组件存放路径Platform.winport.widget
*/
	var InsertVideo = function(obj){
		this.init.apply(this, arguments);
	};
	InsertVideo.prototype={
		init:function(obj){
			var SELF = this;

			this.num = obj.num;
			this.data = obj.data;
			if(obj.type == "id"){
				this.type = 2;
			}else{
				this.type = "" ;
			}

			this.videoUsed = obj.videoUsed;
			this.insert =obj.insert

			function a(c){
				SELF.data = c;
				SELF._init();
			};
			this.data.RequestData(this.data.config.url,a);

		},
		_init:function(data){
			var SELF = this;
			var videoList = this.data;
			if(videoList.isSuccess=="true"){
				SELF.VideoRender(videoList);
			}else{
				alert(videoList.data.message);
			}
			},
		bind:function(){
			var SELF = this;
			$('.vas_videoComponents_insert').bind('click',function(){
				if(this.getAttribute("Status") == "refused"||this.innerHTML == "已插入视频"){
					return false;
				} else {
					if(SELF.insertVideo(this.getAttribute("vid"+SELF.type))){
						SELF.insert(SELF.insertVideo(this.getAttribute("vid"+SELF.type)));
					}
				}
			});
			$(".vas_videoComponents_myvideo_video").bind('mouseover',function(){
				$(this).addClass('vas_videoComponents_bg');
			});
			$(".vas_videoComponents_myvideo_video").bind('mouseout',function(e){
				var e = e || window.event, relatedTarget = e.toElement || e.relatedTarget;
				while(relatedTarget && relatedTarget != this)
					relatedTarget = relatedTarget.parentNode;
				if(!relatedTarget){
					$(this).removeClass('vas_videoComponents_bg');
				}
			});
		},
		insertVideo:function(vid){
			var SELF = this;
			var EL = $('.vas_videoComponents_insert'),
				EL2 = $('.vas_videoComponents_myvideo_video');
			for (i = 0 ; i<EL.length; i++){
				EL[i].innerHTML = $(EL[i]).attr("vid"+SELF.type)==vid?"已插入视频":$(EL[i]).attr("Status")=="refused"?"":"插入视频";
				if(EL[i].innerHTML == "已插入视频"){
					var a = SELF.data.data[i];
					$(EL2[i]).addClass("vas_videoComponentsbg");
				}else{
					if(EL[i].innerHTML == ""){
						$(EL[i]).addClass("vas_videoComponentbg2");
					}
					$(EL2[i]).removeClass("vas_videoComponentsbg");
				}
			}
			return a;
		},
/**
 * 视频插入通用组件（根据视频审核状态输出）
 * @param {approved}
 * approved:成功 init:审核中 refused:审核失败
*/
		checkapproved:function(approved){
			var a = [];
			if(approved.auditStatus=="approved"){
				a.push('<li>');
				a.push('<object id="video_player" type="application/x-shockwave-flash" data="http://player.ku6.com/refer/'+approved.videoInfo.id+'/v.swf&amp;auto=0&amp;deflogo=0&amp;adss=0&amp;jump=0&amp;fu=1&amp;recommend=0" height="194" width="200">');
				a.push('<!--[if lt IE 9.0]><param name="movie" value="http://player.ku6.com/refer/'+approved.videoInfo.id+'/v.swf&amp;auto=0&amp;deflogo=0&amp;adss=0&amp;jump=0&amp;fu=1&amp;recommend=0"><![endif]-->');
				a.push('<param name="quality" value="high">');
				a.push('<param name="allowScriptAccess" value="always">');
				a.push('<param name="allowFullScreen" value="true">');
				a.push('<param name="wMode" value="Transparent">');
				a.push('<param name="swLiveConnect" value="true">');
				a.push('<param name="flashvars" value="">');
				a.push('<video controls height="194" width="200" src="http://v.ku6.com/fetchwebm/'+approved.videoInfo.id+'.m3u8"></video>');
				a.push('</object></li>')
			}else{
				a.push('<li style=" position:relative">');
				a.push('<img src="http://img.s.aliimg.com/vaspool/video/images/pic_01.jpg" width="200" height="194" />');
				a.push('<ul class="vas_videoComponents_fail clearFix">');
				if(approved.auditStatus=="init"){
				a.push('<li class="vas_videoComponents_failicon1"></li>');
				a.push('<li class="vas_videoComponents_failmsg">视频审核中...<br />完成后会自动显示</li>');
				}else if(approved.auditStatus=="refused"){
				a.push('<li class="vas_videoComponents_failicon"></li>');
				a.push('<li class="vas_videoComponents_failmsg">视频'+approved.refuseMessage+'<br />审核不通过</li>');
				}
				a.push('</ul></li>')
			}
			return a.join('')
		},
		VideoRender:function(videoList){
			var SELF = this;
			var b = [];
				b.push('<div class="vas_videoComponents_myvideo">');
				b.push('<div class="vas_videoComponents_myvideo_T clearFix">');
				b.push('<h2>我的视频</h2><h2 class="vas_videoComponents_myvideo_C">');
				b.push('<p>你最多可以上传<span class="vas_videoComponents_myvideo_N">'+this.num+'</span>个视频，已上传<span class="vas_videoComponents_myvideo_N" id="offervideoNum">'+videoList.data.length+'</span>个视频</p>');
				b.push('<span class="vas_videoComponents_check"><a href="'+this.data.basePath+'" target="_blank" id="offer_video_upload">上传视频</a></span>');
				b.push('</h2></div>');
			if(videoList.data==undefined||resultdata.data.length==0){
			//无视频数据
				b.push('<div class="vas_videoComponents_myvideo_videoList clearFix">');
				b.push('<p class="vas_videoComponents_myvideo_novideo">你还没有上传视频，请点击进入<a href="'+this.data.basePath+'" target="_blank" style="color:#ff7300;">视频中心</a>，上传视频</p></div>');
			}else{
			//有视频数据
				b.push('<div class="vas_videoComponents_myvideo_trip clearFix" id="offer_Tips">');
				b.push('<p>温馨提示：可插入审核中的视频，视频审核通过后，在插入的页面上自动展示。</p>');
				b.push('</div><div class="vas_videoComponents_myvideo_videoList clearFix">');
				for(var i = 0;i<videoList.data.length; i++){
					b.push('<div class="vas_videoComponents_myvideo_video"><ul>');
					b.push(SELF.checkapproved(videoList.data[i]));
					b.push('<li class="vas_videoComponents_myvideo_videoName">'+resultdata.data[i].fileName+'</li>');
					b.push('<li class="vas_videoComponents_myvideo_videoRevise">');
					b.push('<a href="javascript:void(0);" class="vas_videoComponents_insert" hidefocus="true" Status="'+videoList.data[i].auditStatus+'" vid="'+resultdata.data[i].videoInfo.id+'" vid2="'+resultdata.data[i].id+'">插入视频</a>');
					b.push('</li></ul></div>');
				}
			}
			b.push('</div></div>');
			$('#vas_videoComponents_wrap').html(b.join(''));
			SELF.insertVideo(SELF.videoUsed);
			this.bind();
		}
	}

WP.widget.InsertVideo = InsertVideo;
WP.widget.VasVideoDataList = VasVideoDataList;

})(jQuery, Platform.winport);
