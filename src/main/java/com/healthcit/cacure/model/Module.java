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
package com.healthcit.cacure.model;

import java.util.Date;
import java.util.EnumSet;

import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;

@Entity
@DiscriminatorValue("module")
public class Module extends BaseModule{

	@Column(name="RELEASE_DATE")
	private Date releaseDate;

	private String completionTime;
	
	public Module(){
		super();
	}
	
	/**
	 * @return the complete time
	 */
	public String getCompletionTime() {
		return completionTime;
	}
	/**
	 * @param complete the complete to set
	 */
	public void setCompletionTime(String comp) {
		this.completionTime = comp;
	}

	/**
	 * @return the release_date
	 */
	public Date getReleaseDate() {
		return releaseDate;
	}
	/**
	 * @param releaseDate the release_date to set
	 */
	public void setReleaseDate(Date releaseDate) {
		this.releaseDate = releaseDate;
	}

	@Override
	protected EnumSet<ModuleStatus> getAllowedStatuses() {
		return EnumSet.of(ModuleStatus.IN_PROGRESS, ModuleStatus.APPROVED_FOR_PILOT, ModuleStatus.APPROVED_FOR_PRODUCTION, ModuleStatus.RELEASED);
	}

	/**
	 * According to the module/section approval workflow a module can only
	 * be edited while it is in IN_PROGRESS status.
	 */
	@Override
	public boolean isEditable() {
		return this.status == ModuleStatus.IN_PROGRESS;
	}
	
	@Override
	public BaseForm newForm() {
		QuestionnaireForm newForm = new QuestionnaireForm();
		newForm.setModule(this);
		return newForm;
	}
	
	@Override
	public String toString(){
		StringBuilder module = new StringBuilder();
		module.append(this.getId());
		module.append(this.getStatus());
		module.append(this.isEditable());
		return module.toString();
		
	}

	public static void copyInformationFields(Module source, Module target) {
		target.setComments(source.getComments());
		target.setCompletionTime(source.getCompletionTime());
		target.setDescription(source.getDescription());
		target.setInsertCheckAllThatApplyForMultiSelectAnswers(source.isInsertCheckAllThatApplyForMultiSelectAnswers());
		target.setReleaseDate(source.getReleaseDate());
		target.setShowPleaseSelectOptionInDropDown(source.isShowPleaseSelectOptionInDropDown());
		target.setStatus(source.getStatus());
	}
}
