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

import javax.persistence.CascadeType;

import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

import javax.persistence.Table;

@Entity
@Table(name="skip_rule")
@DiscriminatorValue("formSkip")
public class FormSkipRule extends BaseSkipRule{

	@ManyToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH},  fetch=FetchType.LAZY )
	@JoinColumn(name="parent_id")
	private QuestionnaireForm form;
	

	
	public QuestionnaireForm getForm() {
		return form;
	}

	public void setForm(QuestionnaireForm form) {
		this.form = form;
	}
}
