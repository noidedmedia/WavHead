$(document).ready(function() {
  $('#content').fullpage({
    css3: true,
    paddingTop: '60px',
    easing: 'easeInCubic',
    loopBottom: false,
    loopTop: false,
    loopHorizontal: false,
    slidesNavigation: true,
    slidesNavPosition: 'bottom',
    menu: '#header',
    anchors: ['home', 'design', 'features', 'install', 'about'],
    onLeave: function(index, nextIndex, direction) {
      if(nextIndex == 1) {
        $("#headercontainer").css("background-color", "transparent");
      }
      else {
        $("#headercontainer").css("background-color", "rgba(88,86,214,0.6)");
      }
    },
  });
});