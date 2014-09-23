function update()
{
  $.getJSON("/current.json", function(o){
    // set the current song
    setCurrentSong(o);
  });
}

function setCurrentSong(o)
{
  console.log(o);
  if(! o === null){
    // o is null, nothing is playing
    // remove the visibility of current song progress, set the other thing
    // to playing
    $(".somethingplaying").hide();
    var updatetime = 20; // check again in 20 seconds
  }
  else{
    // Something is playing! Woo!
    // Show the user info on that
    $(".nothingplaying").hide(); // Hide the nothing playing message
    $(".songtitle").html(o.title); // Set title
    $(".artistalbumtitle").html(o.artist + " - " + o.album); // set info
    loadBar(o); // setup the loading bar
    // The above sets the width of the progress bar to the proper length
    var updatetime = o.timeleft;
  }
  setTimeout(update,updatetime * 1000); // When it's time to update,
  // update. 

}

function loadBar(o){
  var percent = o.percentfinished;
  console.log("Song is " + o.percentfinished * 100 + " percent  finished.");
  $(".progressbarfill").css("width", (percent * 100) + "%");
  $(".progressbarfill").data("percentage", percent);
  // Now the progress bar is set to the proper value.
  // So we need to make it update constantly.
  var grainsize = 100; // Update rate in miliseconds
  var total = o.duration * 1000; // Total time in miliseconds
  var updateFunction = function(){
    // Each time, we update the percentage by grainsize / duration
    var oldpercent = $(".progressbarfill").data("percentage");
    var newpercent = oldpercent + (grainsize / total);
    $(".progressbarfill").data("percentage", newpercent);
    // Update the width
    $(".progressbarfill").css("width", newpercent * 100 + "%");
  }
  var timer = window.setInterval(updateFunction, grainsize);
  setTimeout(function(){
    clearTimeout(timer);
  }, total + 3);
}
$(document).ready(function(){
  update();
});
