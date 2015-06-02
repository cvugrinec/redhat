<html>
<head>
<script src="jquery/jquery-1.11.3.min.js"></script>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<style type="text/css">
div {
  width: 400px;
}
 
h2 {
  font: 400 40px/1.5 Helvetica, Verdana, sans-serif;
  margin: 0;
  padding: 0;
}
 
ul {
  list-style-type: none;
  margin: 0;
  padding: 0;
  width: 400px;
}
 
li {
  width: 400px;
  font: 200 20px/1.5 Helvetica, Verdana, sans-serif;
  border-bottom: 1px solid #ccc;
}
 
li:last-child {
  border: none;
}
 
li a {
  text-decoration: none;
  color: #000;
  display: block;
  width: 400px;
 
  -webkit-transition: font-size 0.3s ease, background-color 0.3s ease;
  -moz-transition: font-size 0.3s ease, background-color 0.3s ease;
  -o-transition: font-size 0.3s ease, background-color 0.3s ease;
  -ms-transition: font-size 0.3s ease, background-color 0.3s ease;
  transition: font-size 0.3s ease, background-color 0.3s ease;
}
 
li a:hover {
  font-size: 30px;
  background: #f6f6f6;
}
</style>
</head>

<script type="text/javascript">
	$(document).ready(function() {
			function isArray(what) {
				result = false;
				if (Object.prototype.toString.call(what) === '[object Object]') {
					result = true;
				}
				return result;
			}

			$.getJSON("./<%= request.getParameter("instance") %>.json",function(data) {
				var items = [];
				$.each(data,function(key, val) {
					if (isArray(val)) {
						items.push("<li id='" + key + "'><a href=\"#\">"+ key+"</a>");
						items.push("<ul>");
						$.each(val,function(key2,val2) {
							if (isArray(val2)) {
								items.push("<li id='" + key2 + "'>"+ key2);
								items.push("<ul>");
								$.each(val2,function(key3,val3) {
								if (isArray(val3)) {
									items.push("<li id='" + key3 + "'>"+ key3);																							items.push("<ul>");
									$.each(val3,function(key4,val4) {
									items.push("<li id='" + key4 + "'>"+ key4+ ' : '+ val4+ "</li>");
								});
								items.push("</ul>");
							} else {
								items.push("<li id='" + key3 + "'>"+ key3+ ' : '+ val3+ "</li>");
							}
						});
						items.push("</ul>");
					} else {
						items.push("<li id='" + key2 + "'>"+ key2+ ' : '+ val2+ "</li>");
					}
				});
				items.push("</ul>");
				items.push("</li>");
			} else {
				items.push("<li id='" + key + "'>"+ key+ ' : '+ val+ "</li>");
			}
		});
		$("<ul/>", {html : items.join("")}).appendTo("#list4");
	});
});
</script>

<body>
	<h2>EAP health check <%= request.getParameter("instance") %></h2>
	<div id="list4"></div>
</body>
</html>
