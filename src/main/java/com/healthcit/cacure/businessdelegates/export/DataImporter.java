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
import com.healthcit.cacure.dao.AnswerValueDao;
import com.healthcit.cacure.dao.FormElementDao;
import com.healthcit.cacure.export.model.Cure;
import com.healthcit.cacure.export.model.Cure.Form;
import com.healthcit.cacure.export.model.Cure.Form.Content;
import com.healthcit.cacure.export.model.Cure.Form.LinkElement.SourceElement;
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
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ExternalQuestion;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
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
	ModuleManager moduleManager;
	Map<String, Long> uuidMap = new HashMap<String, Long>();
//	private static String ID = "ID";
//	private static String UUID = "UUID";
	public void importData(Cure cure, Module module, int startOrderFrom)
	{
		
		List<Form> xmlForms = cure.getForm();
		int formOrder = startOrderFrom;
		for (Form xmlForm: xmlForms)
		{
			QuestionnaireForm form = new QuestionnaireForm();
			form.setName(xmlForm.getName());
			form.setOrd(formOrder);
			
			/*store form first. 
			 * Create a map between old UUID and new one in order to build skips correctly
			 * */
            form.setModule(module);
			formManager.addNewForm(form);
//			newIds.put(DataImporter.ID, form.getId());
//			newIds.put(DataImporter.UUID, form.getUuid());
			uuidMap.put(xmlForm.getUuid(), form.getId());
			
			/* Increase order by one for the next form */
			formOrder++;
			
			/* add all content */
			List<Content> xmlContentList = xmlForm.getContent();
			for ( Content xmlContent: xmlContentList)
			{
				ContentElement content = new ContentElement();
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
				QuestionElement questionElement = constructQuestionElement(xmlQuestionElement);
				assignCategories(questionElement, xmlQuestionElement.getCategories());
				assignSkips(questionElement, xmlQuestionElement.getSkipRule());
				
				form.addElement(questionElement);
				formManager.updateForm(form);
				
			}
			
			/* Add table Element */
			List<TableElementType> xmlTableElementList = xmlForm.getTableElement();
			for(TableElementType xmlTableElement: xmlTableElementList)
			{
				TableElement tableElement = constructTableElement(xmlTableElement);
				assignCategories(tableElement, xmlTableElement.getCategories());
				assignSkips(tableElement, xmlTableElement.getSkipRule());
				form.addElement(tableElement);
				formManager.updateForm(form);
			}
			
			/*Add external Question element */
			List<com.healthcit.cacure.export.model.Cure.Form.ExternalQuestionElement> xmlExternalElementList = xmlForm.getExternalQuestionElement();
			for(com.healthcit.cacure.export.model.Cure.Form.ExternalQuestionElement xmlExternalElement: xmlExternalElementList)
			{
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
				LinkElement linkElement = new LinkElement();
				linkElement.setOrd(xmlLinkElement.getOrder());
				linkElement.setLearnMore(xmlLinkElement.getLearnMore());
				linkElement.setRequired(xmlLinkElement.isIsRequired());
				assignSkips(linkElement, xmlLinkElement.getSkipRule());
				
				SourceElement xmlSourceElement = xmlLinkElement.getSourceElement();
				QuestionElementType xmlQuestionElement =xmlSourceElement.getQuestionElement();
				TableElementType xmlTableElement = xmlSourceElement.getTableElement();
				if (xmlQuestionElement != null)
				{
					String sourceUUID = xmlQuestionElement.getUuid();
					attachLinkSource(linkElement, xmlQuestionElement, sourceUUID);
					
				}
				else if (xmlTableElement != null)
				{
					String sourceUUID = xmlTableElement.getUuid();
					attachLinkSource(linkElement, xmlTableElement, sourceUUID);
				}
				/* add link to the form */
				form.addElement(linkElement);
				formManager.updateForm(form);
			} 
			
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
	
	private void assignSkips(FormElement formElement, SkipRuleType xmlSkipRule)
	{
        FormElementSkipRule skipRule = new FormElementSkipRule();
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
		if(skipRule.getQuestionSkipRules()!= null && skipRule.getQuestionSkipRules().size()>0)
		{
			formElement.setSkipRule(skipRule);
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
//		Answer answer = new Answer();
//		com.healthcit.cacure.export.model.QuestionType.Answer xmlAnswer = xmlQuestion.getAnswer();
//		answer.setUuid(xmlAnswer.getUuid());
//		answer.setDescription(xmlAnswer.getDescription());
//		answer.setDisplayStyle(xmlAnswer.getDisplayStyle());
//		
//		AnswerType answerType = AnswerType.valueOf(xmlAnswer.getType());
//		
//		answer.setType(answerType);
//		
//		AnswerValueConstraint answerValueConstraint = createConstraint(answerType, xmlAnswer.getValueConstraint());
//		answer.setConstraint(answerValueConstraint);
//		question.setAnswer(answer);
//		
//		List<com.healthcit.cacure.export.model.QuestionType.Answer.AnswerValue>xmlAnswerValueList = xmlAnswer.getAnswerValue();
//		for(com.healthcit.cacure.export.model.QuestionType.Answer.AnswerValue xmlAnswerValue: xmlAnswerValueList)
//		{
//			AnswerValue answerValue = new AnswerValue();
//			answerValue.setName(xmlAnswerValue.getName());
//			answerValue.setPermanentId(xmlAnswerValue.getUuid());
//			answerValue.setValue(xmlAnswerValue.getValue());
//			answerValue.setDescription(xmlAnswerValue.getDescription());
//			answerValue.setOrd(xmlAnswerValue.getOrder());
//			answer.addAnswerValues(answerValue);
//			
//		}
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
//				   log.error("There are no String argument constructor present in class " + constraintClass);
//				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("There are no String argument constructor present in class " + constraintClass, e);
			   }
			   catch (InvocationTargetException e)
			   {
//				   log.error("Error constructing object of type " + constraintClass);
//				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

			   }
			   catch(IllegalAccessException e)
			   {
//				   log.error("Error constructing object of type " + constraintClass);
//				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

			   }
			   catch(InstantiationException e)
			   {
//				   log.error("Error constructing object of type " + constraintClass);
//				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);
			   }
		}
		return constraint;
	}
	private void attachLinkSource(LinkElement linkElement, FormElementType xmlSourceElement, String sourceUUID)
	{
		Set<String> set = new HashSet<String>();
		set.add(sourceUUID);
		List<FormElement> elements = formElementDao.getFormElementsByUuid(set);
		if(elements != null && elements.size()>0)
		{
			/* Source Element exists in the database, create a link to existing element. */
			FormElement sourceElement = (FormElement)elements.get(0);
			if(!sourceElement.getForm().isLibraryForm())
			{
				/* import question into the library. */
				formManager.addQuestionToQuestionLibrary(sourceElement.getId());			
			}
			/* if the question already in the library just add it as a source. */
			linkElement.setSource(sourceElement);
		}
		else
		{
			/* source doesnt exist in the database. Import source into the library and create a link to it */
			BaseForm questionLibrary = formManager.getQuestionLibraryForm();
			FormElement sourceElement = null;
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
