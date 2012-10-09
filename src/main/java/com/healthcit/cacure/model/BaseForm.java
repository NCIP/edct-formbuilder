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

import java.util.ArrayList;
import java.util.Date;
import java.util.EnumSet;
import java.util.List;
import java.util.UUID;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorColumn;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Proxy;

import com.healthcit.cacure.model.BaseQuestion.ChildrenRemovalType;

@Entity
@Table(name="FORM")
@Inheritance(strategy=InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name="FORM_TYPE")
@Proxy(lazy=false)
public abstract class BaseForm  implements StateTracker
{

	public enum FormStatus {IN_PROGRESS, IN_REVIEW, APPROVED, QUESTION_LIBRARY, FORM_LIBRARY}

	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	protected Long id;

	@ManyToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH}, optional=false)
	@JoinColumn(name="module_id")
	protected BaseModule module;
	
	@Enumerated (EnumType.STRING)
	@Column(nullable=false)
	protected FormStatus status = FormStatus.IN_PROGRESS;
	
	@Column(nullable=false, length=100)
	protected String name;

	
	// Each  form be uniquely identified across systems
	@Column(name="uuid", nullable=false)
	protected String uuid;

	@OneToMany(mappedBy="form",	cascade = CascadeType.ALL)
	@OrderBy("ord")
	protected List<FormElement> elements = new ArrayList<FormElement>();

	@Column(name="ord", nullable=false)
	protected Integer ord;

	@ManyToOne(targetEntity=UserCredentials.class)
	@JoinColumn(name="author_user_id")
	protected UserCredentials author;

	@ManyToOne(targetEntity=UserCredentials.class)
	@JoinColumn(name="locked_by_user_id")
	protected UserCredentials lockedBy;

	@ManyToOne(targetEntity=UserCredentials.class)
	@JoinColumn(name="last_updated_by_user_id")
	protected UserCredentials lastUpdatedBy;

	@Column(name="update_date")
	protected Date updateDate;

	
	public UserCredentials getAuthor() {
		return author;
	}


	public void setAuthor(UserCredentials author) {
		this.author = author;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	public List<FormElement> getElements() {
		return elements;
	}


	public Integer getOrd() {
		return ord;
	}

	public void setOrd(Integer ord) {
		this.ord = ord;
	}

	public String getUuid()
	{
		return uuid;
	}

	
	public FormStatus getStatus() {
		return status;
	}
	
	protected EnumSet<FormStatus> getAllowedStatuses() {
		return EnumSet.allOf(FormStatus.class);
	}
	
	public void setStatus(FormStatus status) {
		if(status != null && getAllowedStatuses().contains(status)) {
			this.status = status;
		}
	}
	/**
	 * uuid is generate and must not be reset by the application
	 * @param uuid
	 */
	/* changed to public to be able to set the uuid during form's import */
	public void setUuid(String uuid)
	{
		this.uuid = uuid;
	}

	@Override
	public boolean isNew() {
		return (id == null);

	}
	/**
	 * @return a reference to the user who has locked the form
	 */
	public UserCredentials getLockedBy() {
		return lockedBy;
	}

	/**
	 * @param lockedBya reference to the user who has locked the form
	 */
	public void setLockedBy(UserCredentials lockedBy) {
		this.lockedBy = lockedBy;
	}

	public UserCredentials getLastUpdatedBy() {
		return lastUpdatedBy;
	}


	public void setLastUpdatedBy(UserCredentials lastUpdatedBy) {
		this.lastUpdatedBy = lastUpdatedBy;
	}


	public boolean isLibraryForm()
	{
		return false;
	}
	/**
	 * @return whether the form is currently locked
	 */
	public boolean isLocked() {
		return lockedBy != null;
	}

	public Date getUpdateDate() {
		return updateDate;
	}


	public void setUpdateDate(Date updateDate) {
		this.updateDate = updateDate;
	}


	public void prepareForPersist() {
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

	public void prepareForUpdate() {
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

	public void prepareForDelete() {
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}
	public void removeExtraneousChildren(ChildrenRemovalType removalType)
	{
		
	}

	public BaseModule getModule()
	{
		return module;
	}
	
    public abstract boolean isEditable();
	public abstract void setElements(List<FormElement> elements);
	public abstract void addElement(FormElement element);
	
	
	@SuppressWarnings("unused")
	@PreUpdate
	private void updateValues() {
		this.updateDate = new Date();
	}

	@PrePersist
	public void setInitialValues()
	{
		if ( this.getUuid() == null )
			setUuid(UUID.randomUUID().toString());
		this.updateDate = new Date();
		this.lastUpdatedBy = author;
	}
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder(1000);
		builder.append("UUID: " + uuid);
		builder.append(", ");
		builder.append("Name: " + name);
		builder.append(", ");
//		builder.append("Elements: " + elements.toString());
		return builder.toString();
	}

}
