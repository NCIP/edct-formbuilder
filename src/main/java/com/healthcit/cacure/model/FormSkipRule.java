/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


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
