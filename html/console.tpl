%head%

  <div id="main">
    <div class="header">
      <h1><span class="esp">esp</span> link - Microcontroller Console</h1>
    </div>

    <div class="content">
      <p>The Microcontroller console shows the last 1024 characters
         received from UART0, to which a microcontroller is typically attached.</p>
      <p>
        <a id="reset-button" class="pure-button button-primary" href="#">Reset µC</a>
        &nbsp;Baud:
        <a id="57600-button" href="#" class="pure-button">57600</a>
        <a id="115200-button" href="#" class="pure-button">115200</a>
        <a id="230400-button" href="#" class="pure-button">230400</a>
        <a id="460800-button" href="#" class="pure-button">460800</a>
      </p>
      <pre class="console" id="console"></pre>
    </div>
  </div>
</div>

<script src="ui.js"></script>
<script type="text/javascript">
  function loadJSON(url, okCb, errCb) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = handleEv;

    function handleEv() {
      try {
        //console.log("handleEv", xhr.readyState);
        if(xhr.readyState < 4) {
          return;
        }

        if(xhr.status !== 200) {
          //console.log("handleEv error cb");
          if (errCb != null) errCb(xhr);
          return;
        }

        // all is well  
        if(xhr.readyState === 4) {
          //console.log("handleEv success cb");
          if (okCb != null) okCb(xhr, JSON.parse(xhr.responseText));
        }
      } catch(e) {return;}
    }

    xhr.open('GET', url, true);
    xhr.send('');
  }

  function fetchText(delay) {
    el = document.getElementById("console");
    if (el.textEnd == undefined) {
      el.textEnd = 0;
      el.innerHTML = "";
    }
    window.setTimeout(function() {
      loadJSON("/console/text?start=" + el.textEnd, updateText, retryLoad);
    }, delay);
  }

  function updateText(xhr, resp) {
    el = document.getElementById("console");

    delay = 3000;
    if (el == null || resp == null) {
      //console.log("updateText got null response? xhr=", xhr);
    } else if (resp.len == 0) {
      //console.log("updateText got no new text");
    } else {
      console.log("updateText got", resp.len, "chars at", resp.start);
      if (resp.start > el.textEnd) {
        el.innerHTML = el.innerHTML.concat("\r\n<missing lines\r\n");
      }
      el.innerHTML = el.innerHTML.concat(resp.text);
      el.textEnd = resp.start + resp.len;
      delay = 500;
    }
    fetchText(delay);
  }

  function retryLoad(xhr) {
    fetchText(1000);
  }

  function baudButton(baud) {
    document.getElementById(""+baud+"-button").addEventListener("click", function(e) {
      console.log("switching to", baud, "baud");
      e.preventDefault();
      loadJSON("/console/baud?rate="+baud);
    });
  }

  window.onload = function() {
    fetchText(100);

    document.getElementById("reset-button").addEventListener("click", function(e) {
      el = document.getElementById("console");
      e.preventDefault();
      //console.log("reset click");
      el.innerHTML = "";
      loadJSON("/console/reset");
    });
    baudButton(57600);
    baudButton(115200);
    baudButton(230400);
    baudButton(460800);
  }
</script>
</body></html>
