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
package com.healthcit.cacure.businessdelegates.export;

import java.util.List;
import java.util.Set;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;

import org.springframework.beans.factory.annotation.Autowired;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.export.model.Cure;
import com.healthcit.cacure.export.model.Cure.Form;
import com.healthcit.cacure.export.model.Cure.Form.Content;
import com.healthcit.cacure.export.model.Cure.Form.LinkElement.SourceElement;
import com.healthcit.cacure.export.model.Cure.Module;
import com.healthcit.cacure.export.model.Cure.Module.Section;
import com.healthcit.cacure.export.model.Description;
import com.healthcit.cacure.export.model.FormElementType;
import com.healthcit.cacure.export.model.FormElementType.Categories;
import com.healthcit.cacure.export.model.QuestionElementType;
import com.healthcit.cacure.export.model.QuestionType;
import com.healthcit.cacure.export.model.SkipLogicalOpType;
import com.healthcit.cacure.export.model.SkipRuleType;
import com.healthcit.cacure.export.model.SkipsType;
import com.healthcit.cacure.export.model.TableElementType;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerSkipRule;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.AnswerValueConstraint;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.BaseSkipRule;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.FormSkipRule;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.QuestionSkipRule;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableQuestion;

public class DataExporter {
	@Autowired
	FormManager formManager;
	
	@Autowired
	ModuleManager moduleManager;
	
	
	public Cure constructModuleXML(long id)
	{
		com.healthcit.cacure.model.BaseModule module = moduleManager.getModule(id);
		
		com.healthcit.cacure.export.model.ObjectFactory jaxbFactory = new com.healthcit.cacure.export.model.ObjectFactory();
		Cure rootElement = jaxbFactory.createCure();
		
		List<Module> xmlModules = rootElement.getModule();
		
		Module xmlModule = new Module();
		xmlModule.setUuid(module.getUuid());
		xmlModule.setDescription(module.getComments());
		xmlModule.setModuleName(module.getDescription());
		if(!module.isLibrary())
		{
			xmlModule.setCompletionTime(((com.healthcit.cacure.model.Module)module).getCompletionTime());
		}
		xmlModule.setInsertCheckAllThatApplyForMultiSelectAnswers(module.isInsertCheckAllThatApplyForMultiSelectAnswers());
		xmlModule.setShowPleaseSelectOptionInDropDown(module.isShowPleaseSelectOptionInDropDown());
		xmlModules.add(xmlModule);
		List<Section> sections = xmlModule.getSection();
		List<BaseForm> forms = module.getForms();
		for(BaseForm form: forms)
		{
			Form xmlForm = processForm(form, rootElement);
			Section xmlSection = new Section();
			xmlSection.setOrder(form.getOrd());
			xmlSection.setRef(xmlForm);
			if(!form.isLibraryForm())
			{
				QuestionnaireForm qForm = (QuestionnaireForm)form;
				FormSkipRule formSkipRule = qForm.getFormSkipRule();
				
				SkipRuleType skipRuleType = null;
				if (formSkipRule != null)
				{
					skipRuleType = populateSkips(formSkipRule);
					if(skipRuleType != null)
					{
						xmlSection.setSkipRule(skipRuleType);
					}
				}
			}
			sections.add(xmlSection);
		}
		
		return rootElement;
	}
	
	public  Cure  constructFormXML( long id)
	{
		BaseForm qForm = formManager.getForm(id);


		com.healthcit.cacure.export.model.ObjectFactory jaxbFactory = new com.healthcit.cacure.export.model.ObjectFactory();
		Cure rootElement = jaxbFactory.createCure();
		processForm(qForm, rootElement);
		return rootElement;
		
	}

	
	private Form processForm(BaseForm qForm, Cure rootElement)
	{
		List<Form> forms = rootElement.getForm();
		Form form = new Form();
		forms.add(form);
		form.setName(qForm.getName());
		form.setId(qForm.getUuid());
		
		/* go over all the forElements and create objects for them in XML */
		List<FormElement> elements = qForm.getElements();
		
		
		List<Cure.Form.Content> xmlContentList = form.getContent();
		List<Cure.Form.LinkElement>xmlLinkList = form.getLinkElement();
		List<QuestionElementType> xmlQuestionElementList = form.getQuestionElement();
		List<TableElementType> xmlTableElementList = form.getTableElement();
		List<Cure.Form.ExternalQuestionElement>xmlExternalQuestionElementList = form.getExternalQuestionElement();
		for(FormElement element: elements)
		{
			
			
			/* Set Skips */
			SkipRuleType skipRuleType = null;
			FormElementSkipRule formElementSkipRule = element.getSkipRule();
			if (formElementSkipRule != null)
			{
				skipRuleType = populateSkips(formElementSkipRule);			
			}
			
			if (element instanceof ContentElement)
			{
				ContentElement contentElement = (ContentElement)element;
				Content content = new Content();
				content.setDisplayStyle(contentElement.getTypeAsString());
				content.setOrder(contentElement.getOrd());
				content.setDescription(contentElement.getDescription());
				content.setUuid(element.getUuid());
				if(skipRuleType != null)
				{
					content.setSkipRule(skipRuleType);
				}
				
				xmlContentList.add(content);
				
			}
			else if (element instanceof LinkElement)
			{
				LinkElement linkElement = (LinkElement) element;
				com.healthcit.cacure.export.model.Cure.Form.LinkElement xmlLinkElement = new com.healthcit.cacure.export.model.Cure.Form.LinkElement();
				xmlLinkElement.setLearnMore(linkElement.getLearnMore());
				xmlLinkElement.setOrder(linkElement.getOrd());
				xmlLinkElement.setUuid(linkElement.getUuid());
				xmlLinkElement.setDescription(linkElement.getDescription());
				FormElement sourceElement = linkElement.getSourceElement();
				SourceElement xmlSourceElement = new SourceElement();
				if (sourceElement instanceof QuestionElement)
				{
					QuestionElementType xmlFormElementType = constructQuestionElement((QuestionElement)sourceElement);
					xmlSourceElement.setQuestionElement(xmlFormElementType);
				}
				else if(sourceElement instanceof TableElement)
				{
					TableElementType xmlFormElementType = constructTableElement((TableElement)sourceElement);
					xmlSourceElement.setTableElement(xmlFormElementType);
				}
				
				xmlLinkElement.setSourceElement(xmlSourceElement);
				if(skipRuleType != null)
				{
					xmlLinkElement.setSkipRule(skipRuleType);
				}
				
				xmlLinkElement.setIsRequired(element.isRequired());
				xmlLinkList.add(xmlLinkElement);
			}
			else
			{ 
				FormElementType xmlElement = null;
				
				
				if(element instanceof QuestionElement)
				{
					xmlElement = constructQuestionElement((QuestionElement)element);
					xmlQuestionElementList.add((QuestionElementType)xmlElement);
				}
				else if(element instanceof TableElement)
				{
					xmlElement = constructTableElement((TableElement)element);
					xmlTableElementList.add((TableElementType)xmlElement);
					
				}
				else if (element instanceof ExternalQuestionElement)
				{
					xmlElement = new com.healthcit.cacure.export.model.Cure.Form.ExternalQuestionElement();
					setXmlElementProperties(xmlElement, element);
					com.healthcit.cacure.export.model.Cure.Form.ExternalQuestionElement xmlExternalElement = (com.healthcit.cacure.export.model.Cure.Form.ExternalQuestionElement)xmlElement;
					
					ExternalQuestionElement externalElement = (ExternalQuestionElement)element;
					xmlExternalElement.setExternalSource(externalElement.getExternalLinkSource().name());
					xmlExternalElement.setExternalLinkId(externalElement.getLinkId());
					xmlExternalElement.setExternalUuid(externalElement.getExternalUuid());
					xmlExternalElement.setQuestion(constructQuestion(externalElement.getQuestion()));
					xmlExternalQuestionElementList.add((Cure.Form.ExternalQuestionElement)xmlElement);
				}
				
				/* set skips if applicable */
				if(skipRuleType != null)
				{
					xmlElement.setSkipRule(skipRuleType);
				}
				
			
				/* Set categories */
				Set<Category> categories = element.getCategories();
				if(categories != null && categories.size()>0)
				{
					Categories xmlCategories = new Categories();
					List<FormElementType.Categories.Category> xmlCategoryList = xmlCategories.getCategory();
					for(Category category: categories)
					{
						FormElementType.Categories.Category xmlCategory = new FormElementType.Categories.Category();
						xmlCategory.setName(category.getName());
						xmlCategory.setDescription(category.getDescription());
						xmlCategoryList.add(xmlCategory);
					}
				}
				

			}
			
		}
		return form;
		
	}
	
	private SkipRuleType populateSkips(BaseSkipRule formElementSkipRule)
	{
		SkipRuleType skipRuleType = new SkipRuleType();
		SkipLogicalOpType skipLogicalOp = SkipLogicalOpType.fromValue(formElementSkipRule.getLogicalOp());
		skipRuleType.setLogicalOp(skipLogicalOp);
		List<com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule> questionSkipRules = skipRuleType.getQuestionSkipRule();
		
		List<QuestionSkipRule> questionSkips = formElementSkipRule.getQuestionSkipRules();
		for(QuestionSkipRule questionSkip: questionSkips)
		{
			
			com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule questionSkipRule = new com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule();
			String triggerQuestionUUID = questionSkip.getDetails().getSkipTriggerQuestion().getUuid();
			String triggerFormUUID = questionSkip.getDetails().getSkipTriggerForm().getUuid();
			questionSkipRule.setTriggerQuestionUUID(triggerQuestionUUID);
			questionSkipRule.setTriggerFormUUID(triggerFormUUID);
			questionSkipRules.add(questionSkipRule);
			
			if(questionSkip.getLogicalOp() != null)
			{
				questionSkipRule.setLogicalOp(SkipLogicalOpType.fromValue(questionSkip.getLogicalOp()));
				
			}
			List<AnswerSkipRule> answerSkips = questionSkip.getAnswerSkipRules();
			
			List<com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule.AnswerSkipRule> answerSkipRules = questionSkipRule.getAnswerSkipRule();
									
			for(AnswerSkipRule answerSkip: answerSkips)
			{
				answerSkip.getAnswerValue();
				com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule.AnswerSkipRule answerSkipRule = new com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule.AnswerSkipRule();
				answerSkipRule.setAnswerValueUUID(answerSkip.getAnswerValueId());
				long skipFormId = answerSkip.getFormId();
				BaseForm skipForm = formManager.getForm(skipFormId);
				answerSkipRule.setFormUUID(skipForm.getUuid());
				answerSkipRules.add(answerSkipRule);							
			}
		}
		return skipRuleType;
	}
	private void setXmlElementProperties(FormElementType xmlElement, FormElement element )
	{
		/* Set properties */
		xmlElement.setIsRequired(element.isRequired());
		
		//TODO Add read only attribute
		
		xmlElement.setUuid(element.getUuid());
		xmlElement.setOrder(element.getOrd());
		Description descriptions = new Description();
		descriptions.setMainDescription(element.getDescription());
		List<String> alternativeDescriptions = descriptions.getAlternateDescription();
		for(com.healthcit.cacure.model.Description description: element.getDescriptionList())
		{
			alternativeDescriptions.add(description.getDescription());
		}
		xmlElement.setDescriptions(descriptions);
		
		xmlElement.setLearnMore(element.getLearnMore());
	}
	private QuestionElementType constructQuestionElement(QuestionElement element)
	{
		//com.healthcit.cacure.export.model.Cure.Form.QuestionElement questionElement = new com.healthcit.cacure.export.model.Cure.Form.QuestionElement();
		QuestionElementType xmlQuestionElement = new QuestionElementType();
		/* set properties */
		setXmlElementProperties(xmlQuestionElement, element);
		
		QuestionElement qElement = (QuestionElement)element;
		Question question = qElement.getQuestion();
		
		QuestionType questionType = constructQuestion(question);
		xmlQuestionElement.setQuestion(questionType);
		return xmlQuestionElement;
	}
	
	private QuestionType constructQuestion(BaseQuestion question)
	{
		QuestionType questionType = new QuestionType();
		
		
		questionType.setShortName(question.getShortName());
		questionType.setAnswerType(question.getTypeAsString());
		questionType.setUuid(question.getUuid());
		
		com.healthcit.cacure.export.model.QuestionType.Answer xmlAnswer = constructAnswer(question);
		questionType.setAnswer(xmlAnswer);
		return questionType;
	}
	
	private TableElementType constructTableElement(TableElement element)
	{
		 TableElementType xmlTableElement = new TableElementType();
		 
		 /* set properties */
		 setXmlElementProperties(xmlTableElement, element);
		 xmlTableElement.setTableShortName(element.getTableShortName());
		 List<TableElementType.Question> xmlTableQuestions = xmlTableElement.getQuestion();
		 xmlTableElement.setTableType(element.getTableType().name());
		 List<? extends BaseQuestion> questions = element.getQuestions();
		 for (BaseQuestion question: questions)
		 {
			 TableQuestion tQuestion = (TableQuestion) question;
			 TableElementType.Question xmlQuestion = new TableElementType.Question();
			 xmlQuestion.setOrder(tQuestion.getOrd());
			 xmlQuestion.setShortName(tQuestion.getShortName());
			 xmlQuestion.setUuid(tQuestion.getUuid());
			 xmlQuestion.setAnswerType(tQuestion.getTypeAsString());
			 xmlQuestion.setIsIdentifying(tQuestion.isIdentifying());
			 Description descriptions = new Description();
			 descriptions.setMainDescription(((TableQuestion)question).getDescription());
			 xmlQuestion.setDescriptions(descriptions);
			 com.healthcit.cacure.export.model.QuestionType.Answer xmlAnswer = constructAnswer(question);
			 
			xmlQuestion.setAnswer(xmlAnswer);
			xmlTableQuestions.add(xmlQuestion);
		 }
		 
		 
		 
		 return xmlTableElement;
	}
	private com.healthcit.cacure.export.model.QuestionType.Answer constructAnswer(BaseQuestion question)
	{
		/*Populate answer */
		 Answer answer = question.getAnswer();
		 com.healthcit.cacure.export.model.QuestionType.Answer xmlAnswer = new com.healthcit.cacure.export.model.QuestionType.Answer();
		 xmlAnswer.setDescription(answer.getDescription());
		 xmlAnswer.setDisplayStyle(answer.getDisplayStyle());
		 xmlAnswer.setUuid(answer.getUuid());
		 xmlAnswer.setType(answer.getType().name());
		 AnswerValueConstraint constraint = answer.getConstraint();
		 if(constraint != null)
		 {
			 xmlAnswer.setValueConstraint(constraint.getValueAsString());
		 }
		 
			List<com.healthcit.cacure.export.model.QuestionType.Answer.AnswerValue> xmlAnswerValues = xmlAnswer.getAnswerValue();
//		 List<com.healthcit.cacure.export.model.QuestionType.Answer.AnswerValue> xmlAnswerValues = xmlAnswer.getAnswerValue();
		 List<AnswerValue> answerValues = answer.getAnswerValues();
		 for(AnswerValue answerValue: answerValues)
		 {
			com.healthcit.cacure.export.model.QuestionType.Answer.AnswerValue xmlAnswerValue = new com.healthcit.cacure.export.model.QuestionType.Answer.AnswerValue();
			xmlAnswerValue.setDescription(answerValue.getDescription());
			xmlAnswerValue.setOrder(answerValue.getOrd());
			xmlAnswerValue.setUuid(answerValue.getPermanentId());
			xmlAnswerValue.setValue(answerValue.getValue());
			xmlAnswerValue.setName(answerValue.getName());
			xmlAnswerValues.add(xmlAnswerValue);
		}
		return xmlAnswer;
	}
}
