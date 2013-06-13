/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.model;

public class ValueLabelPair <V, L>{

	private V value;
	private L label;
	public ValueLabelPair(V val, L lab)
	{
		this.value = val;
		this.label = lab;
	}
	
	public V getValue()
	{
		return value;
	}

	public L getLabel()
	{
		return label;
	}
}
