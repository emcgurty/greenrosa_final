// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



function displayComments(which_div) {
    if (document.getElementById(which_div).style.display == 'inline')
        document.getElementById(which_div).style.display = 'none';
    else
        document.getElementById(which_div).style.display = 'inline';
}



