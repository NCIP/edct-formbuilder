<%--
Copyright (c) 2012 HealthCare It, Inc.
All rights reserved. This program and the accompanying materials
are made available under the terms of the BSD 3-Clause license
which accompanies this distribution, and is available at
http://directory.fsf.org/wiki/License:BSD_3Clause

Contributors:
    HealthCare It, Inc - initial API and implementation
--%>
<%@ include file="/WEB-INF/includes/taglibs.jsp" %>	

<%@ page import="com.healthcit.cacure.utils.Constants"%>
<%@ page import="com.healthcit.cacure.model.Module"%>
<%@ page import="java.util.ArrayList"%>

	<script language="javascript">
		function showControls(){
			if(document.getElementById('type').value == "checkbox"){
				ShowContent('radiocheck');
			} else if(document.getElementById('type').value == "radio"){
				ShowContent('radiocheck');
				} else if(document.getElementById('type').value == "input"){
				HideContent('radiocheck');			
			}
		}
		
		function onLoadItems(){		
		 		HideContent("searchResults");	 	
		}
		
		function submit(questionValue,fieldName){
			window.opener.document.getElementById("question").value = questionValue;
			window.opener.document.getElementById("fieldName").value = fieldName;
			window.close();
		}
		
	    window.onload=onLoadItems;
	</script>

   <html:form action="/AddQuestionAction" method="post">
     <table width="740" border="0" cellpadding="0" cellspacing="0" class="inputTable" >   
    <tr>
      <td>
     <table width="100%">
        <tr>
          <td colspan="4" height="15"></td>
        </tr>
        <tr>
          <td colspan="4" align="center"><input type="text" name="question" size="75" maxlength="200"/></td>
        </tr>
        <tr>
          <td colspan="4" height="10"></td>
        </tr>           
        <tr>
          <td colspan="4" align="center"><input name="CADSR" value="Search" type="button" onClick="ShowContent('searchResults');"/></td>
          <td></td>
        </tr>   
        <tr>
          <td colspan="4" height="10"></td>
        </tr> 
   </table>     
   </td>
   </tr>
   
    <tr>
      <td>
     <div id="searchResults">
     <table width="100%">
        <tr>
          <td colspan="4" height="15"></td>
        </tr>
        <tr>
          <td colspan="4" align="left"><a href="javascript:submit('Compared to a year ago, how would you rate your health, in general now? (Select only one.)','comparedtoyearago');">Compared to a year ago, how would you rate your health, in general now? (Select only one.)</a></td>
        </tr> 
        <tr>
          <td colspan="4" align="left"><a href="javascript:submit('Have you ever used any tobacco products?','tobacooproducts');">Have you ever used any tobacco products?</a></td>
        </tr> 
        <tr>
          <td colspan="4" align="left"><a href="javascript:submit('On average how many servings of fruits and vegetables do you consume each day?','fruitserving');">On average how many servings of fruits and vegetables do you consume each day?</a></td>
        </tr> 
        <tr>
          <td colspan="4" align="left"><a href="javascript:submit('Indicate the types of foods that are included in your diet (check all that apply)','typesoffood');">Indicate the types of foods that are included in your diet (check all that apply)</a></td>
        </tr>                                 
        <tr>
          <td colspan="4" height="10"></td>
        </tr> 
   </table>     
   </div>
   </td>
   </tr>   
   </table>
    </html:form>
