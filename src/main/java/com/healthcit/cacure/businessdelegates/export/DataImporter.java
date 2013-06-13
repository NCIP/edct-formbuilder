/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.businessdelegates.export;


import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.sf.json.JSONObject;

import org.apache.commons.lang.math.NumberUtils;
import org.springframework.beans.factory.annotation.Autowired;

import com.healthcit.cacure.businessdelegates.CategoryManager;
import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.dao.AnswerValueDao;
import com.healthcit.cacure.dao.FormElementDao;
import com.healthcit.cacure.export.model.Cure;
import com.healthcit.cacure.export.model.Cure.Form;
import com.healthcit.cacure.export.model.Cure.Form.Content;
import com.healthcit.cacure.export.model.Cure.Form.LinkElement.SourceElement;
import com.healthcit.cacure.export.model.Cure.Module.Section;
import com.healthcit.cacure.export.model.Description;
import com.healthcit.cacure.export.model.FormElementType;
import com.healthcit.cacure.export.model.FormElementType.Categories;
import com.healthcit.cacure.export.model.QuestionElementType;
import com.healthcit.cacure.export.model.QuestionType;
import com.healthcit.cacure.export.model.SkipLogicalOpType;
import com.healthcit.cacure.export.model.SkipRuleType;
import com.healthcit.cacure.export.model.TableElementType;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerSkipRule;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.AnswerValueConstraint;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.BaseSkipRule;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ExternalQuestion;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.FormSkipRule;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.QuestionSkipRule;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableQuestion;

public class DataImporter {

	@Autowired
	FormManager formManager;
	
	@Autowired
	CategoryManager categoryManager;
	
	@Autowired
	AnswerValueDao answerValueDao;
	
	@Autowired
	FormElementDao formElementDao;
	
	@Autowired
	QuestionAnswerManager qaManager;
	
	@Autowired
	ModuleManager moduleManager;
	

	/* imports modules */
	public void importModule(Cure cure, Map<String, String>existingModules, Map<String, String>existingForms, List<String> existingQuestions)
	{
		Map<String, Long> uuidMap = new HashMap<String, Long>();
		
		Map<String, Module> sectionsModuleMap = new HashMap<String, Module>();
		Map<String, Integer> sectionsOrderMap = new HashMap<String, Integer>();
		Map<String, SkipRuleType> formSkipsMap = new HashMap<String, SkipRuleType>();

		List<com.healthcit.cacure.export.model.Cure.Module> xmlModules = cure.getModule();
		for (com.healthcit.cacure.export.model.Cure.Module xmlModule: xmlModules)
		{
			String moduleUUID = xmlModule.getUuid();
			BaseModule baseModule = moduleManager.getModule(moduleUUID);
			if(baseModule!= null)
			{
				existingModules.put(moduleUUID, baseModule.getDescription());
				continue;
			}
			Module module = new Module();
			module.setUuid(xmlModule.getUuid());
			
			module.setDescription(xmlModule.getModuleName());
			module.setCompletionTime(xmlModule.getCompletionTime());
			module.setComments(xmlModule.getDescription());
			module.setShowPleaseSelectOptionInDropDown(xmlModule.isShowPleaseSelectOptionInDropDown());
			module.setInsertCheckAllThatApplyForMultiSelectAnswers(xmlModule.isInsertCheckAllThatApplyForMultiSelectAnswers());
			
			moduleManager.addNewModule(module);
			List<Section> xmlSections = xmlModule.getSection();
			for (Section xmlSection: xmlSections)
			{
				Form refForm = (Form)xmlSection.getRef();
				sectionsOrderMap.put(refForm.getId(), Integer.valueOf(xmlSection.getOrder()));
				sectionsModuleMap.put(refForm.getId(), module);
				formSkipsMap.put(refForm.getId(), xmlSection.getSkipRule());
			}
		}
		createForms(cure, sectionsOrderMap, sectionsModuleMap, formSkipsMap, uuidMap, existingForms, existingQuestions);
	}
	
	
	/* Imports forms into an existing module
	 * 
	 */
	public void importData(Cure cure, long moduleId, Map<String, String>existingForms, List<String> existingQuestions)
	{
		/* Maps the element's uuid with the skip in order to create skips later
		 * after all elements in all forms had been created
		 */
		Map<String, SkipRuleType> elementsToSkipMap = new HashMap<String, SkipRuleType>();
		Map<String, Long> uuidMap = new HashMap<String, Long>();
		BaseModule module = moduleManager.getModule(moduleId);
		List<Form> xmlForms = cure.getForm();
		List<BaseForm> qForms = module.getForms();
		int formOrder = 1;
		if(qForms!= null && qForms.size()>0)
		{
			formOrder = qForms.size() +1;
		}
		for (Form xmlForm: xmlForms)
		{
			String formUuid = xmlForm.getId();
			BaseForm storedForm = formManager.getForm(formUuid);
			if(storedForm != null)
			{
				/* if the form with the same uuid already exists in the system
				 * then we will not create this form
				 */
				existingForms.put(formUuid, storedForm.getName());
				continue;
			}
				
			QuestionnaireForm form = new QuestionnaireForm();
			form.setName(xmlForm.getName());
			form.setOrd(formOrder);
			form.setUuid(xmlForm.getId());
			
			/*store form first. 
			 * Create a map between UUID and new id in order to build skips correctly
			 * */
            form.setModule(module);
			formManager.addNewForm(form);
			uuidMap.put(xmlForm.getId(), form.getId());
			
			/* Increase order by one for the next form */
			formOrder++;
			
			addElementsToForm(form, xmlForm, existingQuestions, elementsToSkipMap);
			
		}
		/* now that all elements were created we can assign skips
		 *  There are no form skips to create because the concept of a form skip only exists when the whole module is imported
		 */
		for(String uuid: elementsToSkipMap.keySet())
		{
			FormElementSkipRule skipRule = new FormElementSkipRule();
	        createSkipRule(skipRule, elementsToSkipMap.get(uuid), uuidMap);
			if(skipRule.getQuestionSkipRules()!= null && skipRule.getQuestionSkipRules().size()>0)
			{
				FormElement formElement = qaManager.getFormElement(uuid);
				formElement.setSkipRule(skipRule);
				qaManager.saveFormElement(formElement);
			}
		}
	}
	
	/* Creates forms, a map of all forms
	 *  in order to cross check them with the sections and
	 *  to create form skips and assign order within the module
	 */
	private void createForms(Cure cure, Map<String, Integer>sectionsOrderMap, Map<String, Module> sectionsModuleMap, Map<String, SkipRuleType> formSkipsMap, Map<String, Long> uuidMap, Map<String, String>existingForms, List<String> existingQuestions)
	{
		Map<String, SkipRuleType> elementsToSkipMap = new HashMap<String, SkipRuleType>();
		
		List<Form> xmlForms = cure.getForm();
		for (Form xmlForm: xmlForms)
		{
			String formUuid = xmlForm.getId();
			BaseForm storedForm = formManager.getForm(formUuid);
			if(storedForm != null)
			{
				/* if the form with the same uuid already exists in the system
				 * then we will not create this form
				 */
				existingForms.put(formUuid, storedForm.getName());
				continue;
			}
			QuestionnaireForm form = new QuestionnaireForm();
			form.setName(xmlForm.getName());
			form.setOrd(sectionsOrderMap.get(xmlForm.getId()));
			
			/*store form first. 
			 * Create a map between old UUID and new one in order to build skips correctly
			 * */
            form.setModule(sectionsModuleMap.get(xmlForm.getId()));
            
			formManager.addNewForm(form);
			uuidMap.put(xmlForm.getId(), form.getId());
			
			/* add all form elements to the form */
			addElementsToForm(form, xmlForm, existingQuestions, elementsToSkipMap);
		}
		/* now that all elements are created we can assign skips 
		 * to those elements that have them
		 */
		for(String uuid: elementsToSkipMap.keySet())
		{
			FormElementSkipRule skipRule = new FormElementSkipRule();
	        createSkipRule(skipRule, elementsToSkipMap.get(uuid), uuidMap);
			if(skipRule.getQuestionSkipRules()!= null && skipRule.getQuestionSkipRules().size()>0)
			{
				FormElement formElement = qaManager.getFormElement(uuid);
				formElement.setSkipRule(skipRule);
				qaManager.saveFormElement(formElement);
			}
		}
		
		/* now that all forms and elements are created we can assign skips
		 * 
		 */
		for(String uuid: formSkipsMap.keySet())
		{
			FormSkipRule skipRule = new FormSkipRule();
			createSkipRule(skipRule, formSkipsMap.get(uuid), uuidMap);
			if(skipRule.getQuestionSkipRules()!= null && skipRule.getQuestionSkipRules().size()>0)
			{
				QuestionnaireForm form = (QuestionnaireForm)formManager.getForm(uuid);
				form.setFormSkipRule(skipRule);
			}
//			if(formSkipsMap.containsKey(xmlForm.getId()))
//	        {
//	        	assignSkips(form, formSkipsMap.get(xmlForm.getId()), uuidMap);
//	        }
		}
	}
	

	
//	private void executeIdChecks(Cure cure, Map<String, String> existingModules, Map<String, String> existingForms)
//	{
//		List<com.healthcit.cacure.export.model.Cure.Module> xmlModules = cure.getModule();
//		
//		/* checks if any of the modules and sections exist */
//		if(xmlModules!= null && xmlModules.size() >0)
//		{
//			for(com.healthcit.cacure.export.model.Cure.Module xmlModule: xmlModules)
//			{
//				String moduleUUID = xmlModule.getUuid();
//				BaseModule module = moduleManager.getModule(moduleUUID);
//				if(module != null)
//				{
//					existingModules.put(moduleUUID, module.getDescription());
//				}
//			    List<Section>xmlSections = xmlModule.getSection();
//			    for(Section xmlSection: xmlSections)
//			    {
//			    	Form xmlForm = (Form)xmlSection.getRef();
//			    	String formUUID = xmlForm.getId();
//			    	BaseForm form = formManager.getForm(formUUID);
//			    	if(form!= null)
//			    	{
//			    		existingForms.put(formUUID, form.getName());
//			    	}
//			    }
//			}
//		}
//		
//	}
//	/* checks for existing forms if xml does not contains the module information */
//	private void executeIdChecks(Cure cure, Map<String, String> existingForms)
//	{
//		List<Form> xmlForms = cure.getForm();
//		
//		if(xmlForms != null)
//		{
//			 for(Form xmlForm: xmlForms)
//			 {
//			   	String formUUID = xmlForm.getId();
//			   	BaseForm form = formManager.getForm(formUUID);
//			    if(form!= null)
//			    {
//			    	existingForms.put(formUUID, form.getName());
//			    }
//			 }
//		}
//	}
	private void addElementsToForm(QuestionnaireForm form, Form xmlForm, List<String> existingQuestions, Map<String, SkipRuleType>elementsToSkipMap)
	{
		/* add all content */
		//Map<String, SkipRuleType> elementsWithSkips = new HashMap<String, SkipRuleType>();
		List<Content> xmlContentList = xmlForm.getContent();
		for ( Content xmlContent: xmlContentList)
		{
			if(qaManager.getFormElement(xmlContent.getUuid())!= null)
			{
				existingQuestions.add(xmlContent.getUuid());
				continue;
			}
			ContentElement content = new ContentElement();
			content.setUuid(xmlContent.getUuid());
			content.setDescription(xmlContent.getDescription());
			content.setOrd(xmlContent.getOrder());
			content.setType(ContentElement.ContentType.valueOf(xmlContent.getDisplayStyle()));
			form.addElement(content);
			formManager.updateForm(form);
		}
		
		/*Add all QuestionElements */
		List<QuestionElementType> xmlQuestionElementList = xmlForm.getQuestionElement();
		for(QuestionElementType xmlQuestionElement: xmlQuestionElementList)
		{
			if(qaManager.getFormElement(xmlQuestionElement.getUuid())!= null)
			{
				existingQuestions.add(xmlQuestionElement.getUuid());
				continue;
			}
			QuestionElement questionElement = constructQuestionElement(xmlQuestionElement);
			assignCategories(questionElement, xmlQuestionElement.getCategories());
			if(xmlQuestionElement.getSkipRule()!=null)
			{
				elementsToSkipMap.put(questionElement.getUuid(), xmlQuestionElement.getSkipRule());
				//assignSkips(questionElement, xmlQuestionElement.getSkipRule(), uuidMap);
			}
			
			form.addElement(questionElement);
			formManager.updateForm(form);
			
		}
		
		/* Add table Element */
		List<TableElementType> xmlTableElementList = xmlForm.getTableElement();
		for(TableElementType xmlTableElement: xmlTableElementList)
		{
			if(qaManager.getFormElement(xmlTableElement.getUuid())!= null)
			{
				existingQuestions.add(xmlTableElement.getUuid());
				continue;
			}
			TableElement tableElement = constructTableElement(xmlTableElement);
			assignCategories(tableElement, xmlTableElement.getCategories());
			//assignSkips(tableElement, xmlTableElement.getSkipRule(), uuidMap);
			elementsToSkipMap.put(tableElement.getUuid(), xmlTableElement.getSkipRule());
			form.addElement(tableElement);
			formManager.updateForm(form);
		}
		
		/*Add external Question element */
		List<com.healthcit.cacure.export.model.Cure.Form.ExternalQuestionElement> xmlExternalElementList = xmlForm.getExternalQuestionElement();
		for(com.healthcit.cacure.export.model.Cure.Form.ExternalQuestionElement xmlExternalElement: xmlExternalElementList)
		{
			
			if(qaManager.getFormElement(xmlExternalElement.getUuid())!= null)
			{
				existingQuestions.add(xmlExternalElement.getUuid());
				continue;
			}
			ExternalQuestionElement externalElement = new ExternalQuestionElement();
			
			setFormElementProperties(externalElement, xmlExternalElement);
			//externalElement.setExternalLinkSource(ExternalQuestionElement.QuestionSource.valueOf(xmlExternalElement.getExternalSource()));
			externalElement.setExternalUuid(xmlExternalElement.getExternalUuid());
			externalElement.setLink(ExternalQuestionElement.QuestionSource.valueOf(xmlExternalElement.getExternalSource()), xmlExternalElement.getExternalLinkId());
			
			QuestionType xmlQuestion = xmlExternalElement.getQuestion();
			ExternalQuestion question = new ExternalQuestion();
			question.setUuid(xmlQuestion.getUuid());
			question.setShortName(xmlQuestion.getShortName());
			//question.setType(type);
			externalElement.setQuestion(question);
			Answer answer = constructAnswer(xmlQuestion);
			question.setAnswer(answer);
			form.addElement(externalElement);
			formManager.updateForm(form);
		}
		
		/* Add all Links */
		List<com.healthcit.cacure.export.model.Cure.Form.LinkElement> xmlLinkElementList = xmlForm.getLinkElement();
		for(com.healthcit.cacure.export.model.Cure.Form.LinkElement xmlLinkElement: xmlLinkElementList)
		{
			if(qaManager.getFormElement(xmlLinkElement.getUuid())!= null)
			{
				existingQuestions.add(xmlLinkElement.getUuid());
				continue;
			}
			LinkElement linkElement = new LinkElement();
			linkElement.setOrd(xmlLinkElement.getOrder());
			linkElement.setLearnMore(xmlLinkElement.getLearnMore());
			linkElement.setRequired(xmlLinkElement.isIsRequired());
			linkElement.setUuid(xmlLinkElement.getUuid());
			linkElement.setDescription(xmlLinkElement.getDescription());
			elementsToSkipMap.put(linkElement.getUuid(), xmlLinkElement.getSkipRule());
			//assignSkips(linkElement, xmlLinkElement.getSkipRule(), uuidMap);
			
			SourceElement xmlSourceElement = xmlLinkElement.getSourceElement();
			QuestionElementType xmlQuestionElement =xmlSourceElement.getQuestionElement();
			TableElementType xmlTableElement = xmlSourceElement.getTableElement();
			if (xmlQuestionElement != null)
			{
				String sourceUUID = xmlQuestionElement.getUuid();
				attachLinkSource(linkElement, xmlQuestionElement, sourceUUID, existingQuestions);
				
			}
			else if (xmlTableElement != null)
			{
				String sourceUUID = xmlTableElement.getUuid();
				attachLinkSource(linkElement, xmlTableElement, sourceUUID, existingQuestions);
			}
			/* add link to the form */
			form.addElement(linkElement);
			formManager.updateForm(form);
		} 
		
	}
	private void assignCategories(FormElement formElement, Categories xmlCategories)
	{
		Set<Category> assignedCategories = new LinkedHashSet<Category>();  
		if( xmlCategories == null)
		{
			return;
		}
		for ( com.healthcit.cacure.export.model.FormElementType.Categories.Category xmlCategory : xmlCategories.getCategory())
		{
			
			List<Category> categories = categoryManager.getCategoriesByName(xmlCategory.getName());
			if(categories != null && categories.size()>0)
			{
				assignedCategories.add(categories.get(0));
			}
			else
			{
				/* create new category */
				Category category = new Category();
				category.setDescription(xmlCategory.getDescription());
				category.setName(xmlCategory.getName());
				assignedCategories.add(category);
			}
		}
		formElement.setCategories(assignedCategories);
	}
	/* functionality was moved to createForms method*/
//	private void assignSkips(QuestionnaireForm form, SkipRuleType xmlSkipRule,  Map<String, Long>uuidMap)
//	{
//		 FormSkipRule skipRule = new FormSkipRule();
//		 assignSkips(skipRule, xmlSkipRule, uuidMap);
//		 if(skipRule.getQuestionSkipRules()!= null && skipRule.getQuestionSkipRules().size()>0)
//			{
//				form.setFormSkipRule(skipRule);
//			}
//	}
	/* functionality is moved into addElementsToForm */
//	private void assignSkips(FormElement formElement, SkipRuleType xmlSkipRule,  Map<String, Long>uuidMap)
//	{
//        FormElementSkipRule skipRule = new FormElementSkipRule();
//        createSkipRule(skipRule, xmlSkipRule, uuidMap);
//		if(skipRule.getQuestionSkipRules()!= null && skipRule.getQuestionSkipRules().size()>0)
//		{
//			formElement.setSkipRule(skipRule);
//		}
//	}
	
	private void createSkipRule(BaseSkipRule skipRule, SkipRuleType xmlSkipRule, Map<String, Long>uuidMap)
	{
		if(xmlSkipRule != null)
		{
			List<com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule> xmlQuestionSkipRuleList = xmlSkipRule.getQuestionSkipRule();
			if ( !xmlQuestionSkipRuleList.isEmpty() ) 
			{
				skipRule.setLogicalOp(xmlSkipRule.getLogicalOp().name());
	
				for(com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule xmlQuestionSkipRule: xmlQuestionSkipRuleList)
				{
					QuestionSkipRule questionSkipRule = new QuestionSkipRule();
					questionSkipRule.setValid( true );
					questionSkipRule.setRuleValue( "show" );
					SkipLogicalOpType xmlLogicalOp = xmlQuestionSkipRule.getLogicalOp();
					if(xmlLogicalOp != null)
					{
						questionSkipRule.setLogicalOp(xmlLogicalOp.name());
					}
					List<com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule.AnswerSkipRule> xmlAnswerSkipRuleList = xmlQuestionSkipRule.getAnswerSkipRule();
					for(com.healthcit.cacure.export.model.SkipRuleType.QuestionSkipRule.AnswerSkipRule xmlAnswerSkipRule: xmlAnswerSkipRuleList)
					{
						String formUUID = xmlAnswerSkipRule.getFormUUID();
						long formId= 0;
						/* when we exporting just some forms the cross form skips will be lost because the form might not exist in the new system
						 */
						if(uuidMap.containsKey(formUUID))
						{
							formId = uuidMap.get(formUUID);
						}
						/* check that the form referenced by skip has been processed during this import */
						if(formId != 0)
						{
							/*check that answerValue with referenced UUID exists in the database */
							if(answerValueDao.isValidAnswerValue(xmlAnswerSkipRule.getAnswerValueUUID()))
							{
								AnswerSkipRule answerSkipRule = new AnswerSkipRule();
								answerSkipRule.setAnswerValueId(xmlAnswerSkipRule.getAnswerValueUUID());
								answerSkipRule.setFormId(formId);
								questionSkipRule.addAnswerSkipRule(answerSkipRule);
							}
						}					
					}
					/* only create question skip rule if there are any valid references to answerValue that exist in the system */
					if(questionSkipRule.getAnswerSkipRules() != null && questionSkipRule.getAnswerSkipRules().size()>0)
					{
						skipRule.addQuestionSkipRule( questionSkipRule );
					}
				}		
			}
		}
	}
	private void setFormElementProperties(FormElement element, FormElementType xmlFormElement)
	{
		element.setUuid(xmlFormElement.getUuid());
		Description description = xmlFormElement.getDescriptions();
		element.setDescription(description.getMainDescription());
		element.setOrd(xmlFormElement.getOrder());
		element.setRequired(xmlFormElement.isIsRequired());
		element.setLearnMore(xmlFormElement.getLearnMore());
		Set<com.healthcit.cacure.model.Description> alternativeDescriptions = new HashSet<com.healthcit.cacure.model.Description>();
		
		for(String xmlAlternativeDescription : description.getAlternateDescription())
		{
			com.healthcit.cacure.model.Description alternativeDescription = new com.healthcit.cacure.model.Description();
			alternativeDescription.setDescription(xmlAlternativeDescription);
			alternativeDescriptions.add(alternativeDescription);
		}
		element.setDescriptionList(alternativeDescriptions);
	}
	private QuestionElement constructQuestionElement(QuestionElementType xmlQuestionElement)
	{
		QuestionElement questionElement = new QuestionElement();
		setFormElementProperties(questionElement, xmlQuestionElement);
		
		QuestionType xmlQuestion = xmlQuestionElement.getQuestion();
		Question question = new Question();
		question.setUuid(xmlQuestion.getUuid());
		question.setShortName(xmlQuestion.getShortName());
		//question.setType(type);
		questionElement.setQuestion(question);
		Answer answer = constructAnswer(xmlQuestion);
		question.setAnswer(answer);
		return questionElement;
	}
	
	private TableElement constructTableElement(TableElementType xmlTableElement)
	{
		TableElement tableElement = new TableElement();
		setFormElementProperties(tableElement, xmlTableElement);
		
		tableElement.setTableType(TableElement.TableType.valueOf(xmlTableElement.getTableType()));
	    tableElement.setTableShortName(xmlTableElement.getTableShortName());
		List<TableElementType.Question> xmlQuestions = xmlTableElement.getQuestion();
		
		 for (TableElementType.Question xmlQuestion: xmlQuestions)
		 {
			 TableQuestion question = new TableQuestion();
			 
			 question.setOrd(xmlQuestion.getOrder());
			 question.setShortName(xmlQuestion.getShortName());
			 question.setUuid(xmlQuestion.getUuid());
			 question.setType(BaseQuestion.QuestionType.valueOf(xmlQuestion.getAnswerType()));
			 question.setIsIdentifying(xmlQuestion.isIsIdentifying());
			 
			 Description description = xmlQuestion.getDescriptions();
			 question.setDescription(description.getMainDescription());
			 
			 Answer answer = constructAnswer(xmlQuestion);
			 
			 question.setAnswer(answer);
			 tableElement.addQuestion(question);
		 }
		 
		
		return tableElement;
	}
	
	private Answer constructAnswer(QuestionType xmlQuestion)
	{
		com.healthcit.cacure.export.model.QuestionType.Answer xmlAnswer = xmlQuestion.getAnswer();
		Answer answer = new Answer();

		answer.setUuid(xmlAnswer.getUuid());
		answer.setDescription(xmlAnswer.getDescription());
		answer.setDisplayStyle(xmlAnswer.getDisplayStyle());
		
		AnswerType answerType = AnswerType.valueOf(xmlAnswer.getType());
		
		answer.setType(answerType);
		
		AnswerValueConstraint answerValueConstraint = createConstraint(answerType, xmlAnswer.getValueConstraint());
		answer.setConstraint(answerValueConstraint);
//		question.setAnswer(answer);
		
		List<com.healthcit.cacure.export.model.QuestionType.Answer.AnswerValue>xmlAnswerValueList = xmlAnswer.getAnswerValue();
		for(com.healthcit.cacure.export.model.QuestionType.Answer.AnswerValue xmlAnswerValue: xmlAnswerValueList)
		{
			AnswerValue answerValue = new AnswerValue();
			answerValue.setName(xmlAnswerValue.getName());
			answerValue.setPermanentId(xmlAnswerValue.getUuid());
			answerValue.setValue(xmlAnswerValue.getValue());
			answerValue.setDescription(xmlAnswerValue.getDescription());
			answerValue.setOrd(xmlAnswerValue.getOrder());
			answer.addAnswerValues(answerValue);
			
		}
		return answer;
	}
	private AnswerValueConstraint createConstraint(AnswerType answerType, String formattedConstraint)
	{
		Class<? extends AnswerValueConstraint> constraintClass = answerType.getConstraintClass();
		AnswerValueConstraint constraint = null;
		if (constraintClass != null)
		{
			try 
			   {
				   Constructor<? extends AnswerValueConstraint> constructor = constraintClass.getConstructor(String.class);
				   constraint = constructor.newInstance(formattedConstraint);
			   }
			   catch(NoSuchMethodException e)
			   {
				   throw new UnsupportedOperationException("There are no String argument constructor present in class " + constraintClass, e);
			   }
			   catch (InvocationTargetException e)
			   {
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

			   }
			   catch(IllegalAccessException e)
			   {
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

			   }
			   catch(InstantiationException e)
			   {
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);
			   }
		}
		return constraint;
	}
	private void attachLinkSource(LinkElement linkElement, FormElementType xmlSourceElement, String sourceUUID, List<String> existingQuestions)
	{
		FormElement sourceElement = qaManager.getFormElement(sourceUUID);
		if(sourceElement != null)
		{
			existingQuestions.add(sourceUUID);
		}
		else
		{
			/* source doesnt exist in the database. Import source into the library and create a link to it */
			BaseForm questionLibrary = formManager.getQuestionLibraryForm();
			if(xmlSourceElement instanceof QuestionElementType)
			{
				sourceElement = constructQuestionElement((QuestionElementType)xmlSourceElement);
			}
			else
			{
				sourceElement = constructTableElement((TableElementType)xmlSourceElement);
			}
			questionLibrary.addElement(sourceElement);
			formManager.updateForm(questionLibrary);
			linkElement.setSource(sourceElement);
			
		}
	}
}
