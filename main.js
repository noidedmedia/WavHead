$(document).ready(function() {
    $('#content').fullpage({
      css3: true,
      paddingTop: '60px',
      easing: 'easeInCubic',
      loopBottom: false,
      loopTop: false,
      slidesNavigation: true,
      menu: '#header',
      anchors: ['home', 'design', 'features', 'install', 'about'],
    });
});