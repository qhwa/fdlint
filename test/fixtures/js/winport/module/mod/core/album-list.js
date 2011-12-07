/**
 * @fileoverview 推荐相册板块
 * 
 * @author long.fanl
 */
(function($, WP) {
	
	var UI = WP.UI,
		Util = WP.Util,
		isIE67=$.util.ua.ie67,
		Paging = WP.widget.Paging,
		NO_PHOTO_PIC_150,
		NO_PHOTO_PIC_64,
		NO_COVER_PIC_150,
		NO_COVER_PIC_64,
		LOCK_PIC_150,
		LOCK_PIC_64,
		uid,
		recommendAlbumListUrl,
		albumTemplate = null,
		albumLink = null,
		imageServer = null,
		linkUrl,
		unionData = [];  // 回调变量名称
	
	
	function BaseAlbumMod() {
		this.init.apply(this, arguments);
	}
	
	BaseAlbumMod.prototype = {
		init : function(context,config, inrefresh){
			this.context = context;
			this.config = config;
			this.inMainRegion = $(context).closest("div.region").hasClass("main-wrap");
			var self = this,
				content = $("div.m-content",context);
				
			UI.showLoading(content);
			unionData.push({
				context: context,
				config: config,
				callback: function(albumsJson){
					if (albumsJson.result === "success") {
						if (albumsJson.dataList[config.albumName].length === 0) {
							showEmpty(content);
							return;
						}
						self.renderAlbumList(albumsJson);
						// 如果不在主区域，需要缩略
						if (!self.inMainRegion) {
							resizeSubAlbums(context);
						}
						// 解决DIY后台拖拽/移动时的resize bug
						if (isIE67) {
							var box = $(context).closest("div.mod-box");
							$("div.box-shim", box).height(box.height() - 8);
						}
						// 如果需要分页，根据pagesize生成分页
						if (config.needPaging) {
							// 第一次请求 必然是第一页
							$("ul.album-list-main",context).addClass("album-page-1");
							self.pagingAlbumList(albumsJson, config.pageSize, context);
						}
					}else {
						showError(content);
					}
				},
				error: function(){
					showError(content);
				}
			});

			inrefresh && loadAlbums();
		},
		
		// 渲染相册列表
		renderAlbumList : function(albumsJson){
			var content = $("div.m-content",this.context),
				albumsData = {},
				end =  this.config.end;
				
			albumsData.albumList = albumsJson.dataList[this.config.albumName];
			
			// end和pageSize必须相等
			if (end) {
				albumsData.albumCount =(albumsData.albumList.length < end) ? albumsData.albumList.length : end;
			} else {
				albumsData.albumCount = albumsData.albumList.length;
			}
			albumsData.inMainRegion = this.inMainRegion;
			albumsData.className = this.inMainRegion ? "album-list-main" : "album-list-sub";
			
			content.html(initAlbumListTemplate(albumsData));
		},
		
		// 为相册栏目页生成分页
		pagingAlbumList: function(albumsJson, pageSize, context){
			var self = this,
				content = $("div.m-content", context);
				modPaging = new Paging(content,{
					css: {
						className: "wp-album-paging"
					},
					pageClick: function(pnum){
						doPaging(pnum, self.context, self.config, self.inMainRegion);
					},
					pageSubmit: function(pnum){
						doPaging(pnum,self.context, self.config, self.inMainRegion);
					}
				});
				
		    modPaging.init(1, pageSize, albumsJson.total);
		}
	};
	
	// 对侧边栏的图片进行缩略
	function resizeSubAlbums(context){
		var imgs = $('div.cover img', context);
		UI.resizeImage(imgs, 64);
	}
	
	// 请求相册列表的某一页
	function doPaging(pageNum, context, config, inMainRegion){
		
		var thePage = $("ul.album-page-"+pageNum,context);
		// 如果thePage已经请求过，直接用
		if(thePage.length > 0){
			$("ul.album-list-main",context).not(thePage).hide();
			thePage.fadeIn("slow");
			return;
		}
		
		var pagingParams = constructPagingParams(config.pageSize, pageNum),
			content = $("div.m-content", context);
		
		$.ajax(recommendAlbumListUrl, {
			type: "GET",
			dataType: "script",
			data : pagingParams,
			success:function(){
				var albumsJson = window[pagingParams.jsResponseDataName];
				// 解决IE下script请求未返回依然会走到success逻辑的问题
				if(!albumsJson){
					showError(content);
					return;
				}
				
				if(albumsJson.result === "success"){
					var albumList = albumsJson.dataList[config.albumName];
					if(albumList.length === 0){
						showEmpty(content);
						return;
					}
					
					var albumListMain = $("ul.album-list-main",context),
						albumsData = {
							albumList: albumList,
							albumCount: albumList.length,
							inMainRegion: inMainRegion,
							className: inMainRegion ? "album-list-main" : "album-list-sub"
						};
					
					var newPage = $(initAlbumListTemplate(albumsData));
					newPage.addClass("album-page-"+pageNum).hide();
					// 保证cache的album节点不超过5个
					if($("ul.album-list-main",context).length >=5){
						$("ul.album-list-main:first",context).remove(); // FIFO
					}
					// 将新album节点插到最后 渐显出来
					$("ul.album-list-main",context).hide();
					$("ul.album-list-main:last",context).after(newPage);
					newPage.fadeIn("slow");
				} else {
					showError(content);
				}
			},
			
			error: function() {
				showError(content);
			}
		});
		return false;
	}
	
	// 构造翻页请求参数
	function constructPagingParams(pageSize, pageNum){
		return {
			memberId: uid,
			jsResponseDataName: "albumList" + new Date().getTime(),
			hasAlbums: true,
			start: (pageNum - 1) * pageSize +1,
			end: pageNum * pageSize
		};
	}
	
	// 初始化相册列表模板
	function initAlbumListTemplate(albumsData){

		return FE.util.sweet(
			'<ul class="<%= className %>">\
				<% for (var i=0; i< albumCount; i++) { %>\
					<% var album = this.initAlbumData(albumList[i]);%>\
					<li>\
						<div class="cover">\
						<% var albumTitle = this.escape(album.title); %>\
							<a target="_blank" href="<%= album.link %>" title="<%= albumTitle %>"><img alt="<%= albumTitle %>" src="<%= album.cover %>"></a>\
							<div class="cover-label"></div>\
						</div>\
						<div class="title">\
							<a target="_blank" title="<%= albumTitle %>" href="<%= album.link %>"><%= $util.escape(album.subTitle) %></a>\
						</div>\
						<div class="count">\
							<%= album.count %>张图片\
						</div>\
					</li>\
				<% } %>\
			</ul>').applyData(albumsData, {
				initAlbumData: albumsData.inMainRegion ? initMainAlbumData: initSubAlbumData,
				escape : Util.escape
			});
	}
	
	// 初始化主区域相册数据
	function initMainAlbumData(album){
		// 相册封面
		album.cover = (album["lock"] === 1) ? LOCK_PIC_150 : // 私密相册 显示“加锁图片“\
								(album["coverId"] !== null) ? album["coverSumm"].replace(".summ.jpg",".search.jpg") : // 主区域显示”150“规格的图片\
								(album["count"] === 0) ? NO_PHOTO_PIC_150 : NO_COVER_PIC_150;// 无封面且无图展示no_photo.gif，无封面但有图展示no_cover.gif\
		
		album.coverWidth = album.coverHeight = 150;
		// 相册链接
		album.link = albumLink.replace("(ALBUM_ID_PLACEHOLDER)",album["id"]);
		album.subTitle = album["title"];
		
		return album;
	}
	
	// 初始化侧边栏相册数据
	function initSubAlbumData(album){
		// 相册封面
		album.cover = (album["lock"] === 1) ? LOCK_PIC_64 : // 私密相册 显示“加锁图片“\
								(album["coverId"] !== null ) ?  album["coverSumm"] : // 侧边栏显示”100“规格的图片（需缩略为64规格）\
								(album["count"] === 0) ? NO_PHOTO_PIC_64 : NO_COVER_PIC_64;// 无封面且无图展示no_photo.gif，无封面但有图展示no_cover.gif\
		
		album.coverWidth = album.coverHeight = 64;
		// 相册链接
		album.link = albumLink.replace("(ALBUM_ID_PLACEHOLDER)",album["id"]);
		// 侧边栏截取相册标题（42个字符 共3行）
		var title = album["title"];
		album.subTitle = (Util.lenB(title) > 42) ? (Util.cut(title,40)+"..") : title;
		
		return album;
	}
	
	// 当页面所有mod准备完毕后，在一个请求中取相册列表的数据
	WP.ModContext.bind('nodeallready', loadAlbums);
	
	// 当页面所有mod准备完毕后，在一个请求中取相册列表的数据
	function loadAlbums() {
		if(unionData.length <= 0){
			return;
		}
		initGlobalParams(unionData[0].config);
		
		var unionParams = constructUnionParams();
		$.ajax(recommendAlbumListUrl,{
			type:"GET",
			dataType:"script",
			timeout: 20000,
			data : unionParams,
			success:function(){
				var albumsJson = window[unionParams.jsResponseDataName];
				// 解决IE下script请求未返回依然会走到success逻辑的问题
				if(!albumsJson){
					$.each(unionData, function(i,data){
						data.error();
					});
					return;
				}
				$.each(unionData, function(i,data){
					data.callback(albumsJson);
				});
				unionData = [];
			},
			
			error: function() {
				$.each(unionData, function(i, data){
					data.error();
				});
			}
		});
	}
	
	function initGlobalParams(config){
		var docCfg = $("#doc").data("doc-config");
		
		albumLink = config.albumLink;
		recommendAlbumListUrl = config.recommendAlbumListUrl;
		imageServer = docCfg.imageServer;
		uid = docCfg.uid;
		
		NO_PHOTO_PIC_150 = NO_PHOTO_PIC_150  ? NO_PHOTO_PIC_150 : imageServer+"/images/app/platform/winport/mod/albums/no-photo-150.gif";
		NO_PHOTO_PIC_64 = NO_PHOTO_PIC_64  ? NO_PHOTO_PIC_64 : imageServer+"/images/app/platform/winport/mod/albums/no-photo-64.gif";
		NO_COVER_PIC_150 = NO_COVER_PIC_150  ? NO_COVER_PIC_150 : imageServer+"/images/app/platform/winport/mod/albums/no-cover-150.gif";
		NO_COVER_PIC_64 = NO_COVER_PIC_64  ? NO_COVER_PIC_64 : imageServer+"/images/app/platform/winport/mod/albums/no-cover-64.gif";
		LOCK_PIC_150 = LOCK_PIC_150  ? LOCK_PIC_150 : imageServer+"/images/app/platform/winport/mod/albums/lock-150.gif";
		LOCK_PIC_64 = LOCK_PIC_64  ? LOCK_PIC_64 : imageServer+"/images/app/platform/winport/mod/albums/lock-64.gif";
	}
	
	// 构造联合请求参数
	function constructUnionParams(){
		var maxAlbumsCount = 0,
			params = {
				memberId: uid,
				jsResponseDataName: "albumList"+new Date().getTime()
			};
		
		$.each(unionData,function(i, data) {
			var cfg = data.config;
			
			if (cfg.hasRecAlbums) {
				params.hasRecAlbums = true;
				params.recommendAlbumIds = cfg.recommendAlbumIds; // 推荐相册目前都一样
			}
			if (cfg.hasAlbums) {
				params.hasAlbums = true;
				params.start = 1;
				if (cfg.end > maxAlbumsCount) {
					maxAlbumsCount = params.end = cfg.end; // 只需记录最大的相册数量
				}
			}
		});
		return params;
	}
		
	// 显示暂无相册文案
	function showEmpty(content){
		content.html('<p class="empty-album">暂无相册</p>');
	}
	// 显示异常信息
	function showError(content){
		content.html('<p class="album-error">网络繁忙，请刷新后重试</p>');
	}
	
	/**
	 * 相册列表板块
	 */
	WP.ModContext.register('wp-albums',BaseAlbumMod);
	
	/**
	 * 推荐相册板块
	 */
	WP.ModContext.register('wp-recommend-albums',BaseAlbumMod);
	
	/**
	 * 相册列表栏目页主板块
	 */
	WP.ModContext.register('wp-albums-column',BaseAlbumMod);
	
})(jQuery, Platform.winport);
//~
