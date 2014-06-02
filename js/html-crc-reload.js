/*
  crc-reload is a script to auto reload the current page when you save the html.

  Requires jquery.

  Usage: 
  Simply include this js file in your html page.
  It will ajax GET poll the current page every second and if the html is different, reload itself.

  Version 0.1 - Initial release

  Thanks to Andrea Ercolino for providing the javascript crc32 functionality
  http://noteslog.com/post/crc32-for-javascript/

*/

var previousCrc = 0;

$(function() {
    check(true);
    setInterval('check(false)', 3000);
});

function check(firstRun) {
    
    $.ajax({
	type: 'GET',			
        cache: false,
	url: window.location.pathname,					
	success: function(data) {						
	    
	    // if (window.console && window.console.firebug) {
	    //     for (var x in console) {
	    //         delete console[x];
	    //     }
	    // }
	    
	    if (firstRun) {	
		previousCrc = crc32(data);
		return;
	    }
	    
	    var newCrc = crc32(data);
	    
	    if (newCrc != previousCrc) {
		window.location.reload();
	    } 
	},
	dataType: 'html'
    });
}	

/* Improved crc32 function from http://stackoverflow.com/a/18639999 */

var makeCRCTable = function() {
    var c;
    var crcTable = [];
    for (var n = 0; n < 256; n++){
        c = n;
        for (var k = 0; k < 8; k++){
            c = ((c&1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1));
        }
        crcTable[n] = c;
    }
    return crcTable;
}

var crc32 = function(str) {
    var crcTable = window.crcTable || (window.crcTable = makeCRCTable());
    var crc = 0 ^ (-1);

    for (var i = 0; i < str.length; i++ ) {
        crc = (crc >>> 8) ^ crcTable[(crc ^ str.charCodeAt(i)) & 0xFF];
    }

    return (crc ^ (-1)) >>> 0;
};
