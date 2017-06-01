/*------------------------------------------------------------
  javascript for PCC applications that:
    – use Foundation elements and styles in the content area
    – have a very basic PCC-branded header
  author: Gabriel Nagmay, PCC Web Team
  date:   4/25/17
------------------------------------------------------------*/

/* === links to current page === */
function pcc_current_link(){
    var locationPath = filterPath(location.pathname);
    $("#nav a[href]").each(function () {
        var thisPath = filterPath(this.pathname);
        if (locationPath == thisPath && (location.hostname == this.hostname) && !this.href.match(/(\?|#)/)) { // ? eliminates cfm pages like schedule.cfm?var=3
            $(this).addClass('current');
        }
    });
}
function filterPath(string) { // used in current link
    return string
        .replace(/^\//, '')
        .replace(/(index|default).[a-zA-Z]{3,4}$/, '')
        .replace(/\/$/, '');
}


/* === responsive tables === */
function pcc_tables() {
    // are there tables?
	if ($("#content table")[0]){
        pcc_table_responsive();
    }
}

function pcc_table_responsive(){
    // Setup; fire on scroll
	$('table').wrap('<div class="table"></div>').after('<div class="shadow-left" /><div class="shadow-right" />').on('scroll', pcc_table_shadows);
	// fire on resize
	$(window).resize(function () {
		$('table').each(pcc_table_shadows);
	});
	// fire at start (needed if screen starts small)  
    $(window).load( function(){ 
        $(this).resize();
    });
}

function pcc_table_shadows() {
	if ($(this).outerWidth() < $(this).get(0).scrollWidth) { // is there any overflow?
		var left = $(this).scrollLeft();
		var right = $(this).get(0).scrollWidth - $(this).outerWidth() - left;
		left ? $(this).parent().find('div.shadow-left').fadeIn(300) : $(this).parent().find('div.shadow-left').fadeOut(300);
		right ? $(this).parent().find('div.shadow-right').fadeIn(300) : $(this).parent().find('div.shadow-right').fadeOut(300);
	} else {
		$(this).parent().find('div.shadow-left,div.shadow-right').hide(); // no overflow 
	}
}

/* run the scripts */
$(document).ready(function () {
  pcc_current_link();
  pcc_tables();
});