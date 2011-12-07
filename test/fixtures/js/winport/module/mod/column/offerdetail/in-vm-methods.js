/**
 * @fileoverview 在原有offerdetail中的js
 * 
 * @author long.fanl
 */
//在图片部分使用，onerror事件
function reloadPic(id) {
	var imgObj = document.getElementById(id);
	imgObj.style.display = "none";
}

function changeImg(obj,width,height) {
	if ( obj.width > width || obj.height > height ) {
	  var scale;
	  var scale1 = obj.width / width;
	  var scale2 = obj.height / height;
	
	  if(scale1 > scale2){
	    scale = scale1;
	  }else{
	    scale = scale2;
	  }
	
	  obj.height = obj.height / scale;
	}
}

// 原kylin js.vm中方法..没想到被detail的resizeImgForDetail使用了..
function resizeImage(img,w,h) {
	img.removeAttribute("width");
	img.removeAttribute("height");
	var pic;
	if(window.ActiveXObject) {
	    var pic=new Image();
	    pic.src=img.src;
	} else pic=img;
	if(pic&&pic.width&&pic.height&&w) {
	    if(!h) h=w;
	    if(pic.width>w||pic.height>h) {
	        var scale=pic.width/pic.height,fit=scale>=w/h;
	        if(window.ActiveXObject) img=img.style;
	        img[fit?'width':'height']=fit?w:h;
	        if(window.ActiveXObject) img[fit?'height':'width']=(fit?w:h)*(fit?1/scale:scale);
	    }
	}
}
/*
function feedbackTraceLog(obj,sourceType,traceLog){
	var domainType = "";
	#if($!isTopDomain && "Y" == "$!isTopDomain")
		domainType = "www";
	#end
	feedback_contacttrace(obj,'?toid=$!{toId}&fromid=$!{fromId}&sourcetype='+sourceType+'&domainType='+domainType);
    return aliclick(obj,traceLog);
}

function ppcallFeedbackLog(obj, sourceType, catId) {
	var queryParams = '?toid=$!{toId}&fromid=$!{fromId}&sourcetype='+sourceType;
	if (catId) queryParams += '&categoryId=' + catId;
	#if($!isTopDomain && "Y" == "$!isTopDomain")
		queryParams +='&domainType=www';
	#end
	return feedback_contacttrace(obj, queryParams);
}*/

/**
    用于打点记录tracelog   
*/
/*
function logStatInfo(obj, param){
    d = new Date();
    if(document.images) {
		var domainType = "";
		//顶级域名
		#if($!isTopDomain && "Y" == "$!isTopDomain")
			domainType = "www";
		#end
		var cosite = "";
		try{ 
	        cosite = document.cookie.match(/track_cookie[^;]*cosite=(\w+)/)[1]; 
	    }catch(e){}

		var digurl = "http://stat.china.alibaba.com/feedback/click.html";
	    if(cosite.length > 0){
	 		    param = param + "&fromsite=" + cosite;
		    }
		if(domainType.length > 0){
	 		    param = param + "&domainType=" + domainType;
		    }
		
		logurl =digurl + param + "&time=" + d.getTime();
		try{
			(new Image()).src = logurl;
		}catch(e){}
    }
    return true;
}*/

/**
 打点记录tracelog的包装方法
 param toid        接收方的会员id
 param categoryId  类目id
 param fromid      发送方的会员id
 param sourcetype  源类型
 param tracelog    tracelog
*/
/*
function traceParrotStatLog(obj, type, toid, sourcetype){
    var param = "";
	param = param + "?type=" + type;
	param = param + "&sourcetype=" + sourcetype;
	param = param + "&toid=" + toid;
	memberLevel = "";
	#if($stringUtil.isNotBlank("$!{memberLevel}"))
		#if($stringUtil.equals("$!{memberLevel}", "PM"))
			memberLevel = "PM";
		#else
			memberLevel = "common";
		#end
	#end
	param = param + "&memberLevel=" + memberLevel;
	logStatInfo(obj, param);
	return true;
}*/

/**
     param toId        seller memberId
     param offerId     offer id
     param sourceUrl   offer detail url
    */
	/*
function traceXunpanLog(obj, toId, offerId, sourceUrl){
    #if($!isTopDomain && "Y" == "$!isTopDomain")
        xunpanInfo(obj, "true", "$!requestUrl", toId, offerId, sourceUrl);
    #else
        xunpanInfo(obj, "false", "", toId, offerId, sourceUrl);
    #end
}*/