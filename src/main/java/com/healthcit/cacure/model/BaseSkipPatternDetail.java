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
import javax.persistence.FetchType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.Table;

/**
 * View created to provide additional details about skips. 
 * A readonly entity.
 * @author Oawofolu
 *
 */
@Entity
@Table(name="skip_pattern_answer_value_vw")
public class BaseSkipPatternDetail {
	/**
	 * Unique Identifier
	 */
	@Id
	private Long id;
	
	
	@OneToOne(optional = false,  fetch=FetchType.LAZY  )
	@JoinColumn( name = "id", insertable=false, updatable=false )
	private QuestionSkipRule skip;
	
	/**
	 * The question that owns the skip.
	 * Null if the skip is owned by a form.
	 */
	@Column(name="form_element_id")
	private Long formElementId;
	
	/**
	 * The form which owns the skip.
	 * Null if the skip is owned by a question.
	 */
	@Column( name = "form_id" )
	private Long formId;
	
	/**
	 * The question that triggered the skip.
	 * (NOTE: A bidirectional association was used here in order to specify 
	 * a different name for the foreign key.)
	 */
	@ManyToOne( optional = false, fetch=FetchType.LAZY )
	@JoinColumn( name = "skip_item_question", insertable=false, updatable=false )
	private BaseQuestion skipTriggerQuestion;
	
	/**
	 * The value of the form which contains the question that triggered the skip.
	 */
	@OneToOne(optional = false, fetch=FetchType.LAZY )
	@JoinColumn( name = "skip_item_form", insertable=false, updatable=false )
	BaseForm skipTriggerForm;
	
	public Long getId() {
		return id;
	}

	public Long getFormId() {
		return formId;
	}

	public Long getFormElementId() {
		return formElementId;
	}
	
	public BaseQuestion getSkipTriggerQuestion() {
		return skipTriggerQuestion;
	}

	public BaseForm getSkipTriggerForm() 
	{
		return skipTriggerForm;
	}
	public QuestionSkipRule getSkip()
	{
		return skip;
	}
	
	public boolean isQuestionSkipDetails()
	{
		return (formElementId != null)? true: false;
	}
}
