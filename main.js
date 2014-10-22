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
    });
});