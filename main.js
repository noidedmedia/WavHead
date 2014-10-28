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
      if(nextIndex == 1) {
        $("#headercontainer").css("background-color", "rgba(88,86,214,0.6)");
        $("#headercontainer").css("top","-60px");
      }
      else {
        $("#headercontainer").css("background-color", "rgba(88,86,214,0.6)");
        $("#headercontainer").css("top", "0px");
      }
    },
  });
});