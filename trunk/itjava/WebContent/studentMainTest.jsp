<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="org.apache.jasper.util.Entry"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="itjava.model.*, java.util.HashMap, java.util.ArrayList, itjava.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>Begin Learning..</title>
<style>
#divMainContent {
	width: 800px;
	margin:0 auto;
	position: relative;
}

#tableMeta {
	width: 800px;
}

#alternateLaunch {
	display: none;
}
</style>

<script type="text/javascript">
var launchCounts = 0;
function launchNext(folderName, deliverableName) {
	if (launchCounts == 0) {
		launchCounts++;
		window.open("delivery/" + folderName + "/" + deliverableName + ".jnlp");
		document.getElementById("btnLaunch").value = "Save & Next >>";
		document.getElementById("alternateLaunch").style.display = 'block';
		return false;
	}
	else {
		launchCounts = 0;
		return true;
	}
}

function launchNow(folderName, deliverableName) {
	window.open("delivery/" + folderName + "/" + deliverableName + ".jnlp");
	launchCounts = 1;
}
</script>

</head>

<body>
<%

int tutorialInfoId = Integer.parseInt(request.getParameter("id"));

DeliverableLauncher deliverableLauncher = (DeliverableLauncher)session.getAttribute("deliverableLauncher");
if (deliverableLauncher == null) {
	System.err.println("Landed on studentMainTest.jsp from a wrong source..");
	response.sendRedirect("studentWelcome.jsp");
}
else {
	deliverableLauncher.setStudentId((Integer)session.getAttribute("studentId"));
	deliverableLauncher.setTutorialInfoId(tutorialInfoId);
}

HashMap<String, String> whereClause = new HashMap<String, String>();
whereClause.put("tutorialInfoId", Integer.toString(tutorialInfoId));
session.setAttribute("tutorialInfoId", tutorialInfoId);
ArrayList<TutorialInfo> tutorialInfoList = TutorialInfoStore.SelectInfo(whereClause);

KeyValue<Integer, String> deliveryKeyValue = (KeyValue<Integer, String>)session.getAttribute("deliveryKeyValue");
int deliverableId = -1;
String deliverableName = null;
if (deliveryKeyValue == null  && request.getParameter("start").trim().equals("1")) {
	deliveryKeyValue = deliverableLauncher.GetFirstDeliverableName();
}
else if (deliveryKeyValue == null)
{
	response.sendRedirect("studentFinalPage.jsp");
}
deliverableId = deliveryKeyValue.getKey();
deliverableName = deliveryKeyValue.getValue();
%>
<form id="formMainTest" method="post" action="DeliverableSelectionServlet">
<div id="divMainContent">
<table border="1" id="tableMeta"><tbody>
<%
TutorialInfo tutorialInfo = new TutorialInfo();
if (tutorialInfoList.size() != 1) {
	System.err.println("TutorialInfo table should have returned only 1 tuple..");
	out.println("Error seeking Tutorial Information..");
}
else {
	tutorialInfo = tutorialInfoList.get(0);
	int timesAccessed = tutorialInfo.getTimesAccessed() + 1;
	TutorialInfoStore.UpdateInfo(tutorialInfoId, 
			new KeyValue<String, String>("timesAccessed", Integer.toString(timesAccessed)));
	out.println("<tr>");
	out.print("<td colspan=\"3\" class=\"tdTutorialName\">");
	out.print(tutorialInfo.getTutorialName());
	out.println("</td><tr>");
	
	out.print("<td class=\"tdMeta\">Created by : ");
	out.print(tutorialInfo.getCreatedBy());
	out.println("</td>");
	out.print("<td class=\"tdMeta\">Date : ");
	out.print(tutorialInfo.getCreationDate().toString());
	out.println("</td>");
	out.print("<td class=\"tdMeta\">Downloads : ");
	out.print(tutorialInfo.getTimesAccessed());
	out.println("</td></tr>");
	
	out.print("<tr><td colspan=\"3\" class=\"tdDescription\">Description : ");
	out.print(tutorialInfo.getTutorialDescription());
	out.println("</td></tr>");
	
}
String folderName = tutorialInfo.getFolderName();
String buttonLabel = "Begin Lesson";

String disabledLaunch = "";
if (deliverableName == null) {
	disabledLaunch = "disabled";
}
else {
	session.setAttribute("deliveryKeyValue", deliveryKeyValue);
	session.setAttribute("tutorialInfoId", tutorialInfoId);
	session.setAttribute("studentId", 99);
	session.setAttribute("deliverableLauncher", deliverableLauncher);
}
%>
</tbody></table>
<div id="divNavigate">
<input type="submit" id="btnLaunch" name="btnLaunch" value="<%= buttonLabel%>" 
	onclick="return launchNext('<%= folderName%>', '<%= deliverableName%>');"
	<%= disabledLaunch%>/>
</div>
<div id="alternateLaunch">
If you closed the pop-up by mistake, click on this <input type="button" value="button" onclick="return launchNow('<%= folderName%>', '<%= deliverableName%>');"/> to re-take the quiz.
</div>

</div>
</form>
</body>
</html>