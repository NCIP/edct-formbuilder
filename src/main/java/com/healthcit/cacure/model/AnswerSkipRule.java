package com.healthcit.cacure.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import javax.persistence.JoinColumn;

import javax.persistence.ManyToOne;

import javax.persistence.SequenceGenerator;
import javax.persistence.Table;



@Entity
@Table(name="answer_skip_rule")
public class AnswerSkipRule implements Cloneable {

	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	protected Long id;

	@Column(name="answer_value_id", nullable=false)
	protected String answerValueId;

	@Column (name="form_id", nullable=false)
	protected Long formId;
	
	@ManyToOne(optional=false, fetch=FetchType.LAZY)
	@JoinColumn(name="parent_id" )
	private QuestionSkipRule questionSkipRule;
	
//	@Formula(value="(select av.value from answer_value_form_id_vw vw, answer_value av, answer a, question q, form_element fe  where vw.av_uuid= answer_value_id and vw.link_form_id=form_id and av.id = vw.av_id and av.answer_id = a.id and a.question_id = q.id and q.parent_id=fe.id)") 
//	protected String answerValue;
	
	@ManyToOne
	@JoinColumn(unique=false, updatable=false, insertable=false, name="answer_value_id", referencedColumnName="permanent_id")
	protected AnswerValue answerValue;
	
	/**
	 * default constructor
	 */
	public AnswerSkipRule() {}

	
	public QuestionSkipRule getParentSkip() {
		return questionSkipRule;
	}

	public void setParentSkip(QuestionSkipRule parentSkip) {
		this.questionSkipRule = parentSkip;
	}
	
	/**
	 * @return the id
	 */
	public Long getId() {
		return id;
	}
	/**
	 * @param id the id to set
	 */
	public void setId(Long id) {
		this.id = id;
	}
	public String getAnswerValueId() {
		return answerValueId;
	}

	public void setAnswerValueId(String answerValueId) {
		this.answerValueId = answerValueId;
	}

	public AnswerValue getAnswerValue()
	{
		return answerValue;
	}
	public void setAnswerValue(AnswerValue answerValue) 
	{
		this.answerValue = answerValue;
	}
	public void setFormId(Long formId)
	{
		this.formId = formId;
	}
	public Long getFormId() 
	{
		return formId;
	}
	@Override
	public AnswerSkipRule clone() {
		AnswerSkipRule answerSkipRule = new AnswerSkipRule();
		answerSkipRule.setAnswerValueId(getAnswerValueId());
		answerSkipRule.setFormId(getFormId());
		return answerSkipRule;
	}
}
