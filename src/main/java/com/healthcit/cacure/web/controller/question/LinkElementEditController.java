/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller.question;


import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.PersistenceException;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.directwebremoting.annotations.RemoteProxy;
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
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.UserManager;
import com.healthcit.cacure.businessdelegates.UserManagerService;
import com.healthcit.cacure.dao.SkipPatternDao;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.QuestionBreadCrumb;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.controller.BreadCrumbsSupporter;
import com.healthcit.cacure.web.editors.AnswerPropertyEditor;
import com.healthcit.cacure.web.editors.CategoryPropertyEditor;
import com.healthcit.cacure.web.editors.DescriptionPropertyEditor;
import com.healthcit.cacure.web.editors.QuestionPropertyEditor;
import com.healthcit.cacure.web.editors.SkipPatternPropertyEditor;


@Controller
@Service
@RemoteProxy
@RequestMapping(value=Constants.LINK_EDIT_URI)
public class LinkElementEditController extends BaseFormElementController implements BreadCrumbsSupporter<QuestionBreadCrumb> {

	private static final Logger log = Logger.getLogger(LinkElementEditController.class);

	@Autowired
	private UserManager userManager;
	
	@Autowired
	private UserManagerService userService;

	@Autowired
	SkipPatternDao skipDao;
	
	public static final String IS_LINK  = "isLink";
	public static final String PARAM_UNLINK  = "unlink";
	public static final String UPDATE_SRC_CATEGORIES  = "updateSourceCategories";
	
	@InitBinder
	public void initBinder(WebDataBinder dataBinder) {
	        dataBinder.registerCustomEditor(Category.class, new CategoryPropertyEditor());
	        dataBinder.registerCustomEditor(null,"descriptionList", new DescriptionPropertyEditor());
	        dataBinder.registerCustomEditor(null, "question.answer", new AnswerPropertyEditor());
	        dataBinder.registerCustomEditor(null,"questions", new QuestionPropertyEditor());
	        dataBinder.registerCustomEditor(null, "skipRule", new SkipPatternPropertyEditor<FormElementSkipRule>(FormElementSkipRule.class, skipDao));
	}

	@ModelAttribute
	public void createMainModel(@RequestParam(value = "id", required = false) Long id, ModelMap modelMap) 
	{
		FormElement fElement = qaManager.getFantom(id);
		modelMap.addAttribute(COMMAND_NAME, fElement);
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

		lookupData.put(QUESTION_ID, questionId);
		lookupData.put(IS_LINK, true);

		List<Category> allCategories = categoryManager.getAllCategories();
		lookupData.put(KEY_ALL_CATEGORIES, allCategories);

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
	public ModelAndView editFormElement(
			@ModelAttribute(COMMAND_NAME) FormElement fElement,
			@ModelAttribute(LOOKUP_DATA) Map lookupData)
	{
		ModelAndView view = getModelAndView(fElement);
		return view;
	}

	private ModelAndView getModelAndView(FormElement fElement)
	{
		ModelAndView view = null;
		if(fElement  instanceof QuestionElement)
		{
			view = new ModelAndView("questionEdit");
		}
		else if (fElement instanceof TableElement)
		{
			view = new ModelAndView("questionTableEdit");
		}
		else if (fElement instanceof ContentElement)
		{
			view = new ModelAndView("contentEdit");
		}
		
		return view;
	}

	@RequestMapping(method = RequestMethod.POST)
	public ModelAndView onSubmit(
			@ModelAttribute(COMMAND_NAME) FormElement formElement,
			BindingResult result,
			@RequestParam(value = PARAM_UNLINK, required = false, defaultValue = "false") Boolean unlink,
			@RequestParam(value = UPDATE_SRC_CATEGORIES, required = false, defaultValue = "false") Boolean updateSrcCategories,
			@ModelAttribute(LOOKUP_DATA) Map lookupData, HttpServletRequest req) {
		Long formId = getFormId();

		if (updateSrcCategories) {
			EnumSet<RoleCode> roles = userService.getCurrentUserRoleCodes();
			if (!roles.contains(RoleCode.ROLE_LIBRARIAN)
					&& !roles.contains(RoleCode.ROLE_ADMIN)
					&& !roles.contains(RoleCode.ROLE_AUTHOR)) {
				throw new RuntimeException(
						"The user has no rights to modify categories.");
			}
			Set<Category> selectedCategories = prepareCategories(req,
					lookupData);
			qaManager.updateSourceCategories(formElement.getId(),
					selectedCategories);
		}

		if (unlink) {
			Long id = formElement.getId();
			validateEditOperation(formElement);
			// persist the new formElement
			formElement.setId(null);
			try {
				qaManager.unlink(formElement, id, formId);
			} catch (PersistenceException e) {
				//log.debug(ExceptionUtils.getFullStackTrace(e));
				return new ModelAndView(new RedirectView(
						Constants.LINK_EDIT_URI + "?id=" + id + "&formId="
								+ formId, true));
			}
		} else {
			qaManager.updateLink(formElement);
		}

		// after question is saved - return to question listing
		return new ModelAndView(new RedirectView(Constants.QUESTION_LISTING_URI
				+ "?formId=" + formId, true));
	}

	@Override
	public QuestionBreadCrumb setBreadCrumb(ModelMap modelMap) {
		FormElement fElement = (FormElement) modelMap.get(COMMAND_NAME);
		if(fElement != null) {
			if (fElement.getForm() == null) {
				BaseForm form = getFormContext();
				fElement.setForm(form);
			}
			QuestionBreadCrumb breadCrumb = new QuestionBreadCrumb(fElement.getForm(), fElement.isNew() ? Action.ADD : Action.EDIT);
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
