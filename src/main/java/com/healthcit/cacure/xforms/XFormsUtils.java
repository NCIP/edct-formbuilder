/*******************************************************************************
 * Copyright (c) 2012 HealthCare It, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the BSD 3-Clause license
 * which accompanies this distribution, and is available at
 * http://directory.fsf.org/wiki/License:BSD_3Clause
 * 
 * Contributors:
 *     HealthCare It, Inc - initial API and implementation
 ******************************************************************************/
package com.healthcit.cacure.xforms;

import java.io.StringReader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.ResourceBundle;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.jdom.Attribute;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import org.jdom.input.SAXBuilder;

import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerSkipRule;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.BaseSkipPatternDetail;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionSkipRule;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableElement.TableType;
import com.healthcit.cacure.model.TableQuestion;

public class XFormsUtils
{
	//	xsltforms.xsl gives errror "Function http://www.w3.org/2005/xpath-functions ends-with() not found"
	@SuppressWarnings("unused")
	private static final String CONTAINS_VALUE_XPATH_FORMAT = "(%2$s = '%3$s' or starts-with(%2$s, '%3$s%1$s') or contains(%2$s, '%1$s%3$s%1$s') or ends-with(%2$s, '%1$s%3$s'))";
//	xsltforms.xsl gives errror "Function http://www.w3.org/2005/xpath-functions matches() not found"
	@SuppressWarnings("unused")
	private static final String CONTAINS_VALUE_XPATH_FORMAT_RE = "fn:matches(%2$s, '(?:^|%1$s)%3$s(?:$|%1$s)')";
	
	private static final String CONTAINS_VALUE_XPATH_FIX = "(%2$s = '%3$s' or starts-with(%2$s, '%3$s%1$s') or contains(%2$s, '%1$s%3$s%1$s') or substring(%2$s, string-length(%2$s) - string-length('%1$s%3$s') + 1) = '%1$s%3$s')";
	
	private static final ResourceBundle MESSAGES = ResourceBundle.getBundle( XFormsConstants.XFORMS_MESSAGES_BUNDLE_NAME );
	public static final String OPENING_SPAN = "<span>";
	public static final String CLOSING_SPAN = "</span>";
	public static final String INVALID_SHOWERRMSG_IDPREFIX = "errInvBlk-";
	public static final String ERRBLOCK_SHOWERRMSG_IDPREFIX = "errBlk-";
	public static final String ERRBLOCK_HIDEERRMSG_IDPREFIX = "noErrBlk-";
	public static final String INVALID_HIDEERRMSG_IDPREFIX = "noErrInvBlk-";
	public static final String ITEM_DELETE_TRIGGER = "item-delete-trigger-";
	public static final String ITEM_INSERT_TRIGGER = "item-insert-trigger-";
	public static final String BACKSLASH = "/";
	public static final String VALUE_SEPARATOR = "__VALUE_SEPARATOR__";
	
	public static String getXpathRef(String instanceID, String xPath)
	{
		if (instanceID == null || instanceID.length() == 0)
		{
			return xPath;
		}
		else
		{
			StringBuilder sb = new StringBuilder();
			sb.append("instance('").append(instanceID).append("')");
			if (xPath != null && xPath.length() > 0)
				sb.append(xPath);
			return sb.toString();
		}
	}

	public static List<?> parseStringAsXML( String str ) {
		try {
			Document document = new SAXBuilder( false ).build( new StringReader( OPENING_SPAN + str + CLOSING_SPAN ) );
			return document.getRootElement().cloneContent();
		} catch ( Exception ex ){ }
		return null;
	}

	public static String getFormElementInstanceIDREF(FormElement e)
	{
		//This is only currently used for FormElements that are not content
		String instance = null;
		if(e.isReadonly())
		{
			instance = getReadOnlyInstanceIDREF();
		}
		else
		{
			instance = getFormInstanceIDREF();
		}
		return instance;
	}
	public static String getFormElementInstanceIDREF(boolean isReadOnly)
	{
		//This is only currently used for FormElements that are not content
		String instance = null;
		if(isReadOnly)
		{
			instance = getReadOnlyInstanceIDREF();
		}
		else
		{
			instance = getFormInstanceIDREF();
		}
		return instance;
	}
	public static String getFormInstanceIDREF()
	{
		return "FormDataInstance";
	}

	public static String getReadOnlyInstanceIDREF()
	{
		return "ReadOnlyInstance";
	}
	
	public static String getViewInstanceIDREF()
	{
		return "ViewInstance";
	}

	public static String getItemDeleteXPath(FormElement fe)
	{
		return getXpathRef(getViewInstanceIDREF(), BACKSLASH + XFormsConstants.ITEM_DELETE_MODEL_TAG + "[@id='" + ITEM_DELETE_TRIGGER +fe.getUuid() + "']");
	}
	public static String getItemInsertXPath(FormElement fe)
	{
		return getXpathRef(getViewInstanceIDREF(), BACKSLASH + XFormsConstants.ITEM_INSERT_MODEL_TAG + "[@id='" + ITEM_INSERT_TRIGGER + fe.getUuid() + "']");
	}
	
//	public static String getLearnMoreInstanceIDREF()
//	{
//		return "LearnMoreInstance";
//	}

	public static String getDataGroupInstanceIDREF()
	{
		return "DataGroupInstance";
	}

	public static String getFormSkipGroupInstanceIDREF()
	{
		return "FormSkipInstance";
	}

	public static String getCrossFormSkipInstanceIDREF()
	{
		return "CrossFormSkipInstance";
	}

	public static String getURLInstanceIDREF()
	{
		return "URLInstance";
	}
	
	public static String getContextSpecificErrorsInstanceIDREF()
	{
		return "ContextSpecificErrorsInstance";
	}

	public static String getContentInstanceIDREF()
	{
		return "PureContentInstance";
	}

	public static String getQuestionIDREF(BaseQuestion q)
	{
		return "Q-" + q.getUuid();
	}
	public static String getComplexTableQuestionBindIDREF(TableQuestion q)
	{
		return "CTQ-" + q.getUuid();
	}

	public static String getQuestionIDREF(String id)
	{
		return "Q-" + id;
	}

/*	public static String getTableQuestionId(String id)
	{
//		return "TQ-" + id;
		return id;
	}
*/
	public static String getQuestionAnswerSetInstanceIDREF(String id)
	{
		return "Q-ANSWER_SET-" + id;
	}

	public static String getQuestionTextIDREF(Question q)
	{
		return "Q.TXT-" + q.getUuid();
	}

//	public static String getLearnMoreIDREF(Question q)
//	{
//		return "Q.LM-" + q.getUuid();
//	}

	public static String getContentIDREF(ContentElement ce)
	{
		return "Q.CONTENT-" + ce.getUuid();
	}

	public static String getAnswerIDREF(Answer a, Question q)
	{
		return "Q.ANS-" + q.getUuid() + "." +  a.getId().toString();
	}

	public static String getDataGroupIDREF(FormElement fe)
	{
		return getDataGroupIDREF( fe.getUuid() );
	}

	public static String getCrossFormSkipIDREF(Question q)
	{
		return getCrossFormSkipIDREF( q.getUuid() );
	}

	public static String getDataGroupIDREF(String q)
	{
		return "Q.GRP-" + q;
	}

	public static String getCrossFormSkipIDREF(String q)
	{
		return "Q.EXT-" + q;
	}
	
	public static String getRequiredErrorIDREF(FormElement q)
	{
		return getRequiredErrorIDREF(q.getUuid());
	}
	
	public static String getRequiredErrorIDREF(String q)
	{
		return "Q.REQERR-" + q;
	}

//	public static String getQuestionLearnMoreXPath(Question q)
//	{
//		return getXpathRef(getLearnMoreInstanceIDREF(),
//				"/" + XFormsConstants.LEARNMORE_TAG + "[@id='" + getLearnMoreIDREF(q) + "']");
//	}


	public static String getActionBaseURLXPath()
	{
		return getXpathRef(getURLInstanceIDREF(),BACKSLASH + XFormsConstants.ACTIONBASEURL_TAG);
	}

	public static String getActionFullURLXPath()
	{
		return getXpathRef(getURLInstanceIDREF(),BACKSLASH + XFormsConstants.ACTIONFULLURL_TAG);
	}
	
	public static String getXPathByIdAttribute(String id)
	{
		return "//*[@id='" + id + "']";
	}

	public static String getContentXPath(ContentElement q)
	{
//		return getXpathRef(getContentInstanceIDREF(),
//				"/" + XFormsConstants.CONTENT_TAG + "[@id='" + getContentIDREF(q) + "']");
		return "id('" + getContentIDREF(q) + "', instance('" + getContentInstanceIDREF() + "'))";

	}
/*
	public static String getQuestionXPath(BaseQuestion q)
	{
		boolean isTableQuestion = q.isTableQuestion();
		String questionId = ( q.isTableQuestion() ? q.getFirstAnswer().getId().toString() : q.getUuid());
		return getQuestionXPath(questionId);
	}
*/
	public static String getQuestionXPath(BaseQuestion q, boolean isReadOnly)
	{
		String questionId = q.getUuid();
		return getQuestionXPath(questionId, isReadOnly);
	}

	public static String getQuestionXPath(String id, boolean isReadOnly)
	{
//		return getXpathRef(getFormElementInstanceIDREF(isReadOnly), "/question[@id='" +  id + "']");
		return "id('" + id + "', instance('" + getFormElementInstanceIDREF(isReadOnly) + "'))";
	}
	
	public static String getTableQuestionXPath(String tableId, String id)
	{
//		return getXpathRef(getFormInstanceIDREF(), "/question-table[@id='"+ tableId + "']/question[@id='" +  id + "']");
		return "id('" + id + "', instance('" + getFormInstanceIDREF() + "'))";
	}

	public static String getCrossFormSkipQuestionAnswerXPath(final String formId, final String questionId, final String answerValue) {
		return getCrossFormSkipQuestionAnswerXPath(formId, null, questionId, answerValue);
	}
	
	public static String getCrossFormSkipQuestionAnswerXPath(final String formId, String rowId, final String questionId, final String answerValue)
	{
		return getXpathRef(getCrossFormSkipInstanceIDREF(), "/cross-form-skip[@formId='" + formId + "'" +
				(rowId != null ? " and @rowId='" + rowId + "'" : "") +
				" and @id='" + questionId + "']//answer[@value='" + answerValue + "']");
	}
		
	public static String getAnyIsEmptyAnswerConditionXPath(final FormElement fe) {
		String answerXPath = null;
		// If the form element is a complex table, then
		// display an error message if any of the answers in the leading column are empty
		boolean isDynamicTable = fe instanceof TableElement && TableType.DYNAMIC.equals((( TableElement )fe).getTableType());
		boolean isStaticTable = fe instanceof TableElement && TableType.STATIC.equals((( TableElement )fe).getTableType());
		if (isStaticTable || isDynamicTable)
		{
			answerXPath = getXpathRef(getFormElementInstanceIDREF(fe), "/complex-table[@id='"+ fe.getUuid() + "']/row" + (isDynamicTable ? "[position()!=last()]" : "") + "/column/answer");
		}
		else
		{
			answerXPath = getQuestionAnswersXPath(fe);
		}
		return "count(" + answerXPath + "[normalize-space(.)='']) > 0";
	}
	
	public static String getQuestionAnswerXPath(final BaseQuestion q, final String rowId) {
		return getStaticComplexTableAnswerXPath(q.getParent().getUuid(), rowId, q.getUuid());
	}
	
	public static String getQuestionAnswersXPath(final FormElement fe) {
		String answerXpath = null;
		if(fe instanceof TableElement) {
			if(TableType.SIMPLE.equals(((TableElement)fe).getTableType())) {
				//answerXpath = getXpathRef(getFormElementInstanceIDREF(fe), "/question-table[@id='"+ fe.getUuid() + "']/question/answer");
				answerXpath = "id('" + fe.getUuid() + "', instance('" + getFormElementInstanceIDREF(fe) + "'))/question/answer";
			} else {
				//answerXpath = getXpathRef(getFormElementInstanceIDREF(fe), "/complex-table[@id='"+ fe.getUuid() + "']/row/column/answer");
				answerXpath = "id('" + fe.getUuid() + "', instance('" + getFormElementInstanceIDREF(fe) + "'))/row/column/answer";
			}
		} else {
			answerXpath = getQuestionXPath(fe.getQuestions().get(0).getUuid(),fe.isReadonly()) + "/answer";
		}
		return answerXpath;
	}
	
	public static String getQuestionAnswerXPath(final BaseQuestion q)
	{
		FormElement parent = q.getParent();
		String xPath = null;
		if(parent instanceof TableElement)
		{
			TableElement tableElement = (TableElement) parent;
			TableType tableType = tableElement.getTableType();
			if(TableType.SIMPLE.equals(tableType)) {
				xPath = getTableQuestionAnswerXPath(parent.getUuid(), q.getUuid());
			} else {
				throw new RuntimeException("Unexpected table type.");
			}
		}
		else
		{
			xPath = getQuestionAnswerXPath(q.getUuid(), q.getParent().isReadonly());
		}
		return xPath;
	}

	public static String getComplexTableRowXPath(TableElement e)
	{
		//return getXpathRef(getFormElementInstanceIDREF(e), "/complex-table[@id='"+ e.getUuid() + "']/row");
		return  "id('" + e.getUuid() +"', instance('" + getFormElementInstanceIDREF(e)+ "'))/row";
	}
	public static String getComplexTableRowXPathRepeat(TableElement e)
	{
		//return getXpathRef(getFormElementInstanceIDREF(e), "/complex-table[@id='"+ e.getUuid() + "']/row" + (e.getTableType().equals(TableType.DYNAMIC) ? "[position()!=last()]" : ""));
		return "id('" + e.getUuid()+ "', instance('" + getFormElementInstanceIDREF(e) + "'))/row" + (e.getTableType().equals(TableType.DYNAMIC) ? "[position()!=last()]" : "");
	}
	
	public static String getSimpleTableRowXPathRepeat(TableElement e)
	{
//		return getXpathRef(getFormElementInstanceIDREF(e), "/question-table[@id='"+ e.getUuid() + "']/question");
		return "id('" + e.getUuid() + "', instance('" + getFormElementInstanceIDREF(e) + "'))/question";
	}
	
	public static String getComplexTableColumnXPathRepeat(TableElement e, int index)
	{
		return getComplexTableRowXPathRepeat(e) + "/column[" + index + "]/answer";
	}
	public static String getStaticComplexTableAnswerXPath(final String tableUuid, final String rowUuid, final String questionUuid)
	{
		//return getXpathRef(getFormInstanceIDREF(), "/complex-table[@id='"+ tableUuid + "']/row[@id='" + rowUuid + "']/column[@questionId='"+questionUuid +"']/answer");
		return getXpathRef(getFormInstanceIDREF(), "/complex-table[@id='"+ tableUuid + "']/row[@id='" + rowUuid + "']/column[@questionId='"+questionUuid +"']/answer");
	}
	public static String getComplexTableColumnXPath(TableElement e, int index)
	{
//		return getXpathRef(getFormElementInstanceIDREF(e), "/complex-table[@id='"+ e.getUuid() + "']/row[index('" + e.getUuid()+ "')]/column["+ index +"]/answer");
		return "id('"+   e.getUuid()+"', instance('" +  getFormElementInstanceIDREF(e) +"'))/row[index('" + e.getUuid()+ "')]/column["+ index +"]/answer";
	}
	public static String getComplexTableColumnBindXPath(TableElement e, int index)
	{
		//return getXpathRef(getFormElementInstanceIDREF(e), "/complex-table[@id='"+ e.getUuid() + "']/row/column["+ index +"]/answer");
		return "id('" +  e.getUuid() + "', instance('" + getFormElementInstanceIDREF(e) + "'))/row/column["+ index +"]/answer";
	}
	
	public static String getRepeatElementId(FormElement f)
	{
		return f.getUuid();
	}
/*	public static String getQuestionAnswerXPath(String id,boolean isTableQuestion)
	{
		return getQuestionXPath(id,isTableQuestion) + "/answer";
	}
*/
	public static String getQuestionAnswerXPath(String id, boolean isReadOnly)
	{
		return getQuestionXPath(id, isReadOnly) + "/answer";
	}
	
	public static String getTableQuestionAnswerXPath(String tableId,String id)
	{
		return getTableQuestionXPath(tableId,id) + "/answer";
	}
	
	
/*	public static String getCrossFormSkipQuestionAnswerXPath(String id, boolean isTableQuestion, String answerValue)
	{
		return getCrossFormSkipQuestionXPath(id,isTableQuestion,answerValue);
	}
*/

	public static String getQuestionTextXPath(BaseQuestion q)
	{
		return getQuestionXPath(q, q.getParent().isReadonly()) + "/text";
	}
/*
	public static String getTableQuestionTextXPath(Question q)
	{
		return getXpathRef(getFormInstanceIDREF(), "/question[@id='" + getTableQuestionId(q.getFirstAnswer().getId().toString()) + "']/text");
	}
*/
	public static String getTableQuestionTextXPath(TableElement te)
	{
//		return getXpathRef(getFormElementInstanceIDREF(te), (te.getTableType().equals(TableType.SIMPLE) ? "/question-table" : "/complex-table")
//				+ "[@id='" + te.getUuid() + "']/text");
		return "id('" + te.getUuid() + "', instance('" + getFormElementInstanceIDREF(te) + "'))/text";
	}
	
/*
	public static String getQuestionTableTextXPath(Question q)
	{
		return getXpathRef(getFormInstanceIDREF(), "'/question-table[@id='" + q.getUuid() + "']/text");
	}
	*/
	public static String getShowInvalidErrorCaseID(String id)
	{
		return INVALID_SHOWERRMSG_IDPREFIX + id;
	}
	
	public static String getShowErrorBlockCaseID(String id)
	{
		return ERRBLOCK_SHOWERRMSG_IDPREFIX + id;
	}

	public static String getHideErrorBlockCaseID(String id)
	{
		return ERRBLOCK_HIDEERRMSG_IDPREFIX + id;
	}
	
	public static String getHideInvalidErrorCaseID(String id)
	{
		return INVALID_HIDEERRMSG_IDPREFIX + id;
	}
	
	public static String getItemDeleteTriggerBindID(FormElement fe)
	{
		return ITEM_DELETE_TRIGGER + fe.getUuid();
	}
	public static String getItemInsertTriggerBindID(FormElement fe)
	{
		return ITEM_INSERT_TRIGGER + fe.getUuid();
	}
	
	public static String getVisibleAttribute()
	{
		return "@visible";
	}

//	public static String getDataGroupXPath(String q)
//	{
//		return getXpathRef(getDataGroupInstanceIDREF(),
//				BACKSLASH + XFormsConstants.DATAGROUP_TAG + "[@id='" + getDataGroupIDREF(q) + "']");
//	}
	
//	public static String getDataGroupXPathIdFunction(String q)
	public static String getDataGroupXPath(String q)
	{
		return "id('" + getDataGroupIDREF(q) + "', instance('" + getDataGroupInstanceIDREF()+ "'))";
	}
	public static String getRequiredErrorMessageXPath(FormElement q)
	{
		return getRequiredErrorMessageXPath(q.getUuid());
	}
	
	public static String getRequiredErrorMessageXPath( String id )
	{
//		return getXpathRef(getContextSpecificErrorsInstanceIDREF(),
//				BACKSLASH + XFormsConstants.ERROR_TAG + "[@id='ERR-" + id + "']");
		return "id('ERR-" + id + "', instance('" + getContextSpecificErrorsInstanceIDREF() + "'))";

	}
	public static String getFormNameXPath()
	{
		return getXpathRef(getFormInstanceIDREF(), "/@name");
	}
	
	public static String getVisibility(FormElement fe)
	{
		// The XForms attribute ultimately used to determine the visibility of the question
		List<String> relevant = new ArrayList<String>();

		// Skip patterns associated with this question
		//List<FormElementSkip> skipPatterns = question.getQuestionSkip();
		FormElementSkipRule skipRule = fe.getSkipRule();
		String skipRuleLogicalOp = null;
		if(skipRule != null)
		{
			skipRuleLogicalOp = skipRule.getLogicalOp();
			List<QuestionSkipRule> skipPatterns = skipRule.getQuestionSkipRules();
			
			for ( QuestionSkipRule questionSkipRule : skipPatterns )
			{
				List<String> questionSkip = new ArrayList<String>();
	
				// Skip pattern details
				BaseSkipPatternDetail details = questionSkipRule.getDetails();
	            List<AnswerSkipRule> skipParts = questionSkipRule.getSkipParts();
	            String logicalOp = questionSkipRule.getLogicalOp();
	            for(AnswerSkipRule skipPart: skipParts)
	            {
	     			// The answer value that triggered the skip
	    			String skipAnswerValue = null;
	
	     			// Whether or not the skip is a cross-form skip
	    			// (i.e. whether the question that triggered the skip is an external question)
	    			boolean isCrossFormSkip = questionSkipRule.isExternalSkip(fe);
	  			
	    			//In the new model we should always reference question that triggered the skip
	   				skipAnswerValue = skipPart.getAnswerValue().getValue();
	    			BaseQuestion skipQuestion = details.getSkipTriggerQuestion();
	
	
	//    			}
	    			// Ignore skips with blank answer values - such skips contain corrupted data
	    			if ( StringUtils.isNotBlank( skipAnswerValue ) ) {
	    				// Construct the XPath for the skip pattern based on
	    				// whether or not this is a cross-form skip
	    				String questionAnswerXPath, relevantString = "";
	    				String rowUuid = questionSkipRule.getIdentifyingAnswerValue() == null ?
	    						null : questionSkipRule.getIdentifyingAnswerValue().getPermanentId();
	    				if ( isCrossFormSkip ) {
	    					questionAnswerXPath = XFormsUtils.getCrossFormSkipQuestionAnswerXPath(details.getSkipTriggerForm().getUuid(), rowUuid, skipQuestion.getUuid(), skipAnswerValue);
	    					relevantString = "count(" + questionAnswerXPath + ") >= 1";
	    				} else {
							questionAnswerXPath = rowUuid == null ?
	    							XFormsUtils.getQuestionAnswerXPath(skipQuestion)
	    							: XFormsUtils.getQuestionAnswerXPath(skipQuestion, rowUuid);
//	    					Do we need specify form here?
	    					relevantString = containsValueXpath(questionAnswerXPath,  skipAnswerValue);
	    				}
	
	    				//relevant.add( relevantString );
	    				questionSkip.add( relevantString );
	    			}
	            }
	            //join parts of the skip into one
	            String skipString =  null;
	            if(logicalOp != null)
	            {
	            	skipString = "("+ StringUtils.join(questionSkip," " + logicalOp.toLowerCase() + " " ) +")";
	            }
	            else
	            {
	            	//if logicalOp is null that means that there should be only one value
	            	if (questionSkip.size()>0)
	            	{
	            		skipString = questionSkip.get(0);
	            	}
	
	            }
	            if( skipString != null)
	            {
	            	relevant.add(skipString);
	            }
	
			}
		}
			String visibilityRule = null;
			if (skipRuleLogicalOp != null)
			{
				visibilityRule = "("+ StringUtils.join(relevant," " + skipRuleLogicalOp.toLowerCase() + " " ) +")";
			}
			else
			{
				visibilityRule = StringUtils.join( relevant, " and " );
			}
	
		return relevant.isEmpty() ? XFormsConstants.XFORMS_TRUE : visibilityRule;
	}
	
	public static String containsValueXpath(final String containerXpath, final String value) {
		String xPathCondition = String.format(CONTAINS_VALUE_XPATH_FIX, VALUE_SEPARATOR, containerXpath, value);
		return xPathCondition;
	}
	
	public static String getErrorVisibility(FormElement fe, int errorType)
	{
		if ( errorType == 1 ) // error type = REQUIRED
		{
			if ( ! fe.isRequired() ) return "false()";
			String questionDisplayString = getVisibility(fe);
			return StringUtils.join( new String[]{ "(", questionDisplayString , ")", " and ", "(", getAnyIsEmptyAnswerConditionXPath(fe), ")" });
		}
		
		// default case
		return "false()";
	}

	public static List<String> getReferencedQuestionIds( Element element, String attributeName ) {
		Attribute attribute = element.getAttribute( attributeName );
		
		String attributeValue = attribute != null ? attribute.getValue() : null;
		
		List<String> matches = new ArrayList<String>();
		
		if ( StringUtils.isNotBlank( attributeValue ) ){
			Matcher matcher = Pattern.compile("question\\[@id=\\'(.+?)\\'\\]",Pattern.CASE_INSENSITIVE).matcher( attribute.getValue() );
			
			while ( matcher.find() && matcher.groupCount() > 0 ) {
				
				String match = matcher.group(1);
				
				if ( match != null ) matches.add( match );
			}
		}
		return matches;
	}

	public static Element buildXFormsValueChangedActionElement(){
		return XFormsUIBuilder.createElement(new Element(XFormsConstants.ACTION_TAG, XFormsConstants.XFORMS_NAMESPACE),
				new Attribute[]{XFormsUtils.getAttribute("event", XFormsConstants.XFORMS_VALUE_CHANGED, XFormsConstants.EVENTS_NAMESPACE)});
	}

	public static boolean isEditableFormControlElement(Element element)
	{
		return ArrayUtils.contains(
				new String[]{XFormsConstants.SELECT1_TAG,
						     XFormsConstants.SELECT_TAG,
						     XFormsConstants.INPUT_TAG},
				element.getName() );
	}
	
	public static List<Element> getAllEditableFormControlElements(List<Element> elements) {
		List<Element> results = new ArrayList<Element>();
		for (Element element : elements) {
			if ( ! XFormsUtils.isEditableFormControlElement( element ) ) {					
				results.addAll(XFormsUtils.findEditableFormControlElements( element ));
			}  else {
				results.add(element);
			}
		}
		return results;
	}
	
	public static boolean isSelectableFormControlElement( Element element )
	{
		return StringUtils.contains( element.getName(), XFormsConstants.SELECT_TAG );
	}

	public static Attribute getAttribute(String name, String value, Namespace namespace)
	{
		Attribute attribute = new Attribute( name, value );
		if ( namespace != null ) attribute.setNamespace( namespace );
		return attribute;
	}
	
	public static String getDefaultXFormSubmitErrorMessage(){
		return getMessage( XFormsConstants.XFORMS_SUBMIT_ERROR_MESSAGE_KEY );
	}
	
	public static String getMessage( String key ) {
		return MESSAGES.getString( key );
		
	}
	
	
	
	public static  String baseNodesetXPathRef(String formModelInstanceId)
	{
		String xpath = "instance('" + formModelInstanceId + "')";
		return xpath;
	}
	public static String questionNodesetXPathRef(String id, String formModelInstanceId)
	{
//		String xpath = baseNodesetXPathRef(formModelInstanceId) + "/question[@id='"+id + "']";
		String xpath = "id('" + id + "', instance('" + formModelInstanceId+ "'))";
		return xpath;
	}
	
	public static String tableQuestionNodesetXPathRef(FormElement table, BaseQuestion q, String formModelInstance)
	{
		// the XPath is instance('instance-id')//question[@id='id']
//		String xpath = baseNodesetXPathRef(formModelInstanceId)
//		+ "/question-table[@id='" + tableId +"']"
//		+ "/question[@id='" + qId +"']";
		
		String xpath = "id('" + q.getUuid() + "', instance('" + formModelInstance + "'))";
		return xpath;
	}
	
	public static String tableQuestionRowNodesetXPathRef(FormElement table, BaseQuestion question, int qIndex, String formModelInstanceId)
	{
		// the XPath is instance('instance-id')//complex-table[@id='id']/row/column[index]
//		String xpath = baseNodesetXPathRef(formModelInstanceId)
//		+ "/complex-table[@id='" + tableId +"']"
//		+ "/row/column[" + qIndex +"]";
		String xpath = "id('" + table.getUuid() + "', instance('" + formModelInstanceId + "'))/row/column[" + qIndex +"]";
		return xpath;
	}
/*
	public static String answerNodesetXPathRefForExternalQuestionElement(ExternalQuestionElement qe, Answer a, String formModelInstanceId)
	{
		String id = null;
		if(qe.getLinkId() != null)
		{
			id = qe.getLinkId();
		}
		else
		{
			id = qe.getQuestion().getUuid();
		}
		String uuid = qe.getQuestion().getUuid();
		return questionNodesetXPathRef(uuid, formModelInstanceId) + "/answer[@id='" + a.getUuid() + "']";
	}
	public static String answerNodesetXPathRefForQuestionElement(com.healthcit.cacure.model.QuestionElement qe, Answer a, String formModelInstanceId)
	{
		String uuid = qe.getQuestion().getUuid();
		return questionNodesetXPathRef(uuid, formModelInstanceId) + "/answer[@id='" + a.getUuid() + "']";
	}
	
	public static String answerNodesetXPathRefForTableElement(TableElement te, Answer a, String formModelInstanceId)
	{
		String uuid = te.getUuid();
		return tableQuestionNodesetXPathRef(uuid, formModelInstanceId) + "/answer[@id='" + a.getUuid() + "']";		
	}
	*/
	public static String getAnswerNodesetXPathRef(ExternalQuestionElement qe, Answer a, String formModelInstanceId)
	{
		@SuppressWarnings("unused")
		String id = null;
		if(qe.getLinkId() != null)
		{
			id = qe.getLinkId();
		}
		else
		{
			id = qe.getQuestion().getUuid();
		}
		String uuid = qe.getQuestion().getUuid();
		return questionNodesetXPathRef(uuid, formModelInstanceId) + "/answer[@id='" + a.getUuid() + "']";
	}
	
	public static String getAnswerNodesetXPathRef(com.healthcit.cacure.model.QuestionElement qe, Answer a, String formModelInstanceId)
	{
		String uuid = qe.getQuestion().getUuid();
		return questionNodesetXPathRef(uuid, formModelInstanceId) + "/answer[@id='" + a.getUuid() + "']";
	}
	
	public static String getAnswerNodesetXPathRef(TableElement te, Answer a, int questionIndex, String formModelInstanceId)
	{
//		String tableUuid = te.getUuid();
//		String questionUuid = a.getQuestion().getUuid();
		String tableType = te.getTableType().name();
		if ( TableType.SIMPLE.name().equals( tableType ) )
			return tableQuestionNodesetXPathRef(te, a.getQuestion(), formModelInstanceId) + "/answer[@id='" + a.getUuid() + "']";
		else
			return tableQuestionRowNodesetXPathRef(te, a.getQuestion(), questionIndex, formModelInstanceId) + "/answer";
	}
	
	@SuppressWarnings("unchecked")
	public static List<Element> findEditableFormControlElements( Element parent ) {
		List<Element> editableElements = new ArrayList<Element>();
		Iterator<Element> iterator = parent.getDescendants( new ElementFilter() );
		while ( iterator.hasNext() ) {
			Element current = iterator.next();
			if ( isEditableFormControlElement( current ) ) {
				editableElements.add( current );
			}
		}
		
		return editableElements;
	}

	public static String getShowItemDeleteXPath(TableElement fe) {
//		Remember that we have one row that does not shown and do not got deleted. So row[3] is a wright condition
		//return getXpathRef(getFormElementInstanceIDREF(fe), "/complex-table[@id='"+ fe.getUuid() + "']/row[3]");
		return  "id('" + fe.getUuid() + "', instance('" + getFormElementInstanceIDREF(fe)  + "'))/row[3]";
	}
	
	public static String getReadOnlyFormId(String id)
	{
		return "read-only-"+ id;
	}
}
