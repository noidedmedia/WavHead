$(document).ready(function() {
  $('#content').fullpage({
    css3: true,
    paddingTop: '60px',
    easing: 'easeInCubic',
    loopBottom: false,
    loopTop: false,
    loopHorizontal: false,
    slidesNavigation: true,
    slidesNavPosition: 'top',
    menu: '#header',
    anchors: ['home', 'design', 'features', 'install', 'about'],
    onLeave: function(index, nextIndex, direction) {
      var windowwidth = $(window).width();
      var windowheight = $(window).height();

      if(nextIndex == 1 && windowwidth < 700) {
        $("#headercontainer").css("top","-60vh");
      }
      else if(windowwidth < 700) {
        $("#headercontainer").css("top", -(windowheight * .6) + 60 + "px");
      }
      else if(nextIndex == 1 && windowwidth > 700) {
        $("#headercontainer").css("top","-60px");
      }
      else if(windowwidth > 700) {
        $("#headercontainer").css("top","0px");
      }
    },
  });
});