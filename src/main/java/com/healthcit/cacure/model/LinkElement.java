/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model;

import java.util.List;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

import org.apache.commons.lang.StringUtils;

import com.healthcit.cacure.model.Answer.AnswerType;



@Entity
@DiscriminatorValue("link")
public class LinkElement  extends FormElement 
{

	//@Column(name="link_id", nullable=false)
	@Column(name="link_id")
	private String sourceUuid;

	@ManyToOne
	@JoinColumn(name="link_id",unique=false, insertable=false, updatable=false, referencedColumnName="uuid" )
	private FormElement sourceElement;
		
	@Override
	public AnswerType getAnswerType()
	{
		return sourceElement.getAnswerType();
	}
	

	
	public FormElement getSourceElement()
	{
		return sourceElement;
	}
	
  public String getSourceId() {
    return sourceUuid;
	 // return sourceElement.getUuid();
  }
  
  public void setSource(FormElement source)
  {
	    this.sourceUuid = source.getUuid();
	    this.sourceElement = source;
  }
  
  @Override
public boolean isRequired()
  {
		return required;
  }
  
  public String getTableShortName()
  {
	  return isTable() ? (( TableElement ) sourceElement).getTableShortName() : null;
  }
  
  @Override
  public Set<Description> getDescriptionList()
  {
	  return sourceElement.getDescriptionList();
  }
  
  @Override
  public void setDescriptionList(Set<Description> descriptions)
  {
	  sourceElement.setDescriptionList(descriptions);
  }
  
  public void unlink()
  {
    this.sourceUuid= null;
    this.sourceElement = null;
  }
  public boolean isLinked() {
    return StringUtils.isNotEmpty(sourceUuid);// && linkSource != null;
  }


	/**
	 * Returns whether or not this refers to a Table Question
	 * @author Oawofolu
	 * @return
	 */
	@Override
	public boolean isPureContent()
	{
		return sourceElement.isPureContent();
	}
	
	@Override
	public boolean isTable()
	{
		return sourceElement.isTable();
	}
	
	@Override
	public boolean isLink()
	{
		return true;
	}
	@Override
	public boolean isExternalQuestion()
	{
		return false;
	}
	
	@Override
	public boolean isSimpleQuestion() {
		return sourceElement.isSimpleQuestion();
	}
	
	//public abstract QuestionType getType();
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder(100);
		builder.append("LinkId: " + sourceUuid);
		return builder.toString();
	}
	
	@Override
	public void prepareForPersist() {
	}

	@Override
	public void prepareForUpdate()
	{
		  unlink();
	}
	@Override
	public void prepareForDelete() {
	}
	@Override
	public LinkElement clone()
	{
		LinkElement newQuestionElement = new LinkElement();
		copy(this, newQuestionElement);
		return newQuestionElement;
	}

	@Override
	public void resetId()
	{
		this.id= null;
	}
	public static void copy(LinkElement source, LinkElement target)
	{
		FormElement.copy(source, target);
		target.setSource(source.getSourceElement());
	}
	public static void deepCopy(LinkElement source, LinkElement target)
	{
		copy(source, target);
		
	}

	@Override
	public List<? extends BaseQuestion> getQuestions()
	{
		return sourceElement.getQuestions();
	}
	
	
}
