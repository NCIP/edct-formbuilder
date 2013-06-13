/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.xforms.uicontrols.htmlcontrols;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.jdom.Attribute;
import org.jdom.Element;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.businessdelegates.beans.SkipAffecteesBean;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.BaseSkipPatternDetail;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ContentElement.ContentType;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableElement.TableType;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.xforms.XFormsConstants;
import com.healthcit.cacure.xforms.XFormsUIBuilder;
import com.healthcit.cacure.xforms.XFormsUtils;
import com.healthcit.cacure.xforms.uicontrols.XFormUIControl;

public abstract class HTMLXFormUIControl extends XFormUIControl
{
	protected FormElement formElement;
	protected static final String INCORRECT_FORMAT_MSG = "Incorrect format.";
	protected static final String ON_EMPTY_ANSWER_MSG = "You must provide an answer to this question.";
	
	public HTMLXFormUIControl(FormElement fe, QuestionAnswerManager qaManager)
	{
		this.formElement = fe;
		this.qaManager = qaManager;
	}

	abstract protected List<Element>getAnswerElements();

	/**
	 * default implementation assumes regular question text
	 * @return
	 */
	protected String getControlTextClass()
	{
		StringBuilder cssClass = new StringBuilder(100);
		cssClass.append(XFormsConstants.CSS_CLASS_QUESTION_TEXT);
		return cssClass.toString();
	}

	/**
	 * default implementation points to text of the question element in the main model instance
	 * @return
	 */
	protected String getControlTextRef()
	{
		String xpath = null;
		if(formElement instanceof LinkElement)
		{
			formElement = ((LinkElement)formElement).getSourceElement();
	    }
		if(formElement instanceof QuestionElement)
		{
			xpath = XFormsUtils.getQuestionTextXPath(((QuestionElement)formElement).getQuestion());
		}
		else if(formElement instanceof ExternalQuestionElement)
		{
			//this probably will change to use link id
			xpath = XFormsUtils.getQuestionTextXPath(((ExternalQuestionElement)formElement).getQuestion());
		}
		else if(formElement instanceof TableElement)
		{
			xpath = XFormsUtils.getTableQuestionTextXPath((TableElement)formElement);
		}
		else if(formElement instanceof ContentElement)
		{
			/* I am not even sure that this is belons here */
			xpath = XFormsUtils.getContentXPath(((ContentElement)formElement));
		}  

		return xpath;
	}

	/**
	 * returns a collection of XFORMs UI controls representing this control
	 * @return
	 */
	@Override
	public List<Element> getControlElements()
	{
		Element uiGroup = new Element(GROUP_TAG, XFORMS_NAMESPACE);
		uiGroup.setAttribute("ref",XFormsUtils.getDataGroupXPath( formElement.getUuid() ));

		setClassAttribute(uiGroup);
		
		uiGroup.addContent( getTopElements() );
		uiGroup.addContent( getAnswerElementsWithEmbeddedTags() );

		List<Element> elements = new ArrayList<Element>();
		elements.add(uiGroup);
		return elements;
	}

	private void setClassAttribute(Element uiGroup) {
		List<String> cssClasses = new ArrayList<String>();
		if (formElement.isRequired())
		{
			cssClasses.add(XFormsConstants.CSS_CLASS_REQUIRED_QUESTION);
		}
		// Set up any applicable styles
		if ( formElement instanceof ContentElement )
		{
			ContentType type = ((ContentElement) formElement).getType();
			if(type == null) {
				type = ContentElement.DEFAULT_TYPE;
			}
			cssClasses.add("hcit-content-" + type.toString().toLowerCase());
		} else {
			AnswerType answerType = null;
			if (formElement instanceof QuestionElement)
			{
				answerType = ((QuestionElement)formElement).getAnswerType();
			}
			else if (formElement instanceof ExternalQuestionElement)
			{
				answerType = ((ExternalQuestionElement)formElement).getAnswerType();
			}
			else if (formElement instanceof TableElement)
			{
				answerType = ((TableElement)formElement).getAnswerType();
			}
			cssClasses.add(getCssGroupClass(answerType.toString()));
		}

		Attribute classAttribute = uiGroup.getAttribute("class");
		if (classAttribute != null && StringUtils.isNotBlank(classAttribute.getValue()))
		{
			cssClasses.add(classAttribute.getValue());
		}
		uiGroup.setAttribute("class", StringUtils.join(cssClasses, " "));
	}

	/**
	 * this method generates top of the question control - The text of question +
	 * questions's learn more
	 * @return
	 */
	protected List<Element> getTopElements()
	{
		Element questionTextElement;
		questionTextElement = new Element(OUTPUT_TAG, XFORMS_NAMESPACE);
		questionTextElement.setAttribute(new Attribute("ref", getControlTextRef()));
		if ( formElement.isPureContent() ) {
			XFormsUIBuilder.addChild(
				questionTextElement,
					XFormsUIBuilder.createElement(
						new Element(LABEL_TAG,XFORMS_NAMESPACE), null, formElement.getDescription() ));
		} 

		List<Element> learnMore = getLearnMore();
		String cssClass = getControlTextClass();
		if (learnMore != null)  cssClass += (" " + CSS_CLASS_HAS_LEANRMORE);
		questionTextElement.setAttribute(new Attribute("class", cssClass));

		List<Element> eList = new ArrayList<Element>();
		eList.add( getErrorMessageBlock() );
		if ( formElement.isVisible() ) eList.add( questionTextElement );
		if ( learnMore != null && formElement.isVisible() ) eList.addAll(learnMore);
		return eList;

	}

	protected List<Element> getLearnMore()
	{
		String learnMore = formElement.getLearnMore();
		if (learnMore != null && learnMore.length() > 0)
		{
			String learnMoreId = "lmid-"+formElement.getUuid();
			String loadJavascript = XFORMS_DIALOG_SCRIPT
						.replace("XYZ", StringEscapeUtils.escapeXml(learnMore) )
						.replace("lmid-", learnMoreId);

			// generate simple JS
			Element spanElm = XFormsUIBuilder.createElement
			( new Element("span", XHTML_NAMESPACE),
					new Attribute[]{new Attribute("class","learnmore")});

			Element actionElm = XFormsUIBuilder.createElement
			( new Element("a", XHTML_NAMESPACE),
					new Attribute[]{new Attribute("href",loadJavascript),
				                    new Attribute("id",learnMoreId)});
			actionElm.setText("Need help?");

			spanElm.addContent(actionElm);

			LinkedList<Element> returnList = new LinkedList<Element>();
			returnList.add(spanElm);
			return returnList;
		}
		else
		{
			return null;
		}
	}

	protected Element getErrorMessageBlock()
	{
		Element switchElement = new Element( SWITCH_TAG, XFORMS_NAMESPACE );
		
		Element hideErrorBlockCaseElement = new Element( CASE_TAG, XFORMS_NAMESPACE );		
		hideErrorBlockCaseElement.setAttribute( "id", XFormsUtils.getHideErrorBlockCaseID(formElement.getUuid()));
		
		Element showErrorBlockCaseElement = new Element( CASE_TAG, XFORMS_NAMESPACE );		
		showErrorBlockCaseElement.setAttribute( "id", XFormsUtils.getShowErrorBlockCaseID( formElement.getUuid() ));
		
		Element genericErrorSwitchElement = new Element( SWITCH_TAG, XFORMS_NAMESPACE );
		
		Element hideErrorCaseElement = new Element( CASE_TAG, XFORMS_NAMESPACE );		
		hideErrorCaseElement.setAttribute( "id", XFormsUtils.getHideInvalidErrorCaseID(formElement.getUuid()));
		Element showErrorCaseElement = new Element( CASE_TAG, XFORMS_NAMESPACE );
		showErrorCaseElement.setAttribute( "id", XFormsUtils.getShowInvalidErrorCaseID( formElement.getUuid() ));				
		Element showErrorOutputElement = new Element( OUTPUT_TAG, XFORMS_NAMESPACE );		
		showErrorOutputElement.setAttribute( "class", XFORMS_SUBMIT_ERROR_CSS_CLASS );		
		showErrorOutputElement.setAttribute( "value", "'" + XFormsUtils.getMessage(XFORMS_ERROR_INVALID_ALERT_KEY) + "'");
		
		showErrorCaseElement.addContent( showErrorOutputElement );
		
		genericErrorSwitchElement.addContent( Arrays.asList( hideErrorCaseElement, showErrorCaseElement ));
		
		if ( formElement.isRequired() )
		{
			Element requiredErrorOutputElement = new Element( OUTPUT_TAG, XFORMS_NAMESPACE );		
			requiredErrorOutputElement.setAttribute( "class", XFORMS_SUBMIT_ERROR_CSS_CLASS );		
			requiredErrorOutputElement.setAttribute( "bind", XFormsUtils.getRequiredErrorIDREF(formElement));
			showErrorBlockCaseElement.addContent( requiredErrorOutputElement );
		}
		
		showErrorBlockCaseElement.addContent( genericErrorSwitchElement );
		
		switchElement.addContent( Arrays.asList( hideErrorBlockCaseElement, showErrorBlockCaseElement) );
		
		return switchElement;
	}

	protected Element createLabel(String text, String cssClass)
	{
		Element labelElement = createLabel(text);
		labelElement.setAttribute("class", cssClass);
		return labelElement;
	}


	protected Element createRefLabel(String xPathRef, String cssClass)
	{
		Element labelElem = createRefLabel(xPathRef);
		labelElem.setAttribute("class", cssClass);
		return labelElem;
	}

	/*protected List<Element> getAnswerElementsWithEmbeddedTags()
	{
		List<Element> list = getAnswerElements();

		
		if ( !list.isEmpty() )
		{
			BaseQuestion question = null;
			if (formElement instanceof QuestionElement)
			{
				question = ((QuestionElement)formElement).getQuestion();
			}
			else if(formElement instanceof ExternalQuestionElement)
			{
				question = ((ExternalQuestionElement)formElement).getQuestion();
			}
			else if(formElement instanceof TableElement)
			{
				question = ((TableElement)formElement).getFirstQuestion();
			}

			// ADD GENERIC ERROR MESSAGE TOGGLE ELEMENTS
			Attribute invalidEventAttribute = 
				new Attribute("event", "xforms-invalid");
			invalidEventAttribute.setNamespace(EVENTS_NAMESPACE);
			Attribute validEventAttribute = 
				new Attribute("event", "xforms-valid");
			validEventAttribute.setNamespace(EVENTS_NAMESPACE);
			
			Element invalidToggleElement = 
				new Element( TOGGLE_TAG, XFORMS_NAMESPACE);
			invalidToggleElement.setAttribute( invalidEventAttribute );
			invalidToggleElement.setAttribute( "case", XFormsUtils.getShowInvalidErrorCaseID( question.getParent().getUuid() ));
			
			Element validToggleElement = 
				new Element( TOGGLE_TAG, XFORMS_NAMESPACE);
			validToggleElement.setAttribute( validEventAttribute );
			validToggleElement.setAttribute( "case", XFormsUtils.getHideInvalidErrorCaseID( question.getParent().getUuid() ));
			
			// ADD ALERT ELEMENT
			//TODO Add alert message!!
			
			String alertMessage = formElement.isRequired() ?
					"if(normalize-space("+XFormsUtils.getQuestionAnswerXPath(question)+")='','You must provide an answer to this question.','Incorrect format.')" :
					"'Incorrect format.'";
			Element alertElement =
				XFormsUIBuilder.addChild(
				   XFormsUIBuilder.createElement( new Element(ALERT_TAG, XFORMS_NAMESPACE)),
				   XFormsUIBuilder.createElement( new Element(OUTPUT_TAG, XFORMS_NAMESPACE),
					 new Attribute[]{XFormsUtils.getAttribute("value", alertMessage, null)}));
					 
			for ( Element formElement : list )
			{
				List<Element> formElementList = null;
				// If the form element is not an editable element,
				// then search for the editable elements
				// within it (if any)
				if ( ! XFormsUtils.isEditableFormControlElement( formElement ) ) 
				{					
					formElementList = XFormsUtils.findEditableFormControlElements( formElement );
				} 
				else
				{
					formElementList = Arrays.asList( formElement );
				}
				
				for ( Element current : formElementList )
				{
					List<Element> childElements = new ArrayList<Element>();
					// alert element
					if ( XFormsUtils.isEditableFormControlElement( current ) )
						childElements.add( ( Element )alertElement.clone() );
						
					// error message block
					// Do NOT add an error message block to select elements
					// (we assume that select elements will always contain only valid entries)
					if ( ! XFormsUtils.isSelectableFormControlElement( current ) )
					{
						childElements.add( ( Element )invalidToggleElement.clone() );
						
						childElements.add( ( Element ) validToggleElement.clone() );
					}	
					
					if ( ! childElements.isEmpty() ) {
						current.addContent( childElements );
					}
				}

			}

			// ADD SKIP ACTIONS AS APPLICABLE
			Element actionElement = null;
			for ( BaseSkipPatternDetail affectee : question.getSkipAffectees() )
			{
				// Get the answer value which triggered the skip
//					String skipAnswerValue = affectee.getSkipTriggerValue();

//					String skipAnswerValue = affectee.getSkipTriggerValue();
			    //BaseSkipPattern affectedSkip = affectee.getSkip();
				QuestionSkipRule affectedSkip = affectee.getSkip();

			 // Get the question that owns (i.e. is affected by) the skip
			    Long skipOwnerId = affectee.getFormElementId();
			    if (skipOwnerId != null)
			    {
			        FormElement skipOwner = qaManager.getFormElement(skipOwnerId);
			        if (skipOwner != null && skipOwner.hasSameForm( formElement ) )
			        {

			        	@SuppressWarnings("unused")
						List<AnswerSkipRule> skipParts = affectedSkip.getSkipParts();

			        	@SuppressWarnings("unused")
			        	//Get all answerValues
			        	String logicalOp = affectedSkip.getLogicalOp();
			        	//if logicalOp is null then there is only one part to a skip
			        	
			        	// Get the XPath logical statement which controls the visibility of the skip owner
			        	String visibility = XFormsUtils.getVisibility(skipOwner);

			        	// Construct the full list of questions which will be hidden
			        	// if the skip owner is hidden.
			        	// This will be the list of affectees for the skip owner (List A),
			        	// the list of affectees for each of the List A affectees (List B),
			        	// the list of affectees for each of the List B affectees (List C), etc.
			        	Set<FormElement> affectees = qaManager.getAllPossibleSkipAffectees(skipOwner);
			        	                	
			        	List<Element> resetElements = new ArrayList<Element>();
			        	
			        	for ( FormElement element : affectees )
			        	{
			        		
			        		// Add the setvalue element which controls the visibility of the skip owner
			            	resetElements.add( 
			            			XFormsUIBuilder.createElement(
			            				new Element(SETVALUE_TAG,XFORMS_NAMESPACE),
											new Attribute[]{new Attribute("ref",XFormsUtils.getDataGroupXPath(element.getUuid()) + "/@visible"),
			            						new Attribute("value",visibility)}) 
			            	);
			        	
			            	// Add the setvalue element(s) which ensure that a question's answers
			            	// will be cleared out once the question is hidden
			            	if ( element.isTable() ) { 
			            		
			            		for ( Iterator<? extends BaseQuestion> it = ((TableElement)element).getQuestions().iterator(); it.hasNext(); ) {
			            			
			            			TableQuestion tableQuestion = (TableQuestion)it.next();
			            			
			            			resetElements.add(
			                				XFormsUIBuilder.createElement(new Element(SETVALUE_TAG,XFORMS_NAMESPACE),
			        								new Attribute[]{new Attribute("ref", XFormsUtils.getQuestionAnswerXPath( tableQuestion.getUuid())),
			        												new Attribute("value", "if(" + visibility + ",.,'')")})
			                    	);	                			
			            		}
			            		
			            	} else {
			            		BaseQuestion baseQuestion = null;
			            		if(element instanceof QuestionElement)
			            		{
			            			baseQuestion = ((QuestionElement)element).getQuestion();
			            		}
			            		else if (element instanceof ExternalQuestionElement)
			            		{
			            			baseQuestion = ((ExternalQuestionElement)element).getQuestion();
			            		}
			            		
			            		resetElements.add(
			        				XFormsUIBuilder.createElement(new Element(SETVALUE_TAG,XFORMS_NAMESPACE),
											new Attribute[]{new Attribute("ref", XFormsUtils.getQuestionAnswerXPath(baseQuestion.getUuid()) ),
															new Attribute("value", "if(" + visibility + ",.,'')")})
			            		);
			            		
			            	}
			            	
			        	}    	
			        	
			        	// Create a SETVALUE element for the skip owner
			        	Element setValueElement1 =
			        		XFormsUIBuilder.createElement(new Element(SETVALUE_TAG,XFORMS_NAMESPACE),
									new Attribute[]{new Attribute("ref",XFormsUtils.getDataGroupXPath(skipOwner.getUuid()) + "/@visible"),
			        					new Attribute("value",visibility)});
			        	
						// Identify the element in the Answer Elements list
						// which corresponds to these "setvalue" elements
			        	
						for ( Element inputElement : list )
						{
							// Only consider form control elements (SELECT1, SELECT and INPUT elements)
							if ( XFormsUtils.isEditableFormControlElement( inputElement ) )
							{

								String inputElementQuestionId = XFormsUtils.getReferencedQuestionIds( inputElement, "ref").get( 0 );

								List<String> setValueElementIds = XFormsUtils.getReferencedQuestionIds( setValueElement1, "value");

								if ( setValueElementIds.contains( inputElementQuestionId ) ) 
								{

									actionElement = XFormsUIBuilder.removeChildByName( inputElement, ACTION_TAG );

									if ( actionElement == null ) actionElement = XFormsUtils.buildXFormsValueChangedActionElement();

									XFormsUIBuilder.addChild( inputElement,
										XFormsUIBuilder.addChild( actionElement, resetElements.toArray( new Element[ resetElements.size() ] ) ));

									break;
								}
							}
						}
					}//end of if(question != null)
			    }
			}//end for
		}//end if (list empty
		return list;
	}*/



	protected String getSelectControlName()
	{
		return SELECT1_TAG;
	}

	// CSS

	protected String getBaseCssClass( Answer answer )
	{
		return "";
	}

	protected String getCssLabelClass(Answer answer) {
		String answerInputType = answer.getType().toString().toLowerCase();
		return XFormsConstants.LABEL_INPUT_CSS_CLASS_PREFIX + answerInputType; 
	}
	
	protected String getEntryCssClasses( Answer answer )
	{
		StringBuffer cssClass = new StringBuffer( this.getBaseCssClass( answer ) );

		// Add CSS class(es) for alignment, if applicable
		if ( StringUtils.equalsIgnoreCase( answer.getDisplayStyle(), Constants.HORIZONTAL ) ){
			cssClass.append( " " );
			cssClass.append( XFormsConstants.HORIZONTAL_CSS_CLASS );
		} else if ( StringUtils.equalsIgnoreCase( answer.getDisplayStyle(), Constants.VERTICAL ) ){
			cssClass.append( " " );
			cssClass.append( XFormsConstants.VERTICAL_CSS_CLASS );
		}
		
		// Add CSS class(es) for textarea fields if applicable
		if ( answer.getType().equals( AnswerType.TEXTAREA ) ) {
			cssClass.append( " " );
			cssClass.append( XFormsConstants.XFORMS_TEXTAREA_CSS_CLASS );
		}

		addAnswerLengthClass(answer, cssClass);

		//...(add any other CSS classes)...

		return cssClass.toString();
	}

	protected String getAnswerLengthClass(Answer answer) {
		StringBuffer stringBuffer = new StringBuffer();
		addAnswerLengthClass(answer, stringBuffer);
		return stringBuffer.toString();
	}
	
	protected void addAnswerLengthClass(Answer answer, StringBuffer cssClass) {
		if(StringUtils.isBlank(answer.getDisplayStyle())) return;
		/* Setting style for the length of the field */
		if ((StringUtils.equalsIgnoreCase( answer.getDisplayStyle(), XFormsConstants.LENGTH_SHORT ))) {
			cssClass.append( " " );
			cssClass.append( XFormsConstants.LENGTH_SHORT_CSS_CLASS_PREFIX );
			cssClass.append( answer.getType().toString().toLowerCase() );
		} else if ((StringUtils.equalsIgnoreCase( answer.getDisplayStyle(), XFormsConstants.LENGTH_MEDIUM ))) {
			cssClass.append( " " );
			cssClass.append( XFormsConstants.LENGTH_MEDIUM_CSS_CLASS_PREFIX );
			cssClass.append( answer.getType().toString().toLowerCase() );
		} else if ((StringUtils.equalsIgnoreCase( answer.getDisplayStyle(), XFormsConstants.LENGTH_LONG ))) {
			cssClass.append( " " );
			cssClass.append( XFormsConstants.LENGTH_LONG_CSS_CLASS_PREFIX );
			cssClass.append( answer.getType().toString().toLowerCase() );
		}
	}

	protected String getCssGroupClass(String answerType) {			
		if(answerType != null)	{
			return XFormsConstants.GROUP_INPUT_CSS_CLASS_PREFIX + answerType.toLowerCase();
		}
		return null;
	}
	
	protected Element getAlertElement(final FormElement fe) {
		String alertMessage = formElement.isRequired() ?
				"if(" + XFormsUtils.getAnyIsEmptyAnswerConditionXPath(fe) + ",'" + ON_EMPTY_ANSWER_MSG	+ "','" + INCORRECT_FORMAT_MSG + "')" 
				: "'" + INCORRECT_FORMAT_MSG + "'";
				
		Element alertElement =
			XFormsUIBuilder.addChild(
			   XFormsUIBuilder.createElement( new Element(ALERT_TAG, XFORMS_NAMESPACE)),
			   XFormsUIBuilder.createElement( new Element(OUTPUT_TAG, XFORMS_NAMESPACE),
				 new Attribute[]{XFormsUtils.getAttribute("value", alertMessage, null)}));
		return alertElement;
	}
	
	protected Element getInvalidEventElement(final FormElement formElement) {
		Attribute invalidEventAttribute = 
			new Attribute("event", "xforms-invalid");
		invalidEventAttribute.setNamespace(EVENTS_NAMESPACE);
		Element invalidToggleElement = 
			new Element( TOGGLE_TAG, XFORMS_NAMESPACE);
		invalidToggleElement.setAttribute( invalidEventAttribute );
		invalidToggleElement.setAttribute( "case", XFormsUtils.getShowInvalidErrorCaseID( formElement.getUuid() ));
		return invalidToggleElement;
	}
	
	protected Element getValidEventElement(final FormElement formElement) {
		Attribute validEventAttribute = 
			new Attribute("event", "xforms-valid");
		validEventAttribute.setNamespace(EVENTS_NAMESPACE);
		Element validToggleElement = 
			new Element( TOGGLE_TAG, XFORMS_NAMESPACE);
		validToggleElement.setAttribute( validEventAttribute );
		validToggleElement.setAttribute( "case", XFormsUtils.getHideInvalidErrorCaseID( formElement.getUuid() ));
		return validToggleElement;
	}
	
	protected Element getDataGroupVisabilityResetElement(final FormElement affectee) {
		return XFormsUIBuilder.createElement(
				new Element(SETVALUE_TAG,XFORMS_NAMESPACE),
					new Attribute[]{new Attribute("ref",XFormsUtils.getDataGroupXPath(affectee.getUuid()) + "/@visible"),
						new Attribute("value", XFormsUtils.getVisibility(affectee))}) ;
	}
	
	protected List<Element> getValueResetElements(final FormElement affectee) {
		/*<xforms:action ev:event="DOMActivate"
	        xxforms:iterate="instance('template-instance')/record/title">
	    <xforms:setvalue ref="context()"
	            value="instance('main-instance')/dummy"/>
	</xforms:action>*/
		List<Element> resetElements = new ArrayList<Element>();
		FormElement raffectee = (affectee instanceof LinkElement) ? ((LinkElement)affectee).getSourceElement() : affectee;
//		TODO We could just check visible attribute of appropriate data-group
		String visibility = XFormsUtils.getVisibility(affectee);
		if(raffectee instanceof TableElement && !TableType.SIMPLE.equals(((TableElement)raffectee).getTableType())) {
			List<AnswerValue> identifyingAnswerValues = ((TableElement)raffectee).getIdentifyingAnswerValues();
			for (AnswerValue identifyingAnswerValue : identifyingAnswerValues) {
				for (Iterator<? extends BaseQuestion> iterator = raffectee.getQuestions().iterator(); iterator.hasNext();) {
					TableQuestion question = (TableQuestion) iterator.next();
					if(question.isIdentifying()) {
						continue;
					}
					Element element = XFormsUIBuilder.createElement(new Element(SETVALUE_TAG,XFORMS_NAMESPACE),
							new Attribute[]{new Attribute("ref", XFormsUtils.getQuestionAnswerXPath(question, identifyingAnswerValue.getPermanentId()) ),
						new Attribute("value", "if(" + visibility + ",.,'')")});
					resetElements.add(element);
				}
			}
		} else {
			for (Iterator<? extends BaseQuestion> iterator = raffectee.getQuestions().iterator(); iterator.hasNext();) {
				BaseQuestion question = (BaseQuestion) iterator.next();
				Element element = XFormsUIBuilder.createElement(new Element(SETVALUE_TAG,XFORMS_NAMESPACE),
						new Attribute[]{new Attribute("ref", XFormsUtils.getQuestionAnswerXPath(question) ),
					new Attribute("value", "if(" + visibility + ",.,'')")});
				resetElements.add(element);
			}
		}
		return resetElements;
	}
	
	protected List<Element> getResetElements(final Collection<FormElement> affectees) {
		List<Element> resetElements = new ArrayList<Element>();
		for ( FormElement affectee : affectees )
    	{
    		
    		// Add the setvalue element which controls the visibility of the skip owner
//			Seems it's double work to set/reset visability. Same attribute we have in visible attribute of data-group 
//        	resetElements.add(getDataGroupVisabilityResetElement(affectee));
    	
        	// Add the setvalue element(s) which ensure that a question's answers
        	// will be cleared out once the question is hidden
        	resetElements.addAll(getValueResetElements(affectee));
        	
    	}
		return resetElements;
	}
	
	protected List<Element> addValidationElements(final FormElement formElement, final List<Element> list) {
		Element invalidToggleElement = getInvalidEventElement(formElement);
		Element validToggleElement = getValidEventElement(formElement);
		Element alertElement = getAlertElement(formElement);
				 
		for ( Element current : list )
		{
			List<Element> childElements = new ArrayList<Element>();
			// alert element
			if ( XFormsUtils.isEditableFormControlElement( current ) )
				childElements.add( ( Element )alertElement.clone() );
				
			// error message block
			// Do NOT add an error message block to select elements
			// (we assume that select elements will always contain only valid entries)
			if ( ! XFormsUtils.isSelectableFormControlElement( current ) )
			{
				childElements.add( ( Element )invalidToggleElement.clone() );
				
				childElements.add( ( Element ) validToggleElement.clone() );
			}	
			
			if ( ! childElements.isEmpty() ) {
				current.addContent( childElements );
			}
		}

		return list;
	}
	
	protected List<Element> addResetElements(final List<Element> list, final List<Element> resetElements) {
		for ( Element inputElement : list )
		{
			// Only consider form control elements (SELECT1, SELECT and INPUT elements)
			if ( XFormsUtils.isEditableFormControlElement( inputElement ) )
			{
				Element actionElement = XFormsUIBuilder.removeChildByName( inputElement, ACTION_TAG );
				if ( actionElement == null ) actionElement = XFormsUtils.buildXFormsValueChangedActionElement();
				for (Element resetElement : resetElements) {
					actionElement.addContent((Element) resetElement.clone());
				}
				XFormsUIBuilder.addChild( inputElement, actionElement);
			}
		}
		return list;
	}
	
	protected void addSkips(BaseQuestion question, Element... elements) {
		LinkedHashSet<Long> ids = new LinkedHashSet<Long>();
		for ( BaseSkipPatternDetail affectee : question.getSkipAffectees() )
		{
		 // Get the question that owns (i.e. is affected by) the skip
		    Long skipOwnerId = affectee.getFormElementId();
		    if (skipOwnerId != null)
		    {
		       ids.add(skipOwnerId);
		    }
		}//end for
		for (Long id : ids) {
			FormElement skipOwner = qaManager.getFormElement(id);
	        if (skipOwner != null && skipOwner.hasSameForm( formElement ) )
	        {
	        	// Get the XPath logical statement which controls the visibility of the skip owner
//	        	Visability is calculated for each element
//	        	String visibility = XFormsUtils.getVisibility(skipOwner);
	
	        	// Construct the full list of questions which will be hidden
	        	// if the skip owner is hidden.
	        	// This will be the list of affectees for the skip owner (List A),
	        	// the list of affectees for each of the List A affectees (List B),
	        	// the list of affectees for each of the List B affectees (List C), etc.
	        	SkipAffecteesBean sab = qaManager.getAllPossibleSkipAffectees(skipOwner);
	        	                	
	        	List<Element> resetElements = getResetElements(sab.getFormElements());
	        	/*Element setValueElement1 = getDataGroupVisabilityResetElement(skipOwner, visibility);
	        	resetElements.add(setValueElement1);*/
	        	addResetElements(Arrays.asList(elements), resetElements);
			}//end of if(question != null)
		}
	}
	
	protected List<Element> getAnswerElementsWithEmbeddedTags()
	{
		List<Element> list = getAnswerElements();
		if ( list.isEmpty() )
			return list;
		
		List<Element> editableElements = XFormsUtils.getAllEditableFormControlElements(list);
		addValidationElements(formElement, editableElements);
		
		return list;
	}
}
