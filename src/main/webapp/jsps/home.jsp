<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>DPC Demo Inc- Home Page</title>
<link href="images/dpc.jpeg" rel="icon">
</head>
</head>
<body>
<h1 align="center">Welcome to DPC Demo Inc, Calgary, Canada Office.</h1>
<h1 align="center">We are developing and supporting quality Software Solutions to millions of clients.
	We offer Training for IT Professional with Linux and Cloud equipping IT Engineers for best performance. God Loves you. Everyone will be hired with multiple job offers, Amen</h1>
<hr>
<br>
	<h1><h3> Server Side IP Address </h3><br>

<% 
String ip = "";
InetAddress inetAddress = InetAddress.getLocalHost();
ip = inetAddress.getHostAddress();
out.println("Server Host Name :: "+inetAddress.getHostName()); 
%>
<br>
<%out.println("Server IP Address :: "+ip);%>
		
</h1>
	
<hr>
<div style="text-align: center;">
	<span>
		<img src="images/DP black.png" alt="" width="150">
	</span>
	<span style="font-weight: bold;">
                DPC Demo Inc, 
		Calgary, Alberta, Canada
		+1 xxx xxx xxx,
		info@dpc-demo.com
		<br>
		<a href="mailto:info@acadalearning">Mail to DPC Inc</a>
	</span>
</div>
<hr>
	<p> Service : <a href="services/employee/getEmployeeDetails">Get Employee Details </p>
<hr>
<hr>
<p align=center>DPC Inc - Consultant, Training and Software Development</p>
<p align=center><small>Copyrights 2023 by <a href="http://acadalearning.com/">DPC Demo Inc</a> </small></p>

</body>
</html>
