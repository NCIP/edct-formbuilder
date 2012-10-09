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

import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.CategoryManager;
import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.web.controller.EditControllable;
import com.healthcit.cacure.web.controller.InvalidStateException;

public abstract class BaseFormElementController implements EditControllable, FormContextRequired
{
	public static final String COMMAND_NAME = "questionCmd";
	public static final String LOOKUP_DATA = "lookupData";
	public static final String QUESTION_ID = "questionId";
	public static final String PARAM_ADDED_CATEGORY_IDS  = "addedCategoryIds";
	public static final String PARAM_SELECTED_CATEGORIES  = "selectedCategories";
	public static final String KEY_ALL_CATEGORIES  = "allCategories";


	@Autowired
	protected QuestionAnswerManager qaManager;

	@Autowired
	protected FormManager formManager;
	
	@Autowired
	protected CategoryManager categoryManager;

	// must be very careful with this variable
	private Long formId;
	/**
	 * for all Question-based controls Form ID is required
	 * @param formId
	 * @return
	 */
	@Override
	public void setFormId(Long formId)
	{
		this.formId = formId;

	}
	protected Long getFormId()
	{
		return this.formId;
	}

	@Override
	public void unsetFormId()
	{
		this.formId = null;

	}

	@Override
	public BaseForm getFormContext()
	{
		if (this.formId != null)
			return formManager.getForm(this.formId);
		else
			throw new InvalidStateException("Form ID is required");
	}

	@Override
	public boolean isModelEditable(ModelAndView mav)
	{
		BaseForm form = getFormContext();
		return formManager.isEditableInCurrentContext(form) ;
	}

	protected boolean isEditable(Long questionId){
		FormElement q = qaManager.getFormElement(questionId);
		return isEditable(q);
	}
	protected boolean isEditable(FormElement q){
		BaseForm form = q.getForm();
		//This is used for delete operation so this condition is not correct when delete is performed
//		if(q.isLink() && form.isLibraryForm())
//		{
//			return false;
//		}
		if (form == null) // may happen on a brand new question
		{
			form = formManager.getForm(formId);
		}
		return formManager.isEditableInCurrentContext(form);
	}

	protected void validateEditOperation(Long questionElementId ) throws UnauthorizedException
	{
		if(!isEditable(questionElementId)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The form is not editable in the current context");
		}
	}

	protected void validateEditOperation(FormElement q ) throws UnauthorizedException
	{
		if(!isEditable(q)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The form is not editable in the current context");
		}
	}
 
	protected Set<Category> prepareCategories(HttpServletRequest req, Map lookupData)
	{
//		Save newly added
		String addedCategoryIds = req.getParameter(PARAM_ADDED_CATEGORY_IDS);
		HashMap<String, Category> newCategories = new HashMap<String, Category>();
		if (StringUtils.isNotBlank(addedCategoryIds)) {
			for (String tempId : addedCategoryIds.split(",")) {
				String name = req.getParameter("category_name_" + tempId);
				String description = req.getParameter("category_description_" + tempId);
				Category category = new Category();
				category.setName(name);
				category.setDescription(description);
				categoryManager.saveCategory(category);
				newCategories.put(tempId, category);
			}
		}
		
//		Collect selected categories
		String selectedCategoryIds = req.getParameter(PARAM_SELECTED_CATEGORIES);
		Set<Category> selectedCategories = new LinkedHashSet<Category>();
		if (StringUtils.isNotBlank(selectedCategoryIds)) {
			List<Category> categories = (List<Category>) lookupData.get(KEY_ALL_CATEGORIES);
			String[] idsSA = selectedCategoryIds.split(",");
			for (String id : idsSA) {
				if(StringUtils.isNumeric(id)) {
					Long lId = Long.valueOf(id);
					for (Category cat : categories) {
						if (cat.getId().equals(lId)) {
							selectedCategories.add(cat);
							break;
						}
					}
				} else {
					Category newCategory = newCategories.get(id);
					if(newCategory != null) {
						selectedCategories.add(newCategory);
					}
				}
			}
		}
		return selectedCategories;
	}
}
