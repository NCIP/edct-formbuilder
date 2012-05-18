package com.healthcit.cacure.web.controller.question;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.ContentBreadCrumb;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.controller.BreadCrumbsSupporter;

@Controller
@RequestMapping(value=Constants.CONTENT_EDIT_URI)
public class ContentElementEditController extends BaseFormElementController implements BreadCrumbsSupporter<ContentBreadCrumb> {

	@ModelAttribute
    public void populateModelWithAttributes(
			@RequestParam(value = "id", required = false) Long id, ModelMap modelMap)
	{		
		FormElement formElement;
		if(id== null)
		{
			formElement = new ContentElement();
		}
		else
		{
			//This could be a link
			formElement = qaManager.getFormElement(id);
		}
		modelMap.addAttribute(COMMAND_NAME, formElement);
		if ( formElement.isNew() ){
			BaseForm parent = getFormContext();
			formElement.setForm(parent);
		}
	}
	
	/**
	 * Show edit/update form
	 * @param question
	 * @param formId
	 * @return
	 */
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(
			@ModelAttribute(COMMAND_NAME) FormElement content)
	{		
		return ("contentEdit");
	}

	/**
	 * Process data entered by user
	 * @param question
	 * @param formId
	 * @return
	 */
   @RequestMapping(method = RequestMethod.POST)
    public View onSubmit(
    		@ModelAttribute(COMMAND_NAME) ContentElement content,
    		BindingResult result, SessionStatus status)
    {
	   validateEditOperation(content);
	   Long formId;

	   if (content.isNew())
		{
		    formId = getFormId();
			qaManager.addNewFormElement(content, formId);
		}
		else
		{
			qaManager.updateFormElement(content);
			formId = content.getForm().getId();
		}
		// after question is saved - return to question listing
		return new RedirectView (Constants.QUESTION_LISTING_URI + "?formId=" + formId, true);
    }

	@Override
	public ContentBreadCrumb setBreadCrumb(ModelMap modelMap) {
		FormElement formElement = (FormElement) modelMap.get(COMMAND_NAME);
		if(formElement != null) {
			ContentBreadCrumb breadCrumb = new ContentBreadCrumb(formElement.getForm(), formElement.isNew() ? Action.ADD : Action.EDIT);
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
