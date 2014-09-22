function loadXMLDoc() {
  var xmlhttp;

  xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 ) {
      if(xmlhttp.status == 200){
        document.getElementById("myDiv").innerHTML = xmlhttp.responseText;
      }

      else if(xmlhttp.status == 400) {
        alert('There was an error 400')
      }
      
      else {
        alert('something else other than 200 was returned')
      }
    }
  }

  xmlhttp.open("GET", "ajax_info.txt", true);
  xmlhttp.send();
}

function convertToTime(@song.length) {
  var totalSec = @song.length;
  var minutes = parseInt( totalSec / 60 ) % 60;
  var seconds = parseInt( totalSec % 60 ) + 00;
  return((minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds  < 10 ? "0" + seconds : seconds));
}