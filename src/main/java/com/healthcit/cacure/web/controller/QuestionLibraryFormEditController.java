package com.healthcit.cacure.web.controller;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.model.QuestionLibraryForm;
import com.healthcit.cacure.model.QuestionsLibraryModule;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.Constants;

@Controller
@RequestMapping(value=Constants.QUESTION_LIBRARY_FORM_EDIT_URI)
public class QuestionLibraryFormEditController extends BaseFormEditController{

	private static final Logger log = Logger.getLogger(QuestionLibraryFormEditController.class);

	/**
	 * This data is needed only for edit, not for delete, so it is made optional
	 * @param id
	 * @return
	 */
	@ModelAttribute(MODULE_ID_NAME)
	public Long initLookupData(
			@RequestParam(value = "moduleId", required = false) Long id)
	{
		return id;
	}

	@ModelAttribute(COMMAND_NAME)
	public QuestionLibraryForm createMainModel(
			@RequestParam(value = "id", required = false) Long id)
	{
		// TODO: Error handling!
		if (id == null) {
			QuestionLibraryForm form = new QuestionLibraryForm();
			return form;
		} else {
			QuestionLibraryForm form = (QuestionLibraryForm)formManager.getForm(id);
			return form;
		}
	}
	/**
	 * Used to populate breadcrumbs
	 * @param id
	 * @return
	 */
	@ModelAttribute(Constants.BREADCRUMB_COMMAND)
	public QuestionLibraryForm getBreadCrumbModel(@ModelAttribute( COMMAND_NAME ) QuestionLibraryForm form, @ModelAttribute( MODULE_ID_NAME ) Long moduleId){
		log.debug( "Setting the BreadCrumb entity in FormEditController..." );
		if ( form.getModule() == null || form.getModule().getId() == null ) {
			QuestionsLibraryModule module = new QuestionsLibraryModule();
			if ( moduleId != null )
				module = (QuestionsLibraryModule)moduleMgr.getModule(moduleId);
			form.setModule( module );
		}
		return form;
	}

	/**
	 * Display edit/update form
	 * @param qForm
	 * @param moduleId
	 * @return
	 */
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(
			@ModelAttribute(COMMAND_NAME) QuestionLibraryForm qForm,
			@ModelAttribute(MODULE_ID_NAME) Long moduleId)
	{
		return ("formEdit");
	}

	/**
	 * Process data edited by users
	 * @param qForm
	 * @param moduleId
	 * @return
	 */
	@RequestMapping(method = RequestMethod.POST)
	public View onSubmit(
			@ModelAttribute(COMMAND_NAME) QuestionLibraryForm qForm,
			@ModelAttribute(MODULE_ID_NAME) Long moduleId) {

		if(!isEditable(qForm)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The form is not editable in the current context");
		}

		if (qForm.isNew()) {
			// must insure linkage to module
			// get module object
			QuestionsLibraryModule parent = (QuestionsLibraryModule)moduleMgr.getModule(moduleId);
			qForm.setModule(parent);
			formManager.addNewForm(qForm);
		} else
			formManager.updateForm(qForm);

		// after question is saved - return to question listing
		return new RedirectView(Constants.QUESTIONNAIREFORM_LISTING_URI, true);
	}
}