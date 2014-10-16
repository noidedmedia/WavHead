window.onload = setup;

function setup(){
  var windowheight = $(window).height();
  var windowwidth = $(window).width();

  $("#homecontainer").css("height", windowheight - 60 + "px");
  $("#designcontainer").css("height", windowheight - 60 + "px");
  $("#featurescontainer").css("height", windowheight - 60 + "px");
  $("#installcontainer").css("height", windowheight - 60 + "px");
  $("#aboutcontainer").css("height", windowheight - 60 + "px");

  document.getElementById("wavheadtitle").addEventListener("click", homeScroll, false);
  document.getElementById("headeritems-design").addEventListener("click", designScroll, false);
  document.getElementById("headeritems-features").addEventListener("click", featuresScroll, false);
  document.getElementById("headeritems-install").addEventListener("click", installScroll, false);
  document.getElementById("headeritems-about").addEventListener("click", aboutScroll, false);

}

function homeScroll(){
  $('html, body').animate({
    scrollTop: $("#homecontainer").offset().top
  }, 1000);
}

function designScroll(){
  $('html, body').animate({
    scrollTop: $("#designcontainer").offset().top
  }, 1000);
}

function featuresScroll(){
  $('html, body').animate({
    scrollTop: $("#featurescontainer").offset().top
  }, 1000); 
}

function installScroll(){
  $('html, body').animate({
    scrollTop: $("#installcontainer").offset().top
  }, 1000);
}

function aboutScroll(){
  $('html, body').animate({
    scrollTop: $("#aboutcontainer").offset().top
  }, 1000);
}