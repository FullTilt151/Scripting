function d_a(ary) {
	var beg = next_entry(ary) - 1; 
	for (var i = beg ; i > -1; i--) {
		ary[i] = null;
	}
} 

function init_array() {
	var ary = new Array(null); 
	return ary;
}

function set_cookie(name,value,expires) {
	if (!expires) expires = new Date();
	
	document.cookie = name + '=' + escape(value) + '; expires=' + expires.toGMTString() + '; path=/';
} 
	
function get_cookie(name) {
	var dcookie = document.cookie; 
	var cname = name + "="; 
	var clen = dcookie.length; 
	var cbegin = 0; 
	while (cbegin < clen) {
		var vbegin = cbegin + cname.length;
		if (dcookie.substring(cbegin, vbegin) == cname) {
			var vend = dcookie.indexOf (";", vbegin); 
			if (vend == -1) vend = clen; 
			return unescape(dcookie.substring(vbegin, vend));
		} 
		cbegin = dcookie.indexOf(" ", cbegin) + 1; 
		if (cbegin == 0) break;
	} 
	return null;
} 
	
function del_cookie(name) {
	document.cookie = name + '=' + '; expires=Thu, 01-Jan-70 00:00:01 GMT; path=/';
} 

function get_indexed_array(name, ary) {
	var ent = get_cookie(name); 
	if (ent) {
		d_a(ary); 
		i = 1; 
		while (ent.indexOf('^') != '-1') {
			ary[i] = ent.substring(0,ent.indexOf('^')); 
			i++;
			ent = ent.substring(ent.indexOf('^')+1, ent.length);
		}
	}
} 

function get_associated_array(name, ary) {
	var ent = get_cookie(name);
	var thisEntry
	if (ent) {
		d_a(ary); 
		while (ent.indexOf('^') != '-1') {
			thisEntry = ent.substring(0,ent.indexOf('^')).split("=")
			ary[thisEntry[0]] = thisEntry[1];
			ent = ent.substring(ent.indexOf('^')+1, ent.length);
		}
	}
} 

function set_indexed_array(name, ary, expires) {
	var value = ''; 
	for (var i = 1; ary[i]; i++) {
		value += ary[i] + '^';
	} 
	set_cookie(name, value, expires);
} 

function set_associated_array(name, ary, expires) {
	var value = ''; 
  for (var index in ary)
    value += index + '=' + ary[index] + '^';
	set_cookie(name, value, expires);
} 

function del_entry(name, ary, pos, expires) {
	var value = ''; 
	get_array(name, ary); 
	for (var i = 1; i < pos; i++) {
		value += ary[i] + '^';
	} 
	for (var j = pos + 1; ary[j]; j++) {
		value += ary[j] + '^';
	} 
	set_cookie(name, value, expires);
} 

function next_entry(ary) {
	var j = 0; 
	for (var i = 1; ary[i]; i++) {
		j = i;
	} 
	return j + 1;
}

function dump_cookies() {
	if (document.cookie == '') document.write('No Cookies Found'); 
	else {
		thisCookie = document.cookie.split('; '); 
		for (i=0; i<thisCookie.length; i++) {
			document.write(thisCookie[i] + '<br>');
		}
	}
}
