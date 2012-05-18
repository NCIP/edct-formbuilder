package com.healthcit.cacure.model;

import java.util.UUID;

import javax.persistence.CascadeType;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.PrePersist;
import javax.persistence.Transient;

import org.apache.log4j.Logger;




//@Entity(polymorphism=PolymorphismType.EXPLICIT)
@Entity
@DiscriminatorValue("question")
public class Question extends BaseQuestion {
	@Transient
	private static final Logger logger = Logger.getLogger(Question.class);

    @ManyToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH},fetch=FetchType.LAZY)
	@JoinColumn(name="parent_id")
	private QuestionElement questionElement;
	
	@PrePersist
	public void onPrePersist()
	{
		if ( this.getUuid() == null )
			this.setUuid(UUID.randomUUID().toString());
//		updateForm();
	}
/*
	@PreUpdate
	@PreRemove
	@SuppressWarnings("unused")
	private void onUpdate() {
		updateForm();
	}
*/
/*	private void updateForm() {
		QuestionnaireForm form = getForm();
		form.setLastUpdatedBy(form.getLockedBy());
	}
*/
	/* default constructor
	 *
	 */
	public Question()
	{
//		answer = new Answer();
//		answer.setQuestion(this);
		
	}

	public void setQuestionElement (QuestionElement qt)
	{
		this.questionElement = qt;
		}
	
	public QuestionElement getQuestionElement()
	{
		return questionElement;
	}

	@Override
	public FormElement getParent()
	{
		return questionElement;
	}
	/**
	 * @return the learnMore
	 */
	
	@Override
	public Question clone() {
		Question o = new Question();
		deepCopy(this, o);
		return o;
	}

	@Override
	public  Question copy() {
		Question destination = new Question();
		BaseQuestion.copy(this, destination);
		destination.setShortName(this.getShortName());
		destination.setType(this.getType());
		return destination;
      }



}
