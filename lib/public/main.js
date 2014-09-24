function update()
{
  console.log("Updating currently playing song...");
  $.getJSON("/current.json", function(o){
    // set the current song
    setCurrentSong(o);
    updateQueue();
  });
}

function updateQueue(){
  sidebar = $("#sidebar");
  console.log(sidebar);
  sidebar.load("/queue #queue");
}

function setCurrentSong(o)
{
  console.log(o);

  if(o === null){
    // o is null, nothing is playing
    // remove the visibility of current song progress, set the other thing
    // to playing
    $(".nothingplaying").show();
    $(".somethingplaying").hide();
    var updatetime = 10; // check again in 10 seconds
  }
  else{
    // Something is playing! Woo!
    // Show the user info on that
    $(".somethingplaying").show();
    $(".nothingplaying").hide(); // Hide the nothing playing message
    $(".songtitle").html(o.title); // Set title
    $(".artistalbumtitle").html(o.artist + " &mdash; " + o.album); // set info
    loadBar(o); // setup the loading bar
    // The above sets the width of the progress bar to the proper length
    var updatetime = o.timeleft;
  }
  setTimeout(update, updatetime * 1000); // When it's time to update,
  // update. 
}

function loadBar(o){
  var percent = o.percentfinished;
  console.log("Song is " + o.percentfinished * 100 + " percent finished.");
  $(".progressbarfill").css("width", (percent * 100) + "%");
  $(".progressbarfill").data("percentage", percent);
  // Now the progress bar is set to the proper value.
  // So we need to make it update constantly.
  var grainsize = 100; // Update rate in milliseconds
  var total = o.duration * 1000; // Total time in milliseconds
  var timeleft = o.timeleft  * 1000;
  var timer = window.setInterval(function(){
    // Each time, we update the percentage by grainsize / duration
    var oldpercent = $(".progressbarfill").data("percentage");
    var newpercent = oldpercent + (grainsize / total);
    timeOutput(newpercent * o.duration, o.duration);
    $(".progressbarfill").data("percentage", newpercent);
    // Update the width
    $(".progressbarfill").css("width", newpercent * 100 + "%");
  }, grainsize);
  setTimeout(function(){
    console.log("Stopping the update of the progress bar.");
    // We stop doing the queue update 100 seconds before the song ends
    clearTimeout(timer);
  }, timeleft - 1000);
}

function timeOutput(left, total){
  var elapsedTime = left;
  var elapsedMinutes = parseInt( elapsedTime / 60 ) % 60;
  var elapsedSeconds = parseInt( elapsedTime % 60 ) + 00;
  var songTimeElapsed = elapsedMinutes + ":" + (elapsedSeconds  < 10 ? "0" + elapsedSeconds : elapsedSeconds);
  $(".songprogresselapsed").html(songTimeElapsed);
  var totalTime = total;
  var totalMinutes = parseInt( totalTime / 60 ) % 60;
  var totalSeconds = parseInt( totalTime % 60 ) + 00;
  // Returns minutes and then seconds, where the seconds value would be displayed with a leading 0 (e.g. "3:03" instead of "3:3") if the integer is less than 10, and normally otherwise.
  var songTimeTotal = totalMinutes + ":" + (totalSeconds  < 10 ? "0" + totalSeconds : totalSeconds);
  $(".songprogresstotal").html(songTimeTotal);
}

window.onload = update;
