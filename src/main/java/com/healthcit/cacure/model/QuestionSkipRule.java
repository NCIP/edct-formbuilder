/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.apache.commons.lang.StringUtils;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;

import com.healthcit.cacure.model.TableElement.TableType;

@Entity
@Table(name="question_skip_rule")
public class QuestionSkipRule implements StateTracker, Cloneable {

	public enum LogicalOperator { OR, AND };
	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	protected Long id;

	@Column(name="logical_op")
	protected String logicalOp;
	
	@Column(name="rule_value", nullable=true)
	protected String ruleValue;
	
	@Transient
	protected boolean valid=true;

	@ManyToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH},  fetch=FetchType.LAZY )
	@JoinColumn(name="parent_id")
	private BaseSkipRule skipRule;
	
	@Column(name="identifying_answer_value_uuid")
	private String identifyingAnswerValueUuId;
	
	@ManyToOne(fetch=FetchType.LAZY )
	@JoinColumn(name="identifying_answer_value_uuid", updatable=false, insertable=false, referencedColumnName="permanent_id")
	private AnswerValue identifyingAnswerValue;

	/* The readonly entity BaseSkipPatternDetails is used to construct skips in XForms*/
	@OneToOne(mappedBy="skip")
	protected BaseSkipPatternDetail details;

	@OneToMany(orphanRemoval = true, mappedBy="questionSkipRule", cascade={CascadeType.ALL}, fetch=FetchType.EAGER )
	@Fetch(FetchMode.SUBSELECT)
	protected List<AnswerSkipRule> answerSkipRules = new ArrayList<AnswerSkipRule>();

	/**
	 * default constructor
	 */
	public QuestionSkipRule() {
		
	}

	/**
	 * helper constructor
	 */
	public QuestionSkipRule(boolean valid)
	{
		this.valid = valid;
	}

	
	public void setSkipRule(BaseSkipRule rule)
	{
		this.skipRule = rule;
	}
	
	public BaseSkipRule getSkipRule()
	{
		return skipRule;
	}
	public List<AnswerSkipRule> getSkipParts()
	{
		return answerSkipRules;
	}
	
	public void setSkipParts(List<AnswerSkipRule> parts)
	{
		this.answerSkipRules = parts;
	}
	
	public BaseSkipPatternDetail getDetails()
	{
		return details;
	}
	
//	TODO It's better to move this in custom tag
	public String getDescription() {
		List<AnswerSkipRule> skipParts = getSkipParts();
		ArrayList<String> answerDescriptions = new ArrayList<String>();
		for (AnswerSkipRule skipPart : skipParts) {
			if(skipPart.getAnswerValue() != null) {
				answerDescriptions.add("\"" + skipPart.getAnswerValue().getDescription() + "\"");
			}
		}
		BaseSkipPatternDetail detail = getDetails();
		if(detail != null) {
			BaseQuestion skipTriggerQuestion = detail.getSkipTriggerQuestion();
			FormElement formElement = skipTriggerQuestion.getParent();
			String questionDescription = formElement.getDescription();
			String rowDescription = null;
			String columnDescription = null;
			if(skipTriggerQuestion instanceof TableQuestion) {
				TableElement tableElement = (TableElement) formElement;
				TableQuestion tableQuestion = (TableQuestion)skipTriggerQuestion;
				if(TableType.SIMPLE.equals(tableElement.getTableType())) {
					rowDescription = tableQuestion.getDescription();
				} else if(getIdentifyingAnswerValue() != null) {
					rowDescription = getIdentifyingAnswerValue().getDescription();
					columnDescription = tableQuestion.getDescription();
				}
			}
			StringBuilder sb = new StringBuilder("Show this question when answer:");
			sb.append(StringUtils.join(answerDescriptions, " " + getLogicalOp() + " "));
			if(questionDescription != null) {
				sb.append("\nQuestion:\"");
				sb.append(questionDescription);
				sb.append("\"");
			}
			if(rowDescription != null) {
				sb.append("\nRow:\"");
				sb.append(rowDescription);
				sb.append("\"");
			}
			if(columnDescription != null) {
				sb.append("\nColumn:\"");
				sb.append(columnDescription);
				sb.append("\"");
			}
			return sb.toString();
		}
		return "";
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
	/**
	 * @return the ruleValue
	 */
	public String getRuleValue() {
		return ruleValue;
	}
	/**
	 * @param ruleValue the ruleValue to set
	 */
	public void setRuleValue(String ruleValue) {
		this.ruleValue = ruleValue;
	}

	@Override
	public boolean isNew() {
		return (id == null);
	}
		
	public String getLogicalOp()
	{
		return logicalOp;
	}
	
	public void setLogicalOp(String logicalOp)
	{
		this.logicalOp = logicalOp;
	}

	/**
	 * isEmpty returns true if valid flag is false and ID is null
	 * @return boolean
	 */
	@Transient
	public boolean isEmpty()
	{
		return (! valid && id == null);
	}
	/**
	 * @return the valid
	 */
	public boolean isValid() {
		return valid;
	}

	/**
	 * @param valid the valid to set
	 */
	public void setValid(boolean valid) {
		this.valid = valid;
	}
    
	public String getAnswerValueId() {
		StringBuilder answerIds = new StringBuilder(100);
		for( int i=0; i<answerSkipRules.size(); i++)
		{
			AnswerSkipRule skipPart = answerSkipRules.get(i);
			String answerId = skipPart.getAnswerValueId();
			answerIds.append(answerId);
			if (i != (answerSkipRules.size() -1))
			{
				answerIds.append(" " + logicalOp +" ");
			}
		}
		
		return answerIds.toString();
	}

	public void setAnswerValue(String answerValueIds, Long formId)
	{
		
		String[] answerValues;
		if (answerValueIds.indexOf(" " + LogicalOperator.OR.name()+ " ") >-1 )
		{
			this.logicalOp = LogicalOperator.OR.name();
			answerValues = answerValueIds.split(" " + logicalOp + " "); 
		}
		else if (answerValueIds.indexOf(LogicalOperator.AND.name()) >-1)
		{
			this.logicalOp = LogicalOperator.AND.name();
			answerValues = answerValueIds.split(" " + logicalOp + " "); 
		}
		else
		{
			// there is only one value
			this.logicalOp = null;
			answerValues = new String[1];
			answerValues[0] = answerValueIds;
		}
		for(String answerValueId: answerValues)
		{
			AnswerSkipRule skipPart = new AnswerSkipRule();
			skipPart.setAnswerValueId(answerValueId);
			skipPart.setFormId(formId);
			skipPart.setParentSkip(this);
			answerSkipRules.add(skipPart);
			
		}
	}
	
//	public BaseSkipRule getSkipRule() {
//		return elem;
//	}
//
//	public void setFormElement(FormElement element) {
//		this.element = element;
//	}
	
	
	@Transient
	public boolean isExternalSkip(FormElement element) {
		if ( element.getForm() == null ) return false;
		BaseForm triggerForm = getDetails().getSkipTriggerForm();
		return ! element.getForm().getUuid().equals( triggerForm.getUuid() );
	}

	
	@Override
	public QuestionSkipRule clone() {
		QuestionSkipRule o = new QuestionSkipRule();
		o.setRuleValue(ruleValue);
		o.setValid(valid);
		o.setLogicalOp(logicalOp);
		o.setIdentifyingAnswerValueUuId(identifyingAnswerValueUuId);
		return o;
	}
	
	public List<AnswerSkipRule> getAnswerSkipRules() 
	{
		return answerSkipRules;
	}

	public void setAnswerSkipRules(List<AnswerSkipRule> answerSkipRules) 
	{
		this.answerSkipRules = answerSkipRules;
	}
	
	public void addAnswerSkipRule(AnswerSkipRule answerSkipRule)
	{
		answerSkipRule.setParentSkip(this);
		if(this.answerSkipRules == null) {
			this.answerSkipRules = new ArrayList<AnswerSkipRule>();
		}
		this.answerSkipRules.add(answerSkipRule);
	
	}
	
	public void setDetails(BaseSkipPatternDetail details) {
		this.details = details;
	}

	public AnswerValue getIdentifyingAnswerValue() {
		return identifyingAnswerValue;
	}

	public void setIdentifyingAnswerValue(AnswerValue identifyingAnswerValue) {
		this.identifyingAnswerValue = identifyingAnswerValue;
	}

	public String getIdentifyingAnswerValueUuId() {
		return identifyingAnswerValueUuId;
	}

	public void setIdentifyingAnswerValueUuId(String identifyingAnswerValueUuId) {
		this.identifyingAnswerValueUuId = identifyingAnswerValueUuId;
	}

}
