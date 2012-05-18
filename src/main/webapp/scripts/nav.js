// jQuery Animated Dropdowns
// Created by Kevin Becker
// http://www.kevinbecker.name/
// http://www.mindsculpt.net/

$(document).ready(function () {
	
	var startingHeight = 21; // Specifies the height of your navigation when collapsed
	var speed = 300; // Specifies the speed of the animation
	
	var heights = new Array();
	
	var i = 1;
	while ($("#nav"+i).length) {
		heights.push($("#nav"+i).height() + 8);
		$("#nav"+i).height(startingHeight);
		$("#nav"+i).mouseover(function () {
			$(this).stop().animate({height:heights[this.id.substr(3)-1]},{queue:false, duration:speed});
		});
		$("#nav"+i).mouseout(function () {
			$(this).stop().animate({height:startingHeight+'px'},{queue:false, duration:speed});
		});
		i++;
	}
	
	$("#nav ul").css("visibility", "visible");
	
});