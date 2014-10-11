// This function is used to update the song that is presently playing.
function update()
{
  ajaxify_forms();
  eventListeners();
  console.log("Updating currently playing song...");
  $.getJSON("/current.json", function(o){
    // set the current song
    setCurrentSong(o);
    updateQueue();
    windowSize();
  });
}

// Makes the forms submit async
function ajaxify_forms()
{
  $(".voteform").submit(function(e){   
    e.preventDefault();
    var data = $(this).serialize();
    $.ajax({
      type: "POST",
      url: this.action,
      data: data,
      success: function(){
        updateQueue();
      }
    });
  });

}

// As the name would imply, this function updates the Queue.
function updateQueue(){
  sidebar = $(".sidebar");
  console.log(sidebar);
  sidebar.load("/queue #queue");
}


// Depending on if a song is currently playing, different values are modified and elements shown/hidden.
function setCurrentSong(o)
{
  console.log(o);
  if(o === null){
    // o is null, nothing is playing
    // remove the visibility of current song progress, set the other thing
    // to playing
    $("#somethingplaying").css({'display': 'none'});
    $("#nothingplaying").css({'display': 'inline-block'});
    $(".currentalbumart").find("img").attr("src","/nocover.png");
    console.log("Nothing playing, trying again in a few seconds...");
    var updatetime = 5; // check again in 5 seconds
  }
  else{
    // Something is playing! Woo!
    // Show the user info on that
    $("#somethingplaying").css({'display': 'block'});
    $("#nothingplaying").css({'display': 'none'}); // Hide the nothing playing message
    $(".currentalbumart").html("<a href='/browse/" + o.safe_artist + "/" + o.safe_album + "'>" + "<img src='/cover/" + o.safe_artist + "/" + o.safe_album + "'>" + "</a>"); // Set album art for current song with link to said album.
    $(".currentsongtitle").html(o.title); // Set title
    console.log("Title is: " + o.title);
    $(".currentartisttitle").html("<a href='/browse/" + o.safe_artist + "'>" + o.artist + "</a>");
    $(".currentalbumtitle").html("<a href='/browse/" + o.safe_artist + "/" + o.safe_album + "'>" + o.album + "</a>");
    // Set info with links to the album/artist pages. If you are trying to understand the above code, God help you.
    loadBar(o); // setup the loading bar
    // The above sets the width of the progress bar to the proper length
    var updatetime = o.timeleft;
  }
  setTimeout(update, updatetime * 1000); // When it's time to update,
  // update. 
}

// This function is used to modify the progress bar that visualized how much of the song has been played.
function loadBar(o){
  var percent = o.percentfinished;
  var windowwidth = $(window).width(); // Sets a variable for the total width of the browser viewport.
  console.log("Song is " + o.percentfinished * 100 + " percent finished."); // Sends a message to the console about how much of the song has been played.

  // If the browser/device width is more than 700px...
  if(windowwidth > '750'){
    $(".songprogress").css({'display': 'block'}); // Sets songprogress to display if a song is playing.
  }
  
  if(windowwidth < '750'){
    $(".progressbar").css("width", windowwidth - 90); // Sets the progressbar to be the width of the window minus 90 pixels, the size of the album art.
    $(".songprogress").css({'display': 'none'}); 
  }

  $(".progressbar").css({'display': 'block'}); // Sets progressbar to display if a song is playing.
  $(".progressbarfill").css({'display': 'block'}); // Sets progressbarfill to display if a song is playing.
  $(".progressbarfill").css("width", (percent * 100) + "%"); // Determines how much of the progressbar will be taken up (in percentage points) by the progressbarfill.
  $(".progressbarfill").data("percentage", percent);
  // Now the progress bar is set to the proper value.
  // So we need to make it update constantly.
  var total = o.duration * 1000; // Total time in milliseconds
  var grainsize = 300; // Update the progress bar every 300 miliseconds
  var timeleft = o.timeleft  * 1000;
  // endTime is when the song shall end.
  var endTime = new Date((new Date()).getTime() + timeleft);
  // startTime is when the song started
  // The stray plus is there because of Javascript being bad at types
  var startTime = new Date(+endTime.getTime() - total);
  var timer = window.setInterval(function(){
    var elapsed = (new Date()).getTime() - startTime.getTime();
    var newpercent = elapsed/total;
    timeOutput(newpercent * o.duration, o.duration);
    $(".progressbarfill").css("width", newpercent * 100 + "%");
  }, grainsize);
  setTimeout(function(){
    console.log("Stopping the update of the progress bar.");
    // We stop doing the queue update just before the song ends
    clearTimeout(timer);
  }, timeleft - 100);
}

// This function takes the value of the song total length and how much of the song has been played and converts it from seconds to a "00:00" format.
function timeOutput(left, total){
  var windowwidth = $(window).width(); // Defines a variable that is equivalent to the height of the browser window.

  // This is limited to browser windows of 750px or more to ensure that the 0:00 value isn't displayed on mobile devices.
  if(windowwidth > '750'){
    // Sets the variable "elapsedTime" to the amount of time remaining.
    var elapsedTime = left;
    // Math stuff to determine the minutes value.
    var elapsedMinutes = parseInt( elapsedTime / 60 ) % 60;
    // Math stuff to determine the seconds value.
    var elapsedSeconds = parseInt( elapsedTime % 60 ) + 00;
    // Returns minutes and then seconds, where the seconds value would be displayed with a leading 0 (e.g. "3:03" instead of "3:3") if the integer is less than 10, and normally otherwise.
    var songTimeElapsed = elapsedMinutes + ":" + (elapsedSeconds < 10 ? "0" + elapsedSeconds : elapsedSeconds);
    // Inserts the songTimeElapsed value into the "songprogresselapsed" div.
    $(".songprogresselapsed").html(songTimeElapsed);

    // Sets the variable "elapsedTime" to the total length of the song.
    var totalTime = total;
    // Math stuff to determine the minutes value.
    var totalMinutes = parseInt( totalTime / 60 ) % 60;
    // Math stuff to determine the seconds value.
    var totalSeconds = parseInt( totalTime % 60 ) + 00;
    // Returns minutes and then seconds, where the seconds value would be displayed with a leading 0 (e.g. "3:03" instead of "3:3") if the integer is less than 10, and normally otherwise.
    var songTimeTotal = totalMinutes + ":" + (totalSeconds < 10 ? "0" + totalSeconds : totalSeconds);
    // Inserts the songTimeTotal value into the "songprogresstotal" div.
    $(".songprogresstotal").html(songTimeTotal);
  }
}

// Run when the browser window is resized to ensure that everything retains the proper dimensions.
function windowSize(){
  var windowheight = $(window).height(); // Defines a variable that is equivalent to the height of the browser window.
  var windowwidth = $(window).width(); // Defines a variable that is equivalent to the width of the browser window.

  // If the window width is 750px or greater, then do the following.
  if(windowwidth > '750'){
    // Modifies the height of the sidebar container to be 180px smaller than the window's height.
    // This is because the header is 50px high, the Queue header is 40px high, and the footer is 90px high, or 180px overall.
    $("#sidebarcontainer").css("height", windowheight - 180 + "px");

    // Sets the width of the contentcontainercontainer to be 75% of the browser window, with 5px subtracted for a margin.
    $("#contentcontainercontainer").css("width", (windowwidth * 0.75) + "px");

    // Sets the height of the contentcontainercontainer to be 140px less than the browser window's height. This is because the header has a height of 50px and the footer has a height of 90px. 
    $("#contentcontainercontainer").css("height", windowheight - 140 + "px");

    $("#contentcontainer").css("width", (windowwidth * 0.75) - 330 + "px");

    // This sets the sidebar width to 25% of the window's width, minus 20px to allow for horizontal margins of 10px on each side of the sidebar.
    $(".sidebar").css("width", (windowwidth * 0.25) - 20 + "px");    
  }

  // Otherwise, do this:
  else{
    // This sets the contentcontainercontainer to the full width (100%) of the browser window. This is for mobile devices, mostly.
    $("#contentcontainercontainer").css("width", windowwidth + "px");

    // This sets the contentcontainercontainer to the window height, minus the header and footer.
    $("#contentcontainercontainer").css("height", windowheight - 140 + "px");
  }
}

// Function that displays the mobile Queue when hamburger icon in the header is pressed.
function mobileQueue(){
  var windowwidth = $(window).width(); // Defines a variable that is equivalent to the width of the browser window.
  var windowheight = $(window).height(); // Defines a variable that is equivalent to the height of the browser window.

  // If the mobile overlay isn't currently being displayed....
  if(document.getElementById('mobileoverlay').style.display == 'none'){
    $("#mobileoverlay").toggle(); // Displays the mobile overlay.
    $(".queueheader").toggle(); // Displays the queue header.
    $("#mobilesidebarcontainer").css("height", windowheight - 90 + "px"); // Determines the mobilesidebarcontainer's height based on the viewport height minus the header and queue header heights.
    $("body").css("overflow-y", "hidden"); // Disables scrolling of background content.
  }
  // If the mobile overlay is already being shown, everything will be toggled back to hidden.
  else{
    $("#mobileoverlay").toggle();
    $(".queueheader").toggle();
    $("body").css("overflow-y", "scroll");
  }
}

// Function that makes the page "listen" for certain HTML objects being pressed. Primarily used for toggling the mobile queue sidebar.
function eventListeners(){
  var mobileQ = document.getElementById("mobilequeuebutton");
  var overlay = document.getElementById("mobileoverlaybackground");

  mobileQ.addEventListener("click", mobileQueue, false);
  overlay.addEventListener("click", mobileQueue, false);
}

// When the window is resized, run the function "windowSize()" above.
window.onresize = windowSize;

// When the page loads, the JavaScript function called "update" is run, which ensures that the Queue and current song info are both accurate.
window.onload = update;