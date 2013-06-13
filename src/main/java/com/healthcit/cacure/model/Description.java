/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

@Entity
@Table(name="description")
/**
 * The description associated with FormElements.
 * @author oawofolu
 *
 */
public class Description implements Cloneable, Serializable, StateTracker{
		
	private static final long serialVersionUID = 1L;

	@Id
	@SequenceGenerator(name="descSequence", sequenceName="\"question_description_seq\"", allocationSize=1)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="descSequence")
	private Long id;
	
	@Column(name="source_description_text")
	private String description;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}
	
	@Override
	public String toString(){
		return description;
	}
	
	@Override
	public Object clone() 
	{
		Description clone = new Description();
		copy( this, clone );
		return clone;
	}
	
	public static void copy(Description source, Description target) 
	{
		source.setDescription( target.getDescription() );
	}

	@Override
	public boolean isNew() {
		return (this.id == null);
	}
}
