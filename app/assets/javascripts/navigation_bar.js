
function onWindowResize() {
  var $nav = $('#main_nav_menu');
  var breakpoint = $nav.data('breakpoint');
  if ($(window).width() <= breakpoint) {
    if (!$nav.hasClass("sm-screen")) {
      $('#main_nav_menu').addClass('collapsed');  
      $('#main_nav_menu_toggler').addClass('collapsed');  
    }
    $nav.removeClass("lg-screen").addClass("sm-screen");
  } else {
    if (!$nav.hasClass("lg-screen")) {
      $('#main_nav_menu').removeClass('collapsed');  
      $('#main_nav_menu_toggler').removeClass('collapsed');  
    }
    $nav.removeClass("sm-screen").addClass("lg-screen");
  }
  $('#main_nav_menu li').removeClass('active');
}

$(document).on('click', '#main_nav_menu_toggler', function(e) {
  e.preventDefault();
  $('#main_nav_menu').toggleClass('collapsed');  
  $('#main_nav_menu_toggler').toggleClass('collapsed');  
});

$(document).on('click', '#main_nav_menu li a, #main_nav_menu li .touch-button', function(e) {
  if($(this).siblings('ul').length > 0)
  {
    e.preventDefault();
    var $parent = $(this).closest('li');
    $parent.siblings('li').removeClass('active');
    $parent.toggleClass('active');
  }
});
    
$(window).on('resize', onWindowResize);

//$(window).on('resize', function(){alert('callback #1');});
//$(window).on('resize', function(){alert('callback #2');});


$( document ).ready(function( $ ) {
  onWindowResize();
});

