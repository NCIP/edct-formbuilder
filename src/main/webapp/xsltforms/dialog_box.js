//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
var Position = (function() {
	// Resolve a string identifier to an object
	// ========================================
	function resolveObject(s) {
		if (document.getElementById && document.getElementById(s)!=null) {
			return document.getElementById(s);
		}
		else if (document.all && document.all[s]!=null) {
			return document.all[s];
		}
		else if (document.anchors && document.anchors.length && document.anchors.length>0 && document.anchors[0].x) {
			for (var i=0; i<document.anchors.length; i++) {
				if (document.anchors[i].name==s) { 
					return document.anchors[i];
				}
			}
		}
	}
	
	var pos = {};
	pos.$VERSION = 1.0;
	
	// Set the position of an object
	// =============================
	pos.set = function(o,left,top) {
		if (typeof(o)=="string") {
			o = resolveObject(o);
		}
		if (o==null || !o.style) {
			return false;
		}
		
		// If the second parameter is an object, it is assumed to be the result of getPosition()
		if (typeof(left)=="object") {
			var pos = left;
			left = pos.left;
			top = pos.top;
		}
		
		o.style.left = left + "px";
		o.style.top = top + "px";
		return true;
	};
	
	// Retrieve the position and size of an object
	// ===========================================
	pos.get = function(o) {
		var fixBrowserQuirks = true;
			// If a string is passed in instead of an object ref, resolve it
		if (typeof(o)=="string") {
			o = resolveObject(o);
		}
		
		if (o==null) {
			return null;
		}
		
		var left = 0;
		var top = 0;
		var width = 0;
		var height = 0;
		var parentNode = null;
		var offsetParent = null;
	
		
		offsetParent = o.offsetParent;
		var originalObject = o;
		var el = o; // "el" will be nodes as we walk up, "o" will be saved for offsetParent references
		while (el.parentNode!=null) {
			el = el.parentNode;
			if (el.offsetParent==null) {
			}
			else {
				var considerScroll = true;
				/*
				In Opera, if parentNode of the first object is scrollable, then offsetLeft/offsetTop already 
				take its scroll position into account. If elements further up the chain are scrollable, their 
				scroll offsets still need to be added in. And for some reason, TR nodes have a scrolltop value
				which must be ignored.
				*/
				if (fixBrowserQuirks && window.opera) {
					if (el==originalObject.parentNode || el.nodeName=="TR") {
						considerScroll = false;
					}
				}
				if (considerScroll) {
					if (el.scrollTop && el.scrollTop>0) {
						top -= el.scrollTop;
					}
					if (el.scrollLeft && el.scrollLeft>0) {
						left -= el.scrollLeft;
					}
				}
			}
			// If this node is also the offsetParent, add on the offsets and reset to the new offsetParent
			if (el == offsetParent) {
				left += o.offsetLeft;
				if (el.clientLeft && el.nodeName!="TABLE") { 
					left += el.clientLeft;
				}
				top += o.offsetTop;
				if (el.clientTop && el.nodeName!="TABLE") {
					top += el.clientTop;
				}
				o = el;
				if (o.offsetParent==null) {
					if (o.offsetLeft) {
						left += o.offsetLeft;
					}
					if (o.offsetTop) {
						top += o.offsetTop;
					}
				}
				offsetParent = o.offsetParent;
			}
		}
		
	
		if (originalObject.offsetWidth) {
			width = originalObject.offsetWidth;
		}
		if (originalObject.offsetHeight) {
			height = originalObject.offsetHeight;
		}
		
		return {'left':left, 'top':top, 'width':width, 'height':height
				};
	};
	
	// Retrieve the position of an object's center point
	// =================================================
	pos.getCenter = function(o) {
		var c = this.get(o);
		if (c==null) { return null; }
		c.left = c.left + (c.width/2);
		c.top = c.top + (c.height/2);
		return c;
	};
	
	return pos;
})();
////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

// global variables //
var TIMER = 5;
var SPEED = 10;
var WRAPPER = 'content';
var CLICKEDELEMENT = null;

// get the target element //
if ( window.captureEvents ) window.captureEvents(Event.CLICK);
window.onclick = handleClick;
function handleClick(e){
	if (!e) e = (event || window.event || document.event);
	CLICKEDELEMENT = (e.target || e.srcElement);
	if ( window.routeEvent ) {
		var rtn = window.routeEvent(e);
		return rtn;
	}
	else return true;
}

function getClickTargetElement() {
	if ( !CLICKEDELEMENT ) { 
		CLICKEDELEMENT = ( event || window.event || window.Event).srcElement;
	}
	return CLICKEDELEMENT;
}

// calculate the current window width //
function pageWidth() {
  return window.innerWidth != null ? window.innerWidth : document.documentElement && document.documentElement.clientWidth ? document.documentElement.clientWidth : document.body != null ? document.body.clientWidth : null;
}

// calculate the current window height //
function pageHeight() {
  return window.innerHeight != null? window.innerHeight : document.documentElement && document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body != null? document.body.clientHeight : null;
}

// calculate the current window vertical offset //
function topPosition() {
  return typeof window.pageYOffset != 'undefined' ? window.pageYOffset : document.documentElement && document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop ? document.body.scrollTop : 0;
}

// calculate the position starting at the left of the window //
function leftPosition() {
  return typeof window.pageXOffset != 'undefined' ? window.pageXOffset : document.documentElement && document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft ? document.body.scrollLeft : 0;
}

// build/show the dialog box, populate the data and call the fadeDialog function //
function showDialog(title,message,type,autohide,objId) {
  if(!type) {
    type = 'error';
  }
  var dialog;
  var dialogheader;
  var dialogclose;
  var dialogtitle;
  var dialogcontent;
  var dialogmask;
  if(!document.getElementById('dialog')) {
    dialog = document.createElement('div');
    dialog.id = 'dialog';
    dialogheader = document.createElement('div');
    dialogheader.id = 'dialog-header';
    dialogtitle = document.createElement('div');
    dialogtitle.id = 'dialog-title';
    dialogclose = document.createElement('div');
    dialogclose.id = 'dialog-close';
    dialogcontent = document.createElement('div');
    dialogcontent.id = 'dialog-content';
    dialogmask = document.createElement('div');
    dialogmask.id = 'dialog-mask';
    document.body.appendChild(dialogmask);
    document.body.appendChild(dialog);
    dialog.appendChild(dialogheader);
    dialogheader.appendChild(dialogtitle);
    dialogheader.appendChild(dialogclose);
    dialog.appendChild(dialogcontent);;
    dialogclose.setAttribute('onclick','hideDialog()');
    dialogclose.onclick = hideDialog;
  } else {
    dialog = document.getElementById('dialog');
    dialogheader = document.getElementById('dialog-header');
    dialogtitle = document.getElementById('dialog-title');
    dialogclose = document.getElementById('dialog-close');
    dialogcontent = document.getElementById('dialog-content');
    dialogmask = document.getElementById('dialog-mask');
    dialogmask.style.visibility = "visible";
    dialog.style.visibility = "visible";
  }
  dialog.style.opacity = 100;
  dialog.style.filter = 'alpha(opacity=100)';
  dialog.alpha = 0;
  var width = pageWidth();
  var height = pageHeight();
  var left = leftPosition();
  var top = topPosition();
  var dialogwidth = dialog.offsetWidth;
  var dialogheight = dialog.offsetHeight;
  //var topposition = top + (height / 3) - (dialogheight / 2);
  var oElm = (parent && parent.document && parent.document.getElementById('xform-iframe')) ?
             parent.document.getElementById('xform-iframe').contentWindow.document.getElementById(objId) :
             document.getElementById(objId);
  var topposition = Position.get(oElm).top;
  var leftposition = left + (width / 2) - (dialogwidth / 2);
  dialog.style.top = topposition + "px";
  dialog.style.left = leftposition + "px";
  dialogheader.className = type + "header";
  dialogtitle.innerHTML = title;
  dialogcontent.className = type;
  dialogcontent.innerHTML = replaceHTMLEntities(message);
  //var content = document.getElementById(WRAPPER);
  var content = document.documentElement ? document.documentElement : document.body;
  dialogmask.style.height = content.offsetHeight + 'px';
  dialog.timer = setInterval("fadeDialog(1)", TIMER);
  if(autohide) {
    dialogclose.style.visibility = "hidden";
    window.setTimeout("hideDialog()", (autohide * 1000));
  } else {
    dialogclose.style.visibility = "visible";
  }
}

// hide the dialog box //
function hideDialog() {
  var dialog = document.getElementById('dialog');
  clearInterval(dialog.timer);
  dialog.timer = setInterval("fadeDialog(0)", TIMER);
}

// fade-in the dialog box //
function fadeDialog(flag) {
  if(flag == null) {
    flag = 1;
  }
  var dialog = document.getElementById('dialog');
  var value;
  if(flag == 1) {
    value = dialog.alpha + SPEED;
  } else {
    value = dialog.alpha - SPEED;
  }
  dialog.alpha = value;
  dialog.style.opacity = (value / 100);
  dialog.style.filter = 'alpha(opacity=' + value + ')';
  if(value >= 99) {
    clearInterval(dialog.timer);
    dialog.timer = null;
  } else if(value <= 1) {
    dialog.style.visibility = "hidden";
    document.getElementById('dialog-mask').style.visibility = "hidden";
    clearInterval(dialog.timer);
  }
}

function replaceHTMLEntities(str) {
	str = str.replace(new RegExp('&amp;','g'),'&');
	str = str.replace(new RegExp('&lt;','g'),'<');
	str = str.replace(new RegExp('&gt;','g'),'>');
	str = str.replace(new RegExp('&quot;','g'),'"');
	str = str.replace(new RegExp('&apos;','g'),'&#39;'); // For IE
	return str;
}