/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


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
import com.healthcit.cacure.model.ExternalQuestion;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
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
@RequestMapping(value=Constants.EXTERNAL_QUESTION_EDIT_URI)
public class ExternalQuestionElementEditController extends BaseFormElementController implements BreadCrumbsSupporter<QuestionBreadCrumb> {

	private static final Logger log = Logger.getLogger(ExternalQuestionElementEditController.class);
	public static final String ANSWER_TYPES = "answerTypes";

	@Autowired
	SkipPatternDao skipDao;
    @InitBinder
    public void initBinder(WebDataBinder dataBinder) {
        dataBinder.registerCustomEditor(Category.class, new CategoryPropertyEditor());
        dataBinder.registerCustomEditor(null,"descriptionList", new DescriptionPropertyEditor());
        dataBinder.registerCustomEditor(null, "question.answer", new AnswerPropertyEditor());
        dataBinder.registerCustomEditor(null, "skipRule", new SkipPatternPropertyEditor<FormElementSkipRule>(FormElementSkipRule.class,skipDao));
    }

	@ModelAttribute
	public void populateModelWithAttributes(@RequestParam(value = "id", required = false) Long id, ModelMap modelMap) {

		FormElement formElement;
		if (id == null) //INSERT Question
		{
			formElement =  new ExternalQuestionElement();
			ExternalQuestion question = new ExternalQuestion();
			Answer answer = new Answer();
			question.setAnswer(answer);
			((ExternalQuestionElement)formElement).setQuestion(question);
		}
		else //UPDATE Question
		{
			formElement = qaManager.getFormElement(id);
		}
		modelMap.addAttribute(COMMAND_NAME, formElement);
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
/*		if (log.isDebugEnabled())
			log.debug("Question object contains " + ((question.getAnswers() == null)?"0":question.getAnswers().size()) + " answers. isEditable: " + isEditable(question));
			*/
	
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
	public ModelAndView onSubmit(@ModelAttribute(COMMAND_NAME) ExternalQuestionElement qElement,BindingResult result,
			@ModelAttribute(LOOKUP_DATA) Map lookupData, 
			SessionStatus status, HttpServletRequest req) {

		validateEditOperation(qElement);
		
		log.debug("QuestionElement: " + qElement.toString());

		log.debug(qElement.toString());

		Long formId;
		try
		{
		if (qElement.isNew()) {
			formId = getFormId();
			qElement = (ExternalQuestionElement)qaManager.addNewFormElement(qElement, formId);
		} else {
				formId = qElement.getForm().getId();
			qElement = (ExternalQuestionElement)qaManager.updateFormElement(qElement);
				
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
					result.rejectValue("question.shortName", "notunique.shortName", "Short name is not unique");
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
		FormElement formElement = (FormElement) modelMap.get(COMMAND_NAME);
		if(formElement != null) {
			if (formElement.getForm() == null) {
				BaseForm form = getFormContext();
				formElement.setForm(form);
			}
			QuestionBreadCrumb breadCrumb = new QuestionBreadCrumb(formElement.getForm(), formElement.isNew() ? Action.ADD : Action.EDIT);
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
