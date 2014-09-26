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
    $(".nothingplaying").css({'display': 'inline-flex'});
    $(".somethingplaying").css({'display': 'none'});
    var updatetime = 10; // check again in 10 seconds
  }
  else{
    // Something is playing! Woo!
    // Show the user info on that
    $(".somethingplaying").css({'display': 'block'});
    $(".nothingplaying").css({'display': 'none'}); // Hide the nothing playing message
    $(".currentalbumart").html("<a href='/browse/" + o.artist + "/" + o.album + "'>" + "<img src='/cover/" + o.artist + "/" + o.album + "'>" + "</a>"); // Set album art for current song with link to said album.
    $(".songtitle").html(o.title); // Set title
    $(".artistalbumtitle").html("<a href='/browse/" + o.artist + "'>" + o.artist + "</a>" + " &mdash; " + "<a href='/browse/" + o.artist + "/" + o.album + "'>" + o.album + "</a>"); 
    // Set info with links to the album/artist pages. If you are trying to understand the above code, God help you.
    loadBar(o); // setup the loading bar
    // The above sets the width of the progress bar to the proper length
    var updatetime = o.timeleft;
  }
  setTimeout(update, updatetime * 1000); // When it's time to update,
  // update. 
}

function loadBar(o){
  var percent = o.percentfinished;
  var docwidth = $(document).width(); // Sets a variable for the total width of the page.
  console.log("Song is " + o.percentfinished * 100 + " percent finished."); // Sends a message to the console about how much of the song has been played.

  // If the browser/device width is more than 700px...
  if(docwidth > '700'){
    $(".songprogress").css({'display': 'block'}); // Sets songprogress to display if a song is playing.
  }
  
  if(docwidth < '700'){
    $(".progressbar").css("width", docwidth - 90); // Sets the progressbar to be 
  }

  $(".progressbar").css({'display': 'block'}); // Sets progressbar to display if a song is playing.
  $(".progressbarfill").css({'display': 'block'}); // Sets progressbarfill to display if a song is playing.
  $(".progressbarfill").css("width", (percent * 100) + "%"); // Determines how much of the progressbar will be taken up (in percentage points) by the progressbarfill.
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

// This function takes the value of the song total length and how much of the song has been played and converts it from seconds to a "00:00" format.
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

function responsiveFooter(){
  var docwidth = $(document).width(); // Sets a variable for the total width of the page.
  var progressbarwidth = parseInt( docwidth - 100 );
}

// When the page loads, the JavaScript function called "update" is run, which ensures that the Queue and current song info are both accurate.
window.onload = update;
