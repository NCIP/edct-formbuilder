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
package com.healthcit.cacure.web.controller.question;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.PersistenceException;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.directwebremoting.annotations.RemoteProxy;
import org.hibernate.exception.GenericJDBCException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.dao.SkipPatternDao;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.QuestionBreadCrumb;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.controller.BreadCrumbsSupporter;
import com.healthcit.cacure.web.editors.AnswerPropertyEditor;
import com.healthcit.cacure.web.editors.CategoryPropertyEditor;
import com.healthcit.cacure.web.editors.DescriptionPropertyEditor;
import com.healthcit.cacure.web.editors.SkipPatternPropertyEditor;

@Controller
@Service
@RemoteProxy
@RequestMapping(value=Constants.QUESTION_EDIT_URI)
public class QuestionElementEditController extends BaseFormElementController implements BreadCrumbsSupporter<QuestionBreadCrumb> {

	private static final Logger log = Logger.getLogger(QuestionElementEditController.class);
	public static final String ANSWER_TYPES = "answerTypes";
	public static final String IS_EXTERNAL  = "isExternal";

	@Autowired
	SkipPatternDao skipDao;
	
    @InitBinder
    public void initBinder(WebDataBinder dataBinder) {
        dataBinder.registerCustomEditor(Category.class, new CategoryPropertyEditor());
        dataBinder.registerCustomEditor(null,"descriptionList", new DescriptionPropertyEditor());
        dataBinder.registerCustomEditor(null, "question.answer", new AnswerPropertyEditor());
        dataBinder.registerCustomEditor(null, "skipRule", new SkipPatternPropertyEditor<FormElementSkipRule>(FormElementSkipRule.class, skipDao));
    }

	@ModelAttribute
	public void createMainModel(@RequestParam(value = "id", required = false) Long id, ModelMap modelMap) {

		FormElement qElement;
		//The ExternalQuestionElement can only be created via import.
		if (id == null) //INSERT Question
		{
			QuestionElement newQElement =  new QuestionElement();
			Question question = new Question();
			Answer answer = new Answer();
			question.setAnswer(answer);
			newQElement.setQuestion(question);
			newQElement.setForm(formManager.getForm(getFormId()));
			qElement = newQElement;
		}
		else //UPDATE Question
		{
			qElement = qaManager.getFormElement(id);
		}
		modelMap.addAttribute(COMMAND_NAME, qElement);
	}

	/**
	 * Initialization of parent form ID
	 * @param id This parameter is required for adding a new question,
	 * but not for editing or deletion of a question
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@ModelAttribute(LOOKUP_DATA)
	public Map initLookupData(
			@RequestParam(value = "id", required = false) Long questionId)
	{
		Map lookupData = new HashMap();

		log.info("************ in initLookupData");

		//Long id = qaManager.getQuestion(questionId).getForm().getId();

		lookupData.put(QUESTION_ID, questionId);

		List<Category> allCategories = categoryManager.getAllCategories();
		lookupData.put(KEY_ALL_CATEGORIES, allCategories);


		//lookupData.put(ANSWER_TYPES, new Answer().getAnswerTypes());
		return lookupData;
	}
	
	/**
	 * Show edit/update form
	 * @param question
	 * @param formId
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(
			@ModelAttribute(COMMAND_NAME) FormElement question,
			@ModelAttribute(LOOKUP_DATA) Map lookupData)
	{	
		return ("questionEdit");
	}

	/**
	 * Process data entered by user
	 * @param question
	 * @param formId
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(method = RequestMethod.POST)
	public ModelAndView onSubmit(@ModelAttribute(COMMAND_NAME) FormElement qElement,BindingResult result,
			@ModelAttribute(LOOKUP_DATA) Map lookupData, 
			SessionStatus status, HttpServletRequest req,
			@RequestParam(value = IS_EXTERNAL, required = false) String isExternal) {

		validateEditOperation(qElement);

		log.debug("QuestionElement: " + qElement.toString());

		log.debug(qElement.toString());
		Long formId = null;
		boolean isNew = qElement.isNew();
		try
		{
			
			if (isNew) {
			//The ExternalQuestionElement can only be created via import.
			formId = getFormId();
			qaManager.addNewFormElement(qElement, formId);
		} else {
				formId = qElement.getForm().getId();

			if (qElement instanceof ExternalQuestionElement)
			{
				//unlink because of modifications
				((ExternalQuestionElement)qElement).unlink();
			} 
			qaManager.updateFormElement(qElement);
			
		}
		}
		catch(PersistenceException e)
		{
			Throwable t = e.getCause();
			if(t instanceof GenericJDBCException)
			{
				String message = ((GenericJDBCException)t).getSQLException().getNextException().getMessage();
				if(message.indexOf("short name already exists") >-1)
				{
					if(isNew)
					{
						qElement.resetId();
						qElement.getDescriptionList().clear();
					}
					int beginIndex = message.indexOf('[');
					int endIndex = message.indexOf(']');
					String shortName = message.substring(beginIndex+1, endIndex);
					Object[] params = {shortName};
					result.rejectValue("question.shortName", "notunique.shortName",params, "Short name is not unique");
					return new ModelAndView("questionEdit");
				}
				else 
				{
					throw e;
				}
			}
			else
			{
				throw e;
			}
		}

		qElement.setCategories(prepareCategories(req, lookupData));
//		TODO Save 2 times is not good idea. We clear constraints by second update (see implementation)
//		Changes to attached to session object save automatically. So categories are seved
//		qaManager.updateFormElement(qElement);
		
		// after question is saved - return to question listing
		return new ModelAndView(new RedirectView(Constants.QUESTION_LISTING_URI + "?formId=" + formId, true));
	}



	@Deprecated
	public void deleteAnswerValueSkip(String permAnswerValueId) throws IOException, InterruptedException {

		qaManager.deleteAnswerValueSkip(permAnswerValueId);

	}

	@Deprecated
	public void deleteAnswerValueSkipTable(String [] permAnswerValueIdArray) throws IOException, InterruptedException {

		for(String pav: permAnswerValueIdArray){
			qaManager.deleteAnswerValueSkip(pav);
		}
	}

	@Override
	public QuestionBreadCrumb setBreadCrumb(ModelMap modelMap) {
		FormElement qElement = (FormElement) modelMap.get(COMMAND_NAME);
		if(qElement != null) {
			if (qElement.getForm() == null) {
				BaseForm form = getFormContext();
				qElement.setForm(form);
			}
			QuestionBreadCrumb breadCrumb = new QuestionBreadCrumb(qElement.getForm(), qElement.isNew() ? Action.ADD : Action.EDIT);
			modelMap.addAttribute(Constants.BREAD_CRUMB, breadCrumb);
			return breadCrumb;
		}
		return null;
	}

	@Override
	public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req) {
		return new ArrayList<BreadCrumb.Link>();
	}

}
