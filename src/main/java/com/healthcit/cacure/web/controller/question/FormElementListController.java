package com.healthcit.cacure.web.controller.question;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.directwebremoting.annotations.RemoteMethod;
import org.directwebremoting.annotations.RemoteProxy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.businessdelegates.UserManager;
import com.healthcit.cacure.businessdelegates.beans.SkipAffecteesBean;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.QuestionsLibraryModule;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Link;
import com.healthcit.cacure.model.breadcrumb.FormDetailsBreadCrumb;
import com.healthcit.cacure.model.breadcrumb.ModuleDetailsBreadCrumb;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.controller.BreadCrumbsSupporter;

/**
 * Controller for view questionList page.
 * @author vetali
 *
 */
@Controller
@Service
@RemoteProxy
public class FormElementListController extends BaseFormElementController implements BreadCrumbsSupporter<BreadCrumb> {

	private static final String QUERY_PARAM = "query";
	private static final String CATEGORY_ID_PARAM = "categoryId";
	private static final int MAX_HEADER_LENGTH = 28;
	public static final String FORM_KEY = "form";
	private static final Logger log = Logger.getLogger(FormElementListController.class);

	@Autowired
	private QuestionAnswerManager qaManager;
	
	@Autowired
	private FormManager formManager;
	
	@Autowired
	private UserManager userManager;
	
	@ModelAttribute("questionLibraryFormExist")
	public Boolean isQuestionLibraryExist()
	{
		return this.formManager.getQuestionLibraryForm() != null;
	}


	@RequestMapping(value = Constants.QUESTION_LISTING_URI, method = RequestMethod.GET)
	public ModelAndView showFormElements(
			@RequestParam(value = FORM_ID_NAME, required = true) Long formId,
			@RequestParam(value = QUERY_PARAM, required = false) String searchText,
			@RequestParam(value = CATEGORY_ID_PARAM, required = false) long[] categoryIds) {
		return getModelAndView(formId, searchText, categoryIds);
	}

	@RequestMapping(value=Constants.QUESTION_LISTING_SKIP_URI)
	public ModelAndView showSkipQuestionList(
			@RequestParam(value = FORM_ID_NAME, required = true) Long formId, @RequestParam(value = "questionId", required = true) Long formElementId) {

		BaseForm form = formManager.getForm(formId);
		String viewName = "questionListSkip";

		List<BaseForm> forms = formManager.getModuleForms(form.getModule().getId());
		ModelAndView mav = new ModelAndView(viewName); // initialize with view name
		ModelMap model = mav.getModelMap();
		if(formElementId != null) {
			FormElement formElement = qaManager.getFormElement(formElementId);
			SkipAffecteesBean dependencies = qaManager.getAllPossibleSkipAffectees(formElement);
			model.addAttribute("formElementId", formElementId);
			model.addAttribute("dependencies", dependencies);
		}
		
		model.addAttribute("forms", forms);

		log.debug("in QuestionListController.showSkipQuestionList(): formId: " + formId + " formElementId: " + formElementId);
		
		return mav;
	}

	/**
	 * Delete question
	 * @param question
	 * @return
	 */
	@SuppressWarnings("deprecation")
	@RequestMapping(value = Constants.QUESTION_LISTING_URI, method = RequestMethod.GET,
			        params=Constants.DELETE_CMD_PARAM)
	public View deleteFormElement(
			@RequestParam(value = "qId", required = true) Long elementId,
			@RequestParam(value = "formId", required = true) Long formId,
			@RequestParam(value = Constants.DELETE_CMD_PARAM, required = true) boolean delete)
	{
		validateEditOperation(elementId);
		qaManager.deleteFormElementByID(elementId);
		return new RedirectView (Constants.QUESTION_LISTING_URI+ "?formId=" + formId, true);
	}
	
	@RequestMapping(value = Constants.ADD_QUESTION_TO_LIBRARY_URI, method = RequestMethod.GET, params = {
			Constants.QUESTION_ID, Constants.FORM_ID })
	public View addQuestionToLibrary(
			@RequestParam(Constants.QUESTION_ID) Long questionId,
			@RequestParam(Constants.FORM_ID) Long formId) {
		if(!this.userManager.isCurrentUserInRole(RoleCode.ROLE_ADMIN) && !this.userManager.isCurrentUserInRole(RoleCode.ROLE_LIBRARIAN))
		{
			throw new UnauthorizedException("You have no permissions to add question to the library.");
		}
		this.formManager.addQuestionToQuestionLibrary(questionId);
		return new RedirectView(Constants.QUESTION_LISTING_URI + "?"+Constants.FORM_ID+"="
				+ formId, true);
	}

	/**
	 * @param formId Long
	 * @param categoryIds 
	 * @param searchText 
	 * @return view with form entity that fetches list of Question items
	 */
	private ModelAndView getModelAndView(Long formId, String searchText, long[] categoryIds) {
		BaseForm form = null;
//		List<? extends FormElement> questions = qaManager.getAllFormElementsWithChildren(formId);
		List<FormElement> elements = qaManager.getFormElementsByTextWithinCategories(formId, searchText, categoryIds);
		
		//getting QuestionnaireForm entity
		if (!elements.isEmpty()) {
			form = elements.get(0).getForm();
//			form.setElements(elements);
		} else {
			form = formManager.getForm(formId);
		}

		String formName = form.getName();
		String shortFormName = form.getName();
		if(shortFormName != null && shortFormName.length() > MAX_HEADER_LENGTH) {
			shortFormName = shortFormName.substring(0, MAX_HEADER_LENGTH) + "...";
		}

		ModelAndView mav = new ModelAndView("questionList"); // initialize with view name
		ModelMap model = mav.getModelMap();
		model.addAttribute(FORM_KEY, form);
		model.addAttribute("elements", elements);
		model.addAttribute("shortFormName", shortFormName);
		model.addAttribute("formName", formName);
		return mav;
	}

	@ModelAttribute("categories")
	public List<Category> getCategories() {
		return categoryManager.getLibraryQuestionsCategories();
	}


 /**
  * This method must stay in this class to utilize validation of editing accesibility
  * @param sourceQuestionId
  * @param targetQuestionId
  * @param before
  * @throws IOException
  * @throws InterruptedException
  */
	/*
  @RemoteMethod
  public void reorderQuestions(Long sourceQuestionId, Long targetQuestionId, boolean before) throws IOException, InterruptedException
  {
		validateEditOperation(sourceQuestionId);
		qaManager.reorderQuestions(sourceQuestionId, targetQuestionId, before);
  }
*/
	@RemoteMethod
	public void reorderFormElements(Long sourceQuestionId, Long targetQuestionId, boolean before) throws IOException, InterruptedException
	{
		validateEditOperation(sourceQuestionId);
		qaManager.reorderFormElements(sourceQuestionId, targetQuestionId, before);
	}


@Override
public BreadCrumb setBreadCrumb(ModelMap modelMap) {
	BaseForm  form = (BaseForm) modelMap.get(FORM_KEY);
	if(form != null) {
		FormDetailsBreadCrumb breadCrumb = new FormDetailsBreadCrumb(form);
		modelMap.addAttribute(Constants.BREAD_CRUMB, breadCrumb);
		return breadCrumb;
	}
	return null;
}


@Override
public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req) {
//	TODO Need to filter out some links
	/*long formId = Long.parseLong(req.getParameter(FORM_ID_NAME));
	String query = req.getParameter(QUERY_PARAM);
	String categoryIdsStr = req.getParameter(CATEGORY_ID_PARAM);
	long[] categoryIds = null;
	if(StringUtils.isNotBlank(categoryIdsStr)) {
		String[] splitedCategoryIds = categoryIdsStr.split(" *, *");
		categoryIds = new long[splitedCategoryIds.length];
		for (int i = 0; i < splitedCategoryIds.length; i++) {
			categoryIds[i] = Long.parseLong(splitedCategoryIds[i]); 
		}
	}
	List<FormElement> elements = qaManager.getFormElementsByTextWithinCategories(formId, query, categoryIds);
	ArrayList<Link> links = new ArrayList<BreadCrumb.Link>();
	for (FormElement fe : elements) {
		links.add(new Link(fe.getDescription(),
					Constants.QUESTION_LISTING_URI + "?" + Constants.FORM_ID + "=" + fe.getForm().getId() + "&" + Constants.MODULE_ID + "=" + fe.getForm().getModule().getId(),
					null));
	}
	return links;*/
	return new ArrayList<BreadCrumb.Link>();
}	

}
