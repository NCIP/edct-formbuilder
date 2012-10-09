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

import java.util.Arrays;
import java.util.EnumSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.namespace.QName;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.jdom.Attribute;
import org.jdom.Element;
import org.jdom.transform.JDOMResult;

import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.QuestionSkipRule;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.TableColumn;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableElement.TableType;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.xforms.model.Column;
import com.healthcit.cacure.xforms.model.ComplexAnswer;
import com.healthcit.cacure.xforms.model.Form;
import com.healthcit.cacure.xforms.model.QuestionElement;
import com.healthcit.cacure.xforms.model.Row;


/**
 *
 * @author lkagan
 *
 */
public class XFormModel implements XFormsConstants
{
	private static final String CHECK_ALL_THAT_APPLY = "Check all that apply.";

	List<Element> bindings = new LinkedList<Element>();

	Element docHead;
	Element xformModelElement;
	Form formModelRoot;
	Form readOnlyFormModelRoot;
	Element formModelInstance; // DOM node for main model definition
//	Element learnMoreDataInstance; // DOM node to store learn more texts
	Element contentDataInstance; // DOM node to store pure content texts
	Element dataGroupInstance; // DOM node to store XForm groups which reference each question in the form
	Element crossFormSkipsInstance; // DOM node to store external skips
	Element urlInstance; // DOM node to store the Submission Action URL
	Element contextSpecificErrorsInstance;
	Element viewInstance; // DOM node to store dummy content for views
	Element readOnlyInstance; //DOM node to store form Elements that are read only.
	
	// I am very explicit here on the factory type
	com.healthcit.cacure.xforms.model.ObjectFactory jaxbFactory = new com.healthcit.cacure.xforms.model.ObjectFactory();
	Marshaller jaxbMarshaller;


	public XFormModel(Element headElement) throws JAXBException
	{
		this.docHead = headElement;
		xformModelElement = new Element(MODEL_TAG, XFORMS_NAMESPACE);
		createSchema();
		this.docHead.addContent(xformModelElement);

		// setting up marshaler
	  	JAXBContext jc = JAXBContext.newInstance( "com.healthcit.cacure.xforms.model" );
	  	jaxbMarshaller = jc.createMarshaller();
		jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
		jaxbMarshaller.setProperty(Marshaller.JAXB_FRAGMENT, Boolean.TRUE);
		// must do some weird mapping in order to get most of the namespaces out of the generated XML
		jaxbMarshaller.setProperty("com.sun.xml.bind.namespacePrefixMapper", new XFormsGeneratorJaxbNamespacePrefixMpper());


	}

	public void createSchema()
	{
		Element schema = new Element("schema", XSD_NAMESPACE);
		schema.addNamespaceDeclaration(HCIT_NAMESPACE);
		schema.addNamespaceDeclaration(XSD_NAMESPACE);
		schema.setAttribute("targetNamespace", HCIT_NAMESPACE.getURI());
		xformModelElement.addContent(schema);
	}
	/*
	public void add(Question q)
	{
		addDataGroupsToModel( q );
		addContextSpecificErrorsToModel( q );
		addQuestionElementToSection( q );
//		addLearnMoreReference( q );
	}
*/
	public void add(FormElement fe)
	{
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
		binding.setAttribute("nodeset", "@id");
		binding.setAttribute("type", "xsd:ID");
		bindings.add(binding);
		addViewsElementToModel(fe);
		addDataGroupsToModel(fe);
		addContextSpecificErrorsToModel( fe );
		addFormElementToSection(fe);
	}

	private void addViewsElementToModel(FormElement fe) {
		if(fe instanceof TableElement && TableType.DYNAMIC.equals(((TableElement)fe).getTableType())) {
			Element deleteTrigger = new Element(ITEM_DELETE_MODEL_TAG);
			deleteTrigger.setAttribute("id", XFormsUtils.ITEM_DELETE_TRIGGER + fe.getUuid());
			Element insertTrigger = new Element(ITEM_INSERT_MODEL_TAG);
			insertTrigger.setAttribute("id", XFormsUtils.ITEM_INSERT_TRIGGER +fe.getUuid());
			viewInstance.addContent(deleteTrigger);
			viewInstance.addContent(insertTrigger);
			
			Element bindDelete = new Element(BIND_TAG, XFORMS_NAMESPACE);
			bindDelete.setAttribute("id", XFormsUtils.getItemDeleteTriggerBindID(fe));
			bindDelete.setAttribute("nodeset", XFormsUtils.getItemDeleteXPath(fe));
			
			Element bindInsert = new Element(BIND_TAG, XFORMS_NAMESPACE);
			bindInsert.setAttribute("id", XFormsUtils.getItemInsertTriggerBindID(fe));
			bindInsert.setAttribute("nodeset", XFormsUtils.getItemInsertXPath(fe));
			if(fe.isReadonly())
			{
				bindInsert.setAttribute("relevant", "false()");
				bindDelete.setAttribute("relevant", "false()");
			}
			else
			{
				bindDelete.setAttribute("relevant", XFormsUtils.getShowItemDeleteXPath((TableElement)fe));
//				bindInsert.setAttribute("relevant", XFormsUtils.getShowItemDeleteXPath((TableElement)fe));
			}
			bindings.add(bindDelete);
			bindings.add(bindInsert);
			
		}
	}

	/**
	 * write out XForms model
	 * @param writer
	 */

	public void createSectionModel(BaseForm form)
	{
		// create xforms structure
		formModelInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		xformModelElement.addContent(formModelInstance);
		formModelInstance.setAttribute("id", XFormsUtils.getFormInstanceIDREF());

//		Element learnMoreRootInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
//		xformModelElement.addContent(learnMoreRootInstance);
//		learnMoreRootInstance.setAttribute("id", XFormsUtils.getLearnMoreInstanceIDREF());
//		learnMoreDataInstance = new Element ("data");
//		learnMoreRootInstance.addContent(learnMoreDataInstance);

		Element contentRootInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		xformModelElement.addContent(contentRootInstance);
		contentRootInstance.setAttribute("id", XFormsUtils.getContentInstanceIDREF());
		contentDataInstance = new Element ("data");
		contentRootInstance.addContent(contentDataInstance);
		
		readOnlyInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		xformModelElement.addContent(readOnlyInstance);
		readOnlyInstance.setAttribute("id", XFormsUtils.getReadOnlyInstanceIDREF());
//		readOnlyInstance = new Element ("data");
//		readonlyRootInstance.addContent(readOnlyInstance);

		Element dataGroupRootInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		xformModelElement.addContent(dataGroupRootInstance);
		dataGroupRootInstance.setAttribute("id", XFormsUtils.getDataGroupInstanceIDREF());
		dataGroupInstance = new Element ("data");
		dataGroupRootInstance.addContent(dataGroupInstance);

		Element crossFormSkipRootInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		xformModelElement.addContent( crossFormSkipRootInstance );
		crossFormSkipRootInstance.setAttribute("id", XFormsUtils.getCrossFormSkipInstanceIDREF());
		crossFormSkipsInstance = new Element("data");
		crossFormSkipRootInstance.addContent(crossFormSkipsInstance);

		Element urlRootInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		xformModelElement.addContent( urlRootInstance );
		urlRootInstance.setAttribute("id", XFormsUtils.getURLInstanceIDREF());
		urlInstance = new Element("data");
		urlRootInstance.addContent(urlInstance);
		
		Element contextSpecificErrorsRootInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		xformModelElement.addContent( contextSpecificErrorsRootInstance );
		contextSpecificErrorsRootInstance.setAttribute("id", XFormsUtils.getContextSpecificErrorsInstanceIDREF());
		contextSpecificErrorsInstance = new Element("data");
		contextSpecificErrorsRootInstance.addContent(contextSpecificErrorsInstance);
		
		Element viewInstanceRootInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		xformModelElement.addContent( viewInstanceRootInstance );
		viewInstanceRootInstance.setAttribute("id", XFormsUtils.getViewInstanceIDREF());
		viewInstance = new Element("data");
		viewInstanceRootInstance.addContent(viewInstance);

		// add root for section model
		formModelRoot = jaxbFactory.createForm();
		formModelRoot.setName(form.getName());
		formModelRoot.setId(form.getUuid());

		readOnlyFormModelRoot = jaxbFactory.createForm();
		readOnlyFormModelRoot.setName(form.getName());
		readOnlyFormModelRoot.setId(XFormsUtils.getReadOnlyFormId(form.getUuid()));
//		sectionInstance.appendChild(sectionRoot);
	}

	public void finalizeModel(BaseForm form)
	{
		// generate model instance
		try
		{
			// only JAXB Element can be serialized
			JAXBElement<Form> jaxbForm = jaxbFactory.createForm(formModelRoot);

			// marshal directly into JDOM results
			JDOMResult jDomResult = new JDOMResult();
			jaxbMarshaller.marshal(jaxbForm, jDomResult);
			@SuppressWarnings("rawtypes") List out = jDomResult.getResult();
			formModelInstance.addContent(out);

		}
		catch (JAXBException e)
		{
			throw new XFormsConstructionException(e);
		}
		
		try{
			JAXBElement<Form> jaxbForm = jaxbFactory.createForm(readOnlyFormModelRoot);
			JDOMResult jDomResult = new JDOMResult();
			jaxbMarshaller.marshal(jaxbForm, jDomResult);
			@SuppressWarnings("rawtypes") List out = jDomResult.getResult();
			readOnlyInstance.addContent(out);
		}
		catch (JAXBException e)
		{
			throw new XFormsConstructionException(e);
		}
		

		// add binding to model - do it here to make sure they are at the end
		for (Element e : bindings)
			xformModelElement.addContent(e);

		// add submission element
		Element submitElement = new Element(SUBMISSION_TAG, XFORMS_NAMESPACE);
		submitElement.setAttribute("id", SubmissionControls.SAVE.getIdRef());
		submitElement.setAttribute("method", "post");
		submitElement.setAttribute("includenamespaceprefixes", "");

		Element resourceElement = new Element(RESOURCE_TAG,XFORMS_NAMESPACE);
		resourceElement.setAttribute("value",XFormsUtils.getActionFullURLXPath());
		submitElement.addContent( resourceElement );

		Element submitErrMessageElement = new Element( MESSAGE_TAG, XFORMS_NAMESPACE);
		Attribute eventAttr = new Attribute("event", "xforms-submit-error");
		eventAttr.setNamespace(EVENTS_NAMESPACE);
		submitErrMessageElement.setAttribute(eventAttr);
//		submitErrMessageElement.setAttribute( Namespace.getNamespace("someONS", "someOtherNamespace"), DOMEVENT_NS_PREFIX + "event", "xforms-submit-error",);
//		submitErrMessageElement.setAttribute("level", "modal");
		submitErrMessageElement.setText( XFormsUtils.getDefaultXFormSubmitErrorMessage() );
		submitElement.addContent(submitErrMessageElement);
		addContextSpecificErrorMessageElements(submitElement, form);
		xformModelElement.addContent(submitElement);

		/* Add partial save button */
		Element partialSaveElement = new Element(SUBMISSION_TAG, XFORMS_NAMESPACE);
		partialSaveElement.setAttribute("id", SubmissionControls.SAVEFORLATER.getIdRef());
		partialSaveElement.setAttribute("method", "post");
		partialSaveElement.setAttribute("includenamespaceprefixes", "");
		partialSaveElement.setAttribute("validate", "false");

		Element submitPartialSaveErrElement = new Element( MESSAGE_TAG, XFORMS_NAMESPACE);
		Attribute eventAttrPartialSave = new Attribute("event", "xforms-submit-error");
		eventAttr.setNamespace(EVENTS_NAMESPACE);
		submitPartialSaveErrElement.setAttribute(eventAttrPartialSave);
		submitPartialSaveErrElement.setText( XFormsUtils.getDefaultXFormSubmitErrorMessage() );
		partialSaveElement.addContent(submitPartialSaveErrElement);
		partialSaveElement.addContent((Element)resourceElement.clone());
		addContextSpecificErrorMessageElements(partialSaveElement, form);
		xformModelElement.addContent(partialSaveElement);

	}

	private void addContextSpecificErrorMessageElements( Element submissionElement, BaseForm form )
	{
		for (FormElement fe : form.getElements() )
		{
			String formElementId = fe instanceof LinkElement ? ((LinkElement)fe).getSourceElement().getUuid() : fe.getUuid();
				
			////////////////////////////////////////////////////////////////////////
			// create toggle element to show error messages upon submission as appropriate
			/////////////////////////////////////////////////////////////////////
			Element toggle = new Element( TOGGLE_TAG, XFORMS_NAMESPACE );
			
			Attribute eventAttr = new Attribute("event", "xforms-submit-error");
			
			eventAttr.setNamespace( EVENTS_NAMESPACE );
			
			toggle.setAttribute(eventAttr);
		
			toggle.setAttribute( "case", XFormsUtils.getShowErrorBlockCaseID( formElementId ) );
			
			submissionElement.addContent( toggle );
		}
	}

	private void addContentReference(ContentElement ce)
	{
		Element contentElement = new Element(CONTENT_TAG);
		contentElement.setAttribute("id", XFormsUtils.getContentIDREF(ce));

		// Set the text to an empty string - the actual text will be coming from its label content.
		// This was done since currently, the LABEL tag handles HTML better
		contentElement.setText(EMPTY_STRING);

		// add to model
		contentDataInstance.addContent(contentElement);
	}

	public void addLookupInstance(BaseQuestion q)
	{
		Element lookupInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		lookupInstance.setAttribute("id", XFormsUtils.getQuestionAnswerSetInstanceIDREF(q.getUuid()));
		Element optionsInstance = new Element(LOOKUP_OPTIONS_TAG);
		if(q.getAnswer().getType() == AnswerType.DROPDOWN && q.getParent().getForm().getModule().isShowPleaseSelectOptionInDropDown()) {
			addAnswerElement("", PLEASE_SELECT_OPTION_TEXT, "\\xA0\\xA0", optionsInstance);
		}
		for (AnswerValue av: q.getAnswer().getAnswerValues())
		{
			addAnswerElement(av, optionsInstance);
		}

		lookupInstance.addContent(optionsInstance);

		xformModelElement.addContent(lookupInstance);
	}

	public void addTableLookupInstance(TableElement q)
	{
		Element lookupInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
		lookupInstance.setAttribute("id", XFormsUtils.getQuestionAnswerSetInstanceIDREF(q.getUuid()));
		Element optionsInstance = new Element(LOOKUP_OPTIONS_TAG);
		List<TableColumn> columns = q.getTableColumns();
		for (TableColumn column: columns)
		{
			addTableColumnElement(column, optionsInstance);
		}
		lookupInstance.addContent(optionsInstance);

		xformModelElement.addContent(lookupInstance);
	}
	
	public void addComplexTableLookupInstance(TableElement q)
	{
		List<? extends BaseQuestion>questions = q.getQuestions();
		for(BaseQuestion question: questions)
		{
			AnswerType answerType = question.getAnswer().getType();
			if(answerType.equals(AnswerType.DROPDOWN) || answerType.equals(AnswerType.CHECKMARK))
			{
				//create a new Lookup instance
				Element lookupInstance = new Element(INSTANCE_TAG, XFORMS_NAMESPACE);
				lookupInstance.setAttribute("id", XFormsUtils.getQuestionAnswerSetInstanceIDREF(question.getUuid()));
				Element optionsInstance = new Element(LOOKUP_OPTIONS_TAG);
				if(answerType.equals(AnswerType.DROPDOWN) && q.getForm().getModule().isShowPleaseSelectOptionInDropDown()) {
					addAnswerElement("", PLEASE_SELECT_OPTION_TEXT, "\\xA0\\xA0", optionsInstance);
				}
				List<AnswerValue> answerValues = question.getAnswer().getAnswerValues();
				for (AnswerValue answerValue: answerValues)
				{
						addAnswerElement(answerValue, optionsInstance);
				}
				lookupInstance.addContent(optionsInstance);

				xformModelElement.addContent(lookupInstance);
			}
		}
		
	}
	public void addDataGroupReference(FormElement q)
	{
		Element dataGroupElement = new Element(DATAGROUP_TAG);
		if (q instanceof LinkElement)
		{
			dataGroupElement.setAttribute("id",XFormsUtils.getDataGroupIDREF(((LinkElement) q).getSourceElement()));
		}
		else
		{
		    dataGroupElement.setAttribute("id",XFormsUtils.getDataGroupIDREF(q));
		}
		dataGroupElement.setAttribute("visible",XFormsUtils.getVisibility(q));
		dataGroupInstance.addContent( dataGroupElement );

	}
	
	public void addContextSpecificErrorReference(FormElement fe)
	{
		// ADD required error reference if applicable
		if (fe.isRequired() )
		{
			Element errorElement = new Element(ERROR_TAG);
			errorElement.setAttribute("id","ERR-" + fe.getUuid());
			errorElement.addContent( XFormsUtils.getMessage( XFORMS_ERROR_REQUIRED_ALERT_KEY ));
			contextSpecificErrorsInstance.addContent( errorElement );
		}
	}

	private void addCrossFormSkipReference(QuestionSkipRule skipPattern)
	{
		Element crossFormSkipElement = new Element(CROSSFORMSKIP_TAG);
		crossFormSkipElement.setAttribute( "id", skipPattern.getDetails().getSkipTriggerQuestion().getUuid() );
		crossFormSkipElement.setAttribute( "formId", skipPattern.getDetails().getSkipTriggerForm().getUuid());
		if(skipPattern.getIdentifyingAnswerValue() != null) {
			crossFormSkipElement.setAttribute( "rowId", skipPattern.getIdentifyingAnswerValue().getPermanentId());
		}
		crossFormSkipsInstance.addContent( crossFormSkipElement );
	}

	@SuppressWarnings("unused")
	private void addAnswerElementWithJaxb(AnswerValue av, Element optionsInstance)
	{
		com.healthcit.cacure.xforms.model.Answer xmlAnswer = jaxbFactory.createAnswer();
		xmlAnswer.setValue(av.getValue());
		xmlAnswer.setSn(av.getName());
		xmlAnswer.setText(av.getDescription());

		JAXBElement<com.healthcit.cacure.xforms.model.Answer> jaxbAnswer =
			new JAXBElement<com.healthcit.cacure.xforms.model.Answer>(
					new QName("answer"),
					com.healthcit.cacure.xforms.model.Answer.class,
					com.healthcit.cacure.xforms.model.Question.class, xmlAnswer);

		try
		{
			JDOMResult jDomResult = new JDOMResult();
			jaxbMarshaller.marshal(jaxbAnswer, jDomResult);
			@SuppressWarnings("rawtypes") List out = jDomResult.getResult();
			optionsInstance.addContent(out);
		}
		catch (JAXBException e)
		{
			throw new XFormsConstructionException(e);
		}
	}

	private void addAnswerElement(String name, String description, String value, Element optionsInstance) {
		Element xmlAnswer =  new Element("answer");
		xmlAnswer.setAttribute(new Attribute("sn", name));
		xmlAnswer.setAttribute(new Attribute("text", description));

		xmlAnswer.setText(value);

		optionsInstance.addContent(xmlAnswer);
	}
	
	private void addAnswerElement(AnswerValue av, Element optionsInstance) {
		addAnswerElement(av.getName(), av.getDescription(), av.getValue(), optionsInstance);
	}

	private void addTableColumnElement(TableColumn tc, Element optionsInstance)
	{
		Element xmlAnswer =  new Element("answer");
		xmlAnswer.setAttribute(new Attribute("text", tc.getHeading()));

		xmlAnswer.setText(tc.getValue());

		optionsInstance.addContent(xmlAnswer);

	}
/*
	private void addAnswerBinding(Question q, Answer a)
	{
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
		binding.setAttribute("nodeset", XFormsUtils.getAnswerNodesetXPathRef(q, a, formModelInstance.getAttribute("id").getValue(), q.isTableQuestion()));
		binding.setAttribute("id", XFormsUtils.getQuestionIDREF(q));
		binding.setAttribute("type", AnswerDataTypeConverter.toXmlType(a.getType()));
		Element customType = AnswerDataTypeConverter.createCustomTypeElement(a.getType());
		if (customType != null)
		{
			Element schema = xformModelElement.getChild("schema", XFormsConstants.XSD_NAMESPACE);
			if (schema == null)
			{
				createSchema();
			}
			schema.addContent(customType);

		}
		binding.setAttribute("required", (q.isRequired() ? XFormsUtils.getVisibility(q) : "false()" ));
		if(a.getConstraint() != null)
		{
		    binding.setAttribute("constraint", a.getConstraint().getXPathExpression("."));
		}
		bindings.add(binding);

	}
	*/
	private void addAnswerBindingQuestion(com.healthcit.cacure.model.QuestionElement qe, Answer a)
	{
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
//		binding.setAttribute("nodeset", XFormsUtils.getAnswerNodesetXPathRef(qe, a, formModelInstance.getAttribute("id").getValue()));
		binding.setAttribute("nodeset", XFormsUtils.getAnswerNodesetXPathRef(qe, a, XFormsUtils.getFormElementInstanceIDREF(qe)));
		binding.setAttribute("id", XFormsUtils.getQuestionIDREF(qe.getQuestion()));
		binding.setAttribute("type", AnswerDataTypeConverter.toXmlType(a.getType()));
		List<Element> customTypeElements = AnswerDataTypeConverter.createCustomTypeElements(a.getType());
		if (!CollectionUtils.isEmpty(customTypeElements))
		{
			Element schema = xformModelElement.getChild("schema", XFormsConstants.XSD_NAMESPACE);
			if (schema == null)
			{
				createSchema();
			}
			schema.addContent(customTypeElements);

		}
		if(qe.isRequired())
		{
			binding.setAttribute("required",XFormsUtils.getVisibility(qe));
		}
		if(a.getConstraint() != null && a.getConstraint().getValueAsString().length()>0)
		{
		    binding.setAttribute("constraint", a.getConstraint().getXPathExpression("."));
		}
		setReadOnlyFlagIfApplicable(qe, binding);
		bindings.add(binding);
		
	}
	
	private void addAnswerBindingExternalQuestion(ExternalQuestionElement qe, Answer a)
	{
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
		binding.setAttribute("nodeset", XFormsUtils.getAnswerNodesetXPathRef(qe, a,XFormsUtils.getFormElementInstanceIDREF(qe)));
		binding.setAttribute("id", XFormsUtils.getQuestionIDREF(qe.getQuestion()));
		binding.setAttribute("type", AnswerDataTypeConverter.toXmlType(a.getType()));
		List<Element> customTypeElements = AnswerDataTypeConverter.createCustomTypeElements(a.getType());
		if (!CollectionUtils.isEmpty(customTypeElements))
		{
			Element schema = xformModelElement.getChild("schema", XFormsConstants.XSD_NAMESPACE);
			if (schema == null)
			{
				createSchema();
			}
			schema.addContent(customTypeElements);

		}
		if(qe.isRequired())
		{
			binding.setAttribute("required", XFormsUtils.getVisibility(qe));
		}
		if(a.getConstraint() != null && a.getConstraint().getValueAsString().length()>0)
		{
		    binding.setAttribute("constraint", a.getConstraint().getXPathExpression("."));
		}
		setReadOnlyFlagIfApplicable(qe, binding);
		bindings.add(binding);
	}

//	private void addLearnMoreBinding(Question q)
//	{
//		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
//		binding.setAttribute("nodeset", XFormsUtils.getQuestionLearnMoreXPath(q) );
//		binding.setAttribute("id", XFormsUtils.getLearnMoreIDREF(q));
//		binding.setAttribute("relevant", "boolean-from-string(" + XFormsUtils.getVisibleAttribute() + ")");
//		bindings.add(binding);
//	}

	private void addDataGroupBindings(FormElement fe)
	{
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
		if(fe instanceof LinkElement)
		{
			//binding.setAttribute("nodeset", XFormsUtils.getDataGroupXPath( ((LinkElement)fe).getSourceElement().getUuid() ) );
			binding.setAttribute("nodeset", XFormsUtils.getDataGroupXPath( ((LinkElement)fe).getSourceElement().getUuid() ) );
		}
		else
		{
			//binding.setAttribute("nodeset", XFormsUtils.getDataGroupXPath( fe.getUuid() ) );
			binding.setAttribute("nodeset", XFormsUtils.getDataGroupXPath( fe.getUuid() ) );
		}
		
		binding.setAttribute("id", XFormsUtils.getDataGroupIDREF( fe) );
		String relevant = XFormsUtils.getVisibility(fe);
		if(!XFormsConstants.XFORMS_TRUE.equals(relevant))
		{
			binding.setAttribute("relevant",  relevant);
		}
		
		bindings.add(binding);
	}
	private void addExternalQuestionBinding(ExternalQuestionElement qe)
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
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
		binding.setAttribute("nodeset", XFormsUtils.questionNodesetXPathRef(id, XFormsUtils.getFormElementInstanceIDREF(qe)));
		binding.setAttribute("id", XFormsUtils.getQuestionIDREF(id));
		if(qe.isRequired())
		{
			binding.setAttribute("required", ( XFormsUtils.getVisibility(qe)));
		}
		setReadOnlyFlagIfApplicable(qe, binding);
		bindings.add(binding);
	}
	
	private void addContextSpecificErrorMessageBindings(FormElement fe)
	{
		// ADD required error binding if applicable
		if ( fe.isRequired() )
		{
			Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
			binding.setAttribute("nodeset", XFormsUtils.getRequiredErrorMessageXPath(fe));
			binding.setAttribute("id",XFormsUtils.getRequiredErrorIDREF(fe));
			binding.setAttribute("relevant", XFormsUtils.getErrorVisibility(fe,1));
			bindings.add(binding);
		}
	}

	private void addQuestionBinding(com.healthcit.cacure.model.QuestionElement q)
	{
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
		binding.setAttribute("nodeset", XFormsUtils.questionNodesetXPathRef(q.getUuid(),XFormsUtils.getFormElementInstanceIDREF(q)));
		binding.setAttribute("id", XFormsUtils.getQuestionIDREF(q.getQuestion()));
		if(q.isRequired())
		{
			binding.setAttribute("required", XFormsUtils.getVisibility(q));
		}
		setReadOnlyFlagIfApplicable(q, binding);
		bindings.add(binding);
	}
	
	/*
	private void addTableQuestionBinding(Answer a)
	{
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
		binding.setAttribute("nodeset", XFormsUtils.getAnswerNodesetXPathRef(a.getQuestion(),a,formModelInstance.getAttribute("id").getValue(),true));
		binding.setAttribute("id", XFormsUtils.getQuestionIDREF(a.getId().toString()));
		binding.setAttribute("required", (a.getQuestion().isRequired() ? XFormsUtils.getVisibility(a.getQuestion()) : "false()"));

		bindings.add(binding);
	}
*/
	private void addTableQuestionBinding(TableElement table,TableQuestion q)
	{
		Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
		binding.setAttribute("nodeset", XFormsUtils.tableQuestionNodesetXPathRef(table,q, XFormsUtils.getFormElementInstanceIDREF(table)) + "/answer[1]");
		binding.setAttribute("id", XFormsUtils.getQuestionIDREF(q));
		if(table.isRequired())
		{
			binding.setAttribute("required", XFormsUtils.getVisibility(table) );
		}
		setReadOnlyFlagIfApplicable(table, binding);
		bindings.add(binding);
	}
	
	private void addComplexTableBinding(TableElement table)
	{
		List<? extends BaseQuestion> questions = table.getQuestions();
		for(int i=0; i<questions.size(); i++)
		{
			Element binding = new Element(BIND_TAG, XFORMS_NAMESPACE);
			binding.setAttribute("nodeset", XFormsUtils.getComplexTableColumnXPathRepeat(table, i+1));
			TableQuestion q = (TableQuestion)questions.get(i);
			binding.setAttribute("id", XFormsUtils.getComplexTableQuestionBindIDREF(q));
			if ((q.isIdentifying() && TableType.STATIC.equals(table.getTableType())) ||
				(i==0)){
				if(table.isRequired())
				{
					binding.setAttribute("required", XFormsUtils.getVisibility(table));
				}
			}
			binding.setAttribute("type", AnswerDataTypeConverter.toXmlType(q.getAnswer().getType()));
			Answer a = q.getAnswer();
			List<Element> customTypeElements = AnswerDataTypeConverter.createCustomTypeElements(a.getType());
			if (!CollectionUtils.isEmpty(customTypeElements))
			{
				Element schema = xformModelElement.getChild("schema", XFormsConstants.XSD_NAMESPACE);
				if (schema == null)
				{
					createSchema();
				}
				schema.addContent(customTypeElements);

			}
//			binding.setAttribute("required", (table.isRequired() ? XFormsUtils.getVisibility(qe) : "false()" ));
			if(a.getConstraint() != null && a.getConstraint().getValueAsString().length()>0)
			{
			    binding.setAttribute("constraint", a.getConstraint().getXPathExpression("."));
			}
			setReadOnlyFlagIfApplicable(table, binding);
			bindings.add(binding);
		}
	}	
	
	private void addFormElementToSection(FormElement fe)
	{
		List<QuestionElement> elements = formModelRoot.getQuestionOrQuestionTableOrComplexTable();
		List<QuestionElement> readOnlyElements = readOnlyFormModelRoot.getQuestionOrQuestionTableOrComplexTable();

		if(fe instanceof LinkElement)
		{
			fe = ((LinkElement)fe).getSourceElement();
		}
		if (fe instanceof ContentElement)
		{
			addContentReference((ContentElement)fe);
		}
		else
		{
			QuestionElement element = null;
			if(fe instanceof com.healthcit.cacure.model.QuestionElement)
			{
				element = addQuestionToSection((com.healthcit.cacure.model.QuestionElement)fe);
				//elements.add(element);
			}
			else if(fe instanceof ExternalQuestionElement)
			{
				element = addExternalQuestionToSection((ExternalQuestionElement)fe);
				//elements.add(element);
			}
			else if(fe instanceof TableElement)
			{
				element = null;
				if (TableType.SIMPLE.equals(((TableElement) fe).getTableType()))
				{
					element = addTableToSection((TableElement)fe);
				}
				else
				{
					element = addComplexTableToSection((TableElement)fe);
				}
				//elements.add(element);
			}
			if(fe.isReadonly())
			{
				//add elements to readonly instance
				readOnlyElements.add(element);
			}
			else
			{
				elements.add(element);
			}
		}
		
	}
	private void addDataGroupsToModel(FormElement fe)
	{
		addDataGroupBindings( fe );
		addDataGroupReference(fe);
	}

	private void addContextSpecificErrorsToModel(FormElement fe)
	{
		FormElement sourceElement =fe;
		if(fe instanceof LinkElement)
		{
			sourceElement =((LinkElement)fe).getSourceElement();
		}
		addContextSpecificErrorMessageBindings(sourceElement);
		addContextSpecificErrorReference(sourceElement);
	}
	public void addCrossFormSkipsToModel( QuestionnaireForm form )
	{
		List<QuestionSkipRule> skip = form.getCrossFormSkips();
		for ( Iterator<QuestionSkipRule> iterator = skip.iterator(); iterator.hasNext(); ) {
			QuestionSkipRule skipPattern = iterator.next();
			addCrossFormSkipReference( skipPattern );
		}
	}

	public void addURLInstanceToModel( BaseForm form )
	{
		Element baseUrlTag = new Element( ACTIONBASEURL_TAG );
		baseUrlTag.addContent( ACTION_URL );
		Element fullUrlTag = new Element( ACTIONFULLURL_TAG );
		fullUrlTag.addContent( ACTION_URL );
		urlInstance.addContent( Arrays.asList( baseUrlTag, fullUrlTag ));
	}

	/**
	 * There are 3 distinct types on non-table questions:
	 *  1. Single Answer/Value (such as text, date, e-mail, etc.)
	 *  2. Multi-choice single answer (radio buttons or drop down)
	 *  3. Multi-choice multi answer (check boxes, multi-select)
	 *  All of them require different approaches for XForms.
	 *  For Type 1 and 2 a single answer element should be added to the form model
	 *  For Types 2 and 3 a lookup instance is required
	 *  For Type 3 a final answer model must be inserted at run time as part of xforms:itemset processing
	 *
	 * @param questionElement
	 * @return
	 */
	private QuestionElement addQuestionToSection(com.healthcit.cacure.model.QuestionElement questionElement)
	{
		com.healthcit.cacure.xforms.model.Question xmlQuestion = jaxbFactory.createQuestion();
		xmlQuestion.setId(questionElement.getQuestion().getUuid());
		xmlQuestion.setSn(questionElement.getQuestion().getShortName());
		String questionText = questionElement.getDescription();
		// All questions must have at least one answer
		Answer firstDataAnswer = questionElement.getQuestion().getAnswer();
		
		AnswerType answerType = firstDataAnswer.getType();
		if(answerType == AnswerType.CHECKBOX && 
				questionElement.getForm().getModule().isInsertCheckAllThatApplyForMultiSelectAnswers()) {
			questionText = StringUtils.isNotBlank(questionText) ? questionText + " " + CHECK_ALL_THAT_APPLY : CHECK_ALL_THAT_APPLY; 
		}
		xmlQuestion.setText(questionText);

		List<com.healthcit.cacure.xforms.model.Answer> xmlAnswers = xmlQuestion.getAnswer();
		com.healthcit.cacure.xforms.model.Answer xmlDataAnswer = dataAnswerToXML(firstDataAnswer);
		xmlAnswers.add(xmlDataAnswer);
		addAnswerBindingQuestion(questionElement, firstDataAnswer);
		if(EnumSet.of(AnswerType.RADIO, AnswerType.DROPDOWN, AnswerType.CHECKBOX).contains(answerType)) {
			addLookupInstance(questionElement.getQuestion());
			if (answerType == AnswerType.CHECKBOX) {
				addQuestionBinding(questionElement);
				setDefaultMultiAnswerValues(firstDataAnswer, xmlDataAnswer);
			} else {
				if(answerType == AnswerType.DROPDOWN && questionElement.getForm().getModule().isShowPleaseSelectOptionInDropDown()) {
					xmlDataAnswer.setValue("\\xA0\\xA0");
				}
				setDefaultSingleAnswerValue(firstDataAnswer, xmlDataAnswer);
			}
		}
		
		return xmlQuestion;
	}

	private void setDefaultSingleAnswerValue(Answer firstDataAnswer, com.healthcit.cacure.xforms.model.Answer xmlDataAnswer) {
		List<AnswerValue> answerValues = firstDataAnswer.getAnswerValues();
		if(answerValues != null) {
			for (AnswerValue answerValue : answerValues) {
				if(answerValue.isDefaultValue()) {
					xmlDataAnswer.setValue(answerValue.getValue());
					break;
				}
			}
		}
	}

	private void setDefaultMultiAnswerValues(Answer firstDataAnswer, com.healthcit.cacure.xforms.model.Answer xmlDataAnswer) {
		List<AnswerValue> answerValues = firstDataAnswer.getAnswerValues();
		StringBuffer sb = new StringBuffer();
		if(answerValues != null) {
			for (AnswerValue answerValue : answerValues) {
				if(answerValue.isDefaultValue()) {
					sb.append(answerValue.getValue());
					sb.append(XFormsUtils.VALUE_SEPARATOR);
				}
			}
		}
		if(sb.length() > XFormsUtils.VALUE_SEPARATOR.length()) {
			sb.setLength(sb.length() - XFormsUtils.VALUE_SEPARATOR.length());
			xmlDataAnswer.setValue(sb.toString());
		}
	}

	private QuestionElement addExternalQuestionToSection(ExternalQuestionElement questionElement)
	{
		com.healthcit.cacure.xforms.model.Question xmlQuestion = jaxbFactory.createQuestion();
		/* If linkId is present then the element is still linked to the external resource we need to use external id,
		 * otherwise if question has been modified we should use uuid of the question.
		 */
		String linkId = questionElement.getLinkId();
		String id = null;
		if (linkId != null)
		{
			id = linkId;
		}
		else 
		{
			id = questionElement.getQuestion().getUuid();
		}
		xmlQuestion.setId(questionElement.getQuestion().getUuid());
//		xmlQuestion.setSn(questionElement.getShortName());
		xmlQuestion.setSn(questionElement.getQuestion().getShortName());
		// All questions must have at least one answer
		Answer firstDataAnswer = questionElement.getQuestion().getAnswer();
		
		String questionText = questionElement.getDescription();
		if(firstDataAnswer.getType() == AnswerType.CHECKBOX && 
				questionElement.getForm().getModule().isInsertCheckAllThatApplyForMultiSelectAnswers()) {
			questionText = StringUtils.isNotBlank(questionText) ? questionText + " " + CHECK_ALL_THAT_APPLY : CHECK_ALL_THAT_APPLY; 
		}
		xmlQuestion.setText(questionText);


		// Type 2:
		if (firstDataAnswer.getType() == AnswerType.RADIO || firstDataAnswer.getType() == AnswerType.DROPDOWN )
		{
			List<com.healthcit.cacure.xforms.model.Answer> xmlAnswers = xmlQuestion.getAnswer();
			com.healthcit.cacure.xforms.model.Answer xmlDataAnswer = dataAnswerToXML(firstDataAnswer);
			setDefaultSingleAnswerValue(firstDataAnswer, xmlDataAnswer);
			xmlAnswers.add(xmlDataAnswer);
			addAnswerBindingExternalQuestion(questionElement, firstDataAnswer);
			addLookupInstance(questionElement.getQuestion());
		}
		// Type 3
		else if (firstDataAnswer.getType() == AnswerType.CHECKBOX)
		{
			addExternalQuestionBinding(questionElement);
			List<com.healthcit.cacure.xforms.model.Answer> xmlAnswers = xmlQuestion.getAnswer();
			com.healthcit.cacure.xforms.model.Answer xmlDataAnswer = dataAnswerToXML(firstDataAnswer);
			setDefaultMultiAnswerValues(firstDataAnswer, xmlDataAnswer);
			xmlAnswers.add(xmlDataAnswer);
			addAnswerBindingExternalQuestion(questionElement, firstDataAnswer);
			addLookupInstance(questionElement.getQuestion());
		}
		// Type 1
		else
		{
			List<com.healthcit.cacure.xforms.model.Answer> xmlAnswers = xmlQuestion.getAnswer();
			xmlAnswers.add(dataAnswerToXML(firstDataAnswer));
			addAnswerBindingExternalQuestion(questionElement, firstDataAnswer);
		}

		return xmlQuestion;
	}

	private com.healthcit.cacure.xforms.model.Answer dataAnswerToXML(Answer dataAnswer)
	{
		com.healthcit.cacure.xforms.model.Answer xmlAnswer = jaxbFactory.createAnswer();
		//xmlAnswer.setText(dataAnswer.getDescription());
		//xmlAnswer.setSn(dataAnswer.getFirstAnswerValue().getName());
		//xmlAnswer.setId(dataAnswer.getId().toString());
		xmlAnswer.setId(dataAnswer.getUuid());
		return xmlAnswer;
	}

	/**
	 * Creating a <tablequestion><question/><question/></tablequestion> structure
	 * For data collection purposes each row of the question table (represented by
	 * single data answer object) can be treated as independent question with question text
	 * propagated from table question
	 * @param dataQuestion
	 * @return
	 */
	
	private QuestionElement addTableToSection(TableElement table)
	{
		com.healthcit.cacure.xforms.model.QuestionTable xmlQTable = jaxbFactory.createQuestionTable();
		xmlQTable.setId(table.getUuid());
		xmlQTable.setText(table.getDescription());
		xmlQTable.setSn(table.getTableShortName());
		List<com.healthcit.cacure.xforms.model.Question> xmlQuestions = xmlQTable.getQuestion();

 		// lookup data set is the same for all rows
		addTableLookupInstance(table);

		// here we are converting multiple answers to multiple questions
		for (BaseQuestion baseQuestion: table.getQuestions())
		{
			TableQuestion question = (TableQuestion)baseQuestion;
			com.healthcit.cacure.xforms.model.Question xmlQuestion = jaxbFactory.createQuestion();
			xmlQuestion.setId(question.getUuid());
			xmlQuestion.setSn(question.getShortName());
			xmlQuestion.setText(question.getDescription());
			// table questions may contain only RADIO or CHECKBOX typed answers
			// Type 2:
			//addTableQuestionBinding(question);
			Answer dataAnswer = baseQuestion.getAnswer();
			EnumSet<AnswerType> tableAnswerTypes = EnumSet.of(AnswerType.RADIO,
					AnswerType.CHECKBOX,
					AnswerType.TEXT,
					AnswerType.YEAR,
					AnswerType.NUMBER,
					AnswerType.DATE);
			if(!tableAnswerTypes.contains(dataAnswer.getType())) {
				throw new XFormsConstructionException("Invalid Answer type '" + dataAnswer.getType().name()
						+ "' for table question.answer: " +	 baseQuestion.getUuid() + "." + dataAnswer.getId().toString());
			}
			com.healthcit.cacure.xforms.model.Answer xmlDataAnswer = dataAnswerToXML(dataAnswer);
			if (dataAnswer.getType() == AnswerType.RADIO) {
				List<com.healthcit.cacure.xforms.model.Answer> xmlAnswers = xmlQuestion.getAnswer();
				xmlAnswers.add(xmlDataAnswer);
//				addTableQuestionBinding(dataAnswer);
			} else {
//				addTableQuestionBinding(dataAnswer);
				xmlQuestion.getAnswer().add(xmlDataAnswer);
			}

			addTableQuestionBinding(table,question);

			xmlQuestions.add(xmlQuestion);
		}

		return xmlQTable;
	}

	
	private QuestionElement addComplexTableToSection(TableElement table)
	{
		com.healthcit.cacure.xforms.model.ComplexTable xmlCTable = jaxbFactory.createComplexTable();
		xmlCTable.setText(table.getDescription());
		xmlCTable.setId(table.getUuid());
//		xmlQTable.setId(table.getUuid());
		xmlCTable.setSn(table.getTableShortName());
		List<Row>rows = xmlCTable.getRow();

 		// lookup data set is the same for all rows
		addComplexTableLookupInstance(table);
		List<AnswerValue> identifyingValues = null;
		for (BaseQuestion baseQuestion: table.getQuestions())
		{
			TableQuestion tableQuestion = (TableQuestion)baseQuestion;
			if(tableQuestion.isIdentifying())
			{
				identifyingValues = tableQuestion.getAnswer().getAnswerValues();
			}
		}
		
		boolean showPleaseSelectOptionInDropDown = table.getForm().getModule().isShowPleaseSelectOptionInDropDown();
		if(table.getTableType().equals(TableType.STATIC))
		{
			for(int i=0; i<identifyingValues.size(); i++)
			{
				Row xmlRow = jaxbFactory.createRow();
				AnswerValue identifyingAnswerValue = identifyingValues.get(i);
				xmlRow.setId(identifyingAnswerValue.getPermanentId());
				List<Column> columns = xmlRow.getColumn();
				for (BaseQuestion baseQuestion: table.getQuestions())
				{
					TableQuestion question = (TableQuestion)baseQuestion;
					Column xmlColumn = jaxbFactory.createColumn();
					xmlColumn.setQuestionId(baseQuestion.getUuid());
					xmlColumn.setQuestionSn(baseQuestion.getShortName());
					List<ComplexAnswer> answers = xmlColumn.getAnswer();
					Answer answer = question.getAnswer();
					ComplexAnswer cAnswer = new ComplexAnswer();
					cAnswer.setAnswerId(answer.getUuid());
					cAnswer.setSn(answer.getGroupName());
					cAnswer.setText(answer.getDescription());
					if(question.isIdentifying())
					{
						xmlColumn.setIsIdentifying(true);
						cAnswer.setValue(identifyingAnswerValue.getValue());
					} else if(answer.getType() == AnswerType.DROPDOWN) {
//						Make first value selected by default
						if(showPleaseSelectOptionInDropDown) {
							cAnswer.setValue("\\xA0\\xA0");
						} else {
							List<AnswerValue> answerValues = answer.getAnswerValues();
							if(CollectionUtils.isNotEmpty(answerValues)) {
								cAnswer.setValue(answerValues.get(0).getValue());
							}
						}
					} else {
						xmlColumn.setQuestionText(((TableQuestion)baseQuestion).getDescription());						
					}
					answers.add(cAnswer);
					columns.add(xmlColumn);
					
				}
				rows.add(xmlRow);
			}
		}
		else
		{
			Row xmlRow = jaxbFactory.createRow();
			for (BaseQuestion baseQuestion: table.getQuestions())
			{
				TableQuestion question = (TableQuestion)baseQuestion;
				List<Column> columns = xmlRow.getColumn();
				Column xmlColumn = jaxbFactory.createColumn();
				xmlColumn.setQuestionId(baseQuestion.getUuid());
				xmlColumn.setQuestionSn(baseQuestion.getShortName());
				xmlColumn.setQuestionText((( TableQuestion )baseQuestion).getDescription());
				if(question.isIdentifying())
				{
					xmlColumn.setIsIdentifying(true);
				}
				List<ComplexAnswer> answers = xmlColumn.getAnswer();
				Answer answer = question.getAnswer();
				ComplexAnswer cAnswer = new ComplexAnswer();
				cAnswer.setAnswerId(answer.getUuid());
				cAnswer.setSn(answer.getGroupName());
				cAnswer.setText(answer.getDescription());
				if(answer.getType() == AnswerType.DROPDOWN) {
//					Make first value selected by default
					if(showPleaseSelectOptionInDropDown) {
						cAnswer.setValue("\\xA0\\xA0");
					} else {
						List<AnswerValue> answerValues = answer.getAnswerValues();
						if(CollectionUtils.isNotEmpty(answerValues)) {
							cAnswer.setValue(answerValues.get(0).getValue());
						}
					}
				}
				answers.add(cAnswer);
				columns.add(xmlColumn);
				
			}
			//Element templateRow = ;
			rows.add(xmlRow);
			//template row
			rows.add(xmlRow);
		}
		addComplexTableBinding(table);

		return xmlCTable;
	}
	private void setReadOnlyFlagIfApplicable(FormElement fe, Element binding)
	{
		if(fe.isReadonly())
		{
			binding.setAttribute("readonly", "true()");
		}
	}

}
