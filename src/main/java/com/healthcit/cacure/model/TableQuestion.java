package com.healthcit.cacure.model;

import java.util.UUID;

import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.PrePersist;
import javax.persistence.Transient;

import org.apache.log4j.Logger;
import org.hibernate.annotations.Formula;




//@Entity(polymorphism=PolymorphismType.EXPLICIT)
@Entity
@DiscriminatorValue("tableQuestion")
public class TableQuestion extends BaseQuestion {
	@Transient
	private static final Logger logger = Logger.getLogger(TableQuestion.class);

    @ManyToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH}, fetch=FetchType.LAZY)
	@JoinColumn(name="parent_id")
	private TableElement table;
	
    private String description;
	@Column(name="ord", nullable=false)
	private Integer ord;

	@Column(name="is_identifying")
	private boolean isIdentifying = false;
    
	
    public String getDescription()
    {
    	return description;
    }
    
    public boolean isIdentifying()
    {
    	return isIdentifying;
    }
    
    public void setIsIdentifying(boolean isIdentifying)
    {
    	this.isIdentifying = isIdentifying;
    }
    
    public boolean getIsIdentifying()
    {
    	return isIdentifying;
    }
    public void setDescription(String description)
    {
    	this.description = description;
    }
    
	public Integer getOrd() {
		return ord;
	}

	public void setOrd(Integer ord) {
		this.ord = ord;
	}
	
	
	@Override
	public FormElement getParent()
	{
		return this.table;
	}
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
	public TableQuestion()
	{

	}

	public void setTable (TableElement qt)
	{
		this.table = qt;
	}
	
	public TableElement getTable()
	{
		return table;
	}

	/**
	 * skip pattern is empty if it's Id is null and its valid flag is set to false
	 */
/*	private void removeExtraneousSkipPatterns(ChildrenRemovalType removalType)
	{
		if (questionSkip == null)
			return;

		// going in normal way, as itertor goes however through each item
		Iterator<QuestionSkip> iter = this.questionSkip.iterator();
		while (iter.hasNext())
		{
			QuestionSkip sp = iter.next();
			if(
				(removalType == ChildrenRemovalType.EMPTY_CHILDREN && sp.isEmpty()) ||
				(removalType == ChildrenRemovalType.INVALID_CHILDREN && ! sp.isValid())
			  )
				{
					iter.remove();
				}
		}

	}
*/
	


	@Override
	public TableQuestion clone() {
		TableQuestion o = new TableQuestion();
		deepCopy(this, o);
		return o;
	}
	
	@Override
	public  TableQuestion copy() {
		TableQuestion destination = new TableQuestion();
		BaseQuestion.copy(this, destination);
		destination.setIsIdentifying(this.getIsIdentifying());
		destination.setDescription(this.getDescription());
		destination.setOrd(this.getOrd());
		return destination;
	}

}
