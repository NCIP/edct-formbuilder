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
import java.util.List;

public class TextValueConstraint extends AnswerValueConstraint {
	private static final long serialVersionUID = 1l;
	public static final String MAX_LENGTH_DISPLAY_NAME = "constraint.text.maxLength";
	private Integer maxLength;
	
	@Override
	public String getValueAsString()
	{
		if ( maxLength != null)
		{
			return String.valueOf(maxLength);
		}
		else 
		{
			return new String();
		}
	}
	
	@Override
	public String getXPathExpression(String operand)
	{
		StringBuilder s = new StringBuilder(100);
		if ( maxLength != null)
		{
			s.append("string-length(");
			s.append(operand);
			s.append(")<= ");
			s.append(maxLength);
		}
		return getXPathWithNilsAllowed(operand,s.toString());
	}
	
	public TextValueConstraint()
	{
		
	}
	public TextValueConstraint(String constraint)
	{
		if ( constraint != null && constraint.length() > 0)
		{
		    maxLength = Integer.valueOf(constraint);
		}
	}
	
	public TextValueConstraint(Integer maxLength)
	{
		this.maxLength = maxLength;
	}

	@Override
	public void createFromList(List<ConstraintValue> constraintValues)
	{
		if (constraintValues != null)
		{
			for (ConstraintValue constraintValue: constraintValues)
			{
				String name = constraintValue.getName();
				if ( "maxLength".equals(name))
				{
					String value = constraintValue.getValue();
					if (value != null && value.length() >0)
					{
						maxLength = Integer.valueOf(value);
					}
				}

			}
		}
	}
	
	@Override
	public List<ConstraintValue> getValuesAsList()
	{
		List<ConstraintValue> constraints = new ArrayList<ConstraintValue>(1);
		ConstraintValue maxLengthConstraint;
		if ( maxLength != null)
		{
			maxLengthConstraint = new ConstraintValue("maxLength", maxLength.toString(), TextValueConstraint.MAX_LENGTH_DISPLAY_NAME);
		}
		else
		{
			maxLengthConstraint = new ConstraintValue("maxLength", null, TextValueConstraint.MAX_LENGTH_DISPLAY_NAME);
		}
		 

		constraints.add(maxLengthConstraint);
		return constraints;
	}
	
	@Override
	public TextValueConstraint clone() {
		TextValueConstraint cloned = new TextValueConstraint(maxLength);
		return cloned;
	}

}
