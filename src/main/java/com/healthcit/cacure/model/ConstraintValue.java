/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model;

public class ConstraintValue {
	private String name;
	private String value;
	private String displayName;
	
	public ConstraintValue()
	{
		name = new String();
		value = new String();
	}
	public ConstraintValue(String name, String value, String displayName)
	{
	   this.name = name;
	   this.value = value;
	   this.displayName = displayName;
	}
	public ConstraintValue(String name, String value)
	{
	   this.name = name;
	   this.value = value;
	}
	
	public String getName()
	{
		return name;
	}
	
	public String getValue()
	{
		return value;
	}
	
	public String getDisplayName()
	{
		return displayName;
	}

}
