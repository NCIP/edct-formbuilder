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

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;


@Entity
@Table(name="preferences")
public class PreferenceSettings {
	@Id
	@SequenceGenerator(name = "genericSequence", sequenceName = "\"GENERIC_ID_SEQ\"", allocationSize = 1)
	@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "genericSequence")
	protected Long id;
	
	@Column(name = "show_please_select_option")
	protected boolean showPleaseSelectOptionInDropDown = false;
	
	@Column(name = "insert_check_all_that_apply")
	protected boolean insertCheckAllThatApplyForMultiSelectAnswers = false;

	public boolean isShowPleaseSelectOptionInDropDown() {
		return showPleaseSelectOptionInDropDown;
	}

	public void setShowPleaseSelectOptionInDropDown(boolean showPleaseSelectOptionInDropDown) {
		this.showPleaseSelectOptionInDropDown = showPleaseSelectOptionInDropDown;
	}

	public boolean isInsertCheckAllThatApplyForMultiSelectAnswers() {
		return insertCheckAllThatApplyForMultiSelectAnswers;
	}

	public void setInsertCheckAllThatApplyForMultiSelectAnswers(
			boolean insertCheckAllThatApplyForMultiSelectAnswers) {
		this.insertCheckAllThatApplyForMultiSelectAnswers = insertCheckAllThatApplyForMultiSelectAnswers;
	}
	
}
