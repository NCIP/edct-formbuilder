package com.healthcit.cacure.web.controller.question;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.PersistenceException;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.hibernate.exception.GenericJDBCException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
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
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.dao.SkipPatternDao;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.Description;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.QuestionBreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Link;
import com.healthcit.cacure.model.breadcrumb.TableQuestionBreadCrumb;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.controller.BreadCrumbsSupporter;
import com.healthcit.cacure.web.editors.DescriptionPropertyEditor;
import com.healthcit.cacure.web.editors.QuestionPropertyEditor;
import com.healthcit.cacure.web.editors.SkipPatternPropertyEditor;

@Controller
@RequestMapping(value=Constants.QUESTION_TABLE_EDIT_URI)
public class TableElementEditController extends BaseFormElementController implements BreadCrumbsSupporter<TableQuestionBreadCrumb> {

	private static final Logger log = Logger.getLogger(TableElementEditController.class);
	public static final String QUESTION_ID = "questionId";

	@Autowired
	SkipPatternDao skipDao;
	
	@ModelAttribute
	public void createMainModel(
			@RequestParam(value = "id", required = false) Long id, ModelMap modelMap) throws Exception
	{
		FormElement qtElement;
		if (id == null) //INSERT Question
		{
			BaseForm form = formManager.getForm(getFormId());
			qtElement =  new TableElement();
			qtElement.setForm(form);
		}
		else //UPDATE Question
		{
			qtElement = qaManager.getFormElement(id);
			// reset order to sequential values - just in case someone mocks with DB
			int ord = 1;
			List<? extends BaseQuestion>questions = qtElement.getQuestions();
			for (BaseQuestion baseQuestion : questions)
			{
				TableQuestion question = (TableQuestion)baseQuestion;
				question.setOrd(ord);
				ord++;
			}
		}
		modelMap.addAttribute(COMMAND_NAME, qtElement);
	}
	
    @InitBinder
    public void initBinder(WebDataBinder dataBinder)
    {
//        dataBinder.registerCustomEditor(null, "answers", new AnswerPropertyEditor());
    	dataBinder.registerCustomEditor(null,"questions", new QuestionPropertyEditor());
        dataBinder.registerCustomEditor(null, "skipRule", new SkipPatternPropertyEditor<FormElementSkipRule>(FormElementSkipRule.class, skipDao));
        dataBinder.registerCustomEditor(null,"descriptionList", new DescriptionPropertyEditor());
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
			@ModelAttribute(COMMAND_NAME) FormElement table,
			@ModelAttribute(LOOKUP_DATA) Map lookupData)
	{
		log.debug("Table element is: " + table);
		log.debug("Lookup data: " + lookupData);
		return ("questionTableEdit");
	}

	/**
	 * Process data entered by user
	 * @param question
	 * @param formId
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(method = RequestMethod.POST)
	public ModelAndView onSubmit(@ModelAttribute(COMMAND_NAME) TableElement table, BindingResult result,
			@ModelAttribute(LOOKUP_DATA) Map lookupData, 
			SessionStatus status, HttpServletRequest req) {

		validateEditOperation(table);
		boolean isNew = table.isNew();
		Long formId = null;

		try
		{
		if (table.isNew()) {
			formId = getFormId();
			qaManager.addNewFormElement(table, formId);
		} else {
			qaManager.updateFormElement(table);
			formId = table.getForm().getId();
		}
		}
		catch(PersistenceException e)
		{
			Throwable t = e.getCause();
			if(t instanceof GenericJDBCException)
			{
				String message = ((GenericJDBCException)t).getSQLException().getNextException().getMessage();
				if(isNew)
				{
					table.resetId();
					table.getDescriptionList().clear();
				}
				if(message.indexOf("A table with the same short name already exists") >-1)
				{
					int beginIndex = message.indexOf('[');
					int endIndex = message.indexOf(']');
					String shortName = message.substring(beginIndex+1, endIndex);
					Object[] params = {shortName};
					result.rejectValue("tableShortName", "notunique.shortName",params, "Short name is not unique");
					return new ModelAndView("questionTableEdit");
				}
				if(message.indexOf("A question with the same short name already exists") >-1)
				{
					int beginIndex = message.indexOf('[');
					int endIndex = message.indexOf(']');
					String shortName = message.substring(beginIndex+1, endIndex);
					Object[] params = {shortName};
					result.reject("notunique.shortName", params,  "Short name is not unique");
					return new ModelAndView("questionTableEdit");
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

		table.setCategories(prepareCategories(req, lookupData));
//		TODO Save 2 times is not good idea. We clear constraints by second update (see implementation)
//		Changes to attached to session object save automatically. So categories are seved
//		qaManager.updateFormElement(table);
		
		// after question is saved - return to question listing
		return new ModelAndView(new RedirectView(Constants.QUESTION_LISTING_URI + "?formId=" + formId, true));
	}

	@Override
	public TableQuestionBreadCrumb setBreadCrumb(ModelMap modelMap) {
		TableElement table = (TableElement) modelMap.get(COMMAND_NAME);
		if(table != null) {
			if ( table.getForm()== null ) {
				BaseForm form = getFormContext();
				table.setForm(form);
			}
			TableQuestionBreadCrumb breadCrumb = new TableQuestionBreadCrumb(table.getForm(), table.isNew() ? Action.ADD : Action.EDIT);
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
