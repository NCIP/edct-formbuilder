var XFORMS_SUBMIT_CSS_CLASS = 'xforms-submit';
var XFORMS_TRIGGER_CSS_CLASS = 'xforms-trigger';

function clearBeforeUnloadMsg(){
	window.onbeforeunload = null;
}

function setBeforeUnloadMsg(){
	window.onbeforeunload = beforeLeave;
}

function beforeLeave() {
	return 'Navigating away from this screen will cause any changes to be lost. You can click on \'Save for Later\' at the bottom of the form page before trying to navigate away.';
}

function hasCSSClass( targetElm, targetClass ) {
	var obj = targetElm.parentNode;
	while ( obj ) {
		var cssClass = obj.className;
		if ( cssClass && cssClass.toLowerCase().match(targetClass)) {
			return true;
		}
		obj = obj.parentNode;
	}
	return false;
}

document.onclick = function(e) {
	var target = getEventTarget(e);
	if ( target && 
	     (target.tagName.toLowerCase() == 'button' &&
	     hasCSSClass(target,XFORMS_SUBMIT_CSS_CLASS)) ||
	     hasCSSClass(target,XFORMS_TRIGGER_CSS_CLASS) ||
	     target.tagName.toLowerCase() == 'a') {
		clearBeforeUnloadMsg();
	} 
}

function getEventTarget(e) {
	var targetElm;
	if (!e) var e = window.event;
	if (e.target) targetElm = e.target;
	else if (e.srcElement) targetElm = e.srcElement;
	if ( targetElm && targetElm.nodeType == 3 )
		targetElm = targetElm.parentNode;
	return targetElm;
}

setBeforeUnloadMsg(); 