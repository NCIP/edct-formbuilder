/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model.breadcrumb;

import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.utils.StringUtils;


/**
 * Breadcrumb for displaying link to a module.
 *
 */
public class ModuleDetailsBreadCrumb extends HomeBreadCrumb {
	
	private String moduleName;
	private Long moduleId;
	private boolean libraryModule;
	
	public ModuleDetailsBreadCrumb(BaseModule module) {
		this.moduleName = module.getDescription();
		this.moduleId = module.getId();
		this.libraryModule = module.isLibrary();
	}
	
	@Override
	public Link getLink() {
		Link link = super.getLink();
		Link currentLink = new Link(StringUtils.truncateWithTrailingDots(this.moduleName, MAX_LABEL_LENGTH), Constants.QUESTIONNAIREFORM_LISTING_URI+"?"+Constants.MODULE_ID+"="+this.moduleId, this);
		if(this.libraryModule)
		{
			Link manageLibraryLink = new Link("Manage Library", Constants.LIBRARY_MANAGE_URI, this);
			this.addLastChild(link, manageLibraryLink);
		}
		this.addLastChild(link, currentLink);
		return link;
	}
}
