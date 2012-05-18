package com.healthcit.cacure.model.breadcrumb;

import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.QuestionLibraryForm;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.utils.StringUtils;

/**
 * Breadcrumb for displaying link to module form
 *
 */
public class FormDetailsBreadCrumb extends ModuleDetailsBreadCrumb {

	private String formName;
	private Long formId;
	private Long moduleId;
	private boolean questionLibraryForm;

	public FormDetailsBreadCrumb(BaseForm form) {
		super(form.getModule());
		this.formName = form.getName();
		this.formId = form.getId();
		this.moduleId = form.getModule().getId();
		this.questionLibraryForm = form.getClass().equals(QuestionLibraryForm.class);
	}

	@Override
	public Link getLink() {
		Link link = super.getLink();
		String url = Constants.QUESTION_LISTING_URI + "?"+Constants.FORM_ID+"=" + this.formId + "&" + Constants.MODULE_ID + "=" + this.moduleId;
		if(!questionLibraryForm) {
			Link currentLink = new Link(StringUtils.truncateWithTrailingDots(this.formName, MAX_LABEL_LENGTH), url, this);
			this.addLastChild(link, currentLink);
		} else {
			getLastChild(link).setUrl(url);
			getLastChild(link).setNameAllUrl(url);
		}
		return link;
	}
}
