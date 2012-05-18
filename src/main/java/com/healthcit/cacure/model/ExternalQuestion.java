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
@DiscriminatorValue("externalQuestion")
public class ExternalQuestion extends BaseQuestion {
	@Transient
	private static final Logger logger = Logger.getLogger(ExternalQuestion.class);

    @ManyToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH},fetch=FetchType.LAZY)
	@JoinColumn(name="parent_id")
	private ExternalQuestionElement questionElement;
	
	@PrePersist
	public void onPrePersist()
	{
		if ( this.getUuid() == null )
			this.setUuid(UUID.randomUUID().toString());
//		updateForm();
	}

	/* default constructor
	 *
	 */
	public ExternalQuestion()
	{

	}

	public void setQuestionElement (ExternalQuestionElement qt)
	{
		this.questionElement = qt;
	}
	
	public ExternalQuestionElement getQuestionElement()
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
	public  ExternalQuestion copy() {
		ExternalQuestion destination = new ExternalQuestion();
		BaseQuestion.copy(this, destination);
		destination.setShortName(this.getShortName());
		destination.setType(this.getType());
		return destination;
	}

	@Override
	public ExternalQuestion clone() {
		ExternalQuestion o = new ExternalQuestion();
		deepCopy(this, o);
		return o;
	}




}
