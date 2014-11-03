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
    menu: '#desktopheader',
    anchors: ['home', 'about', 'features', 'install', 'contact'],
    onLeave: function(index, nextIndex, direction) {
      if(nextIndex == 1) {
        $("#headercontainer").css("top","-60px");
      }
      else {
        $("#headercontainer").css("top","0px");
      }
    },
  });
});