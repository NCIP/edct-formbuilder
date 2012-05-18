package com.healthcit.cacure.model;

import java.util.ArrayList;
import java.util.List;


public class NumberValueConstraint extends AnswerValueConstraint {

	private static final long serialVersionUID = 1l;
	
	private Integer minValue;
	private Integer maxValue;
	
	public static final String MIN_VALUE_PREFIX = "min:";
	public static final String MAX_VALUE_PREFIX = "max:";
	public static final String VALUES_SEPARATOR = ";";
	public static final String MIN_VALUE_DISPLAY_NAME = "constraint.number.minValue";
	public static final String MAX_VALUE_DISPLAY_NAME = "constraint.number.maxValue";
	
	public NumberValueConstraint()
	{
		
	}
	public NumberValueConstraint(String constraint)
	{
        if ( constraint != null)
        {
			int minValueIndex = constraint.indexOf(NumberValueConstraint.MIN_VALUE_PREFIX);
			int maxValueIndex = constraint.indexOf(NumberValueConstraint.MAX_VALUE_PREFIX);
			if (minValueIndex >= 0)
			{
				String value;
				int separatorIndex = constraint.indexOf(';', minValueIndex);
				if ( separatorIndex >0)
				{
					value = constraint.substring(minValueIndex +NumberValueConstraint.MIN_VALUE_PREFIX.length() , separatorIndex);
				}
				else 
				{
					value = constraint.substring(minValueIndex +NumberValueConstraint.MIN_VALUE_PREFIX.length());
				}
				this.minValue = Integer.valueOf(value);
			}
			if (maxValueIndex >= 0)
			{
				String value;
				int separatorIndex = constraint.indexOf(';', maxValueIndex);
				if ( separatorIndex >0)
				{
					value = constraint.substring(maxValueIndex +NumberValueConstraint.MAX_VALUE_PREFIX.length() , separatorIndex);
				}
				else 
				{
					value = constraint.substring(maxValueIndex +NumberValueConstraint.MAX_VALUE_PREFIX.length());
				}
				this.maxValue = Integer.valueOf(value);
			}
        }
	}
	
	@Override
	public void createFromList(List<ConstraintValue> constraintValues)
	{
		if (constraintValues != null)
		{
			for (ConstraintValue constraintValue: constraintValues)
			{

				String name = constraintValue.getName();
				if ( "minValue".equals(name))
				{
					String value = constraintValue.getValue();
					if (value != null && value.length() > 0)
					{
						minValue = Integer.valueOf(value);
					}
				}
				else if ( "maxValue".equals(name))
				{
					String value = constraintValue.getValue();
					if (value != null && value.length() > 0)
					{
						maxValue = Integer.valueOf(value);
					}

					
				}
			}
		}
	}
	@Override
	public List<ConstraintValue> getValuesAsList()
	{
		List<ConstraintValue> constraints = new ArrayList<ConstraintValue>(2);
		ConstraintValue minValueConstraint;
		if ( minValue != null)
		{
			minValueConstraint = new ConstraintValue("minValue", minValue.toString(), NumberValueConstraint.MIN_VALUE_DISPLAY_NAME);

		}
		else 
		{
			minValueConstraint = new ConstraintValue("minValue", null, NumberValueConstraint.MIN_VALUE_DISPLAY_NAME);
		}
		ConstraintValue maxValueConstraint;
		if (maxValue != null)
		{
			maxValueConstraint = new ConstraintValue("maxValue", maxValue.toString(), NumberValueConstraint.MAX_VALUE_DISPLAY_NAME);
		}
		else
		{
			maxValueConstraint = new ConstraintValue("maxValue", null, NumberValueConstraint.MAX_VALUE_DISPLAY_NAME);
		}
		

		constraints.add(minValueConstraint);
		constraints.add(maxValueConstraint);
		return constraints;
	}
	public NumberValueConstraint(Integer minValue, Integer maxValue)
	{
		this.minValue = minValue;
		this.maxValue = maxValue;
	}
	
	@Override
	public String getValueAsString() {
		StringBuilder s = new StringBuilder(100);
		if (minValue != null)
		{
			s.append(NumberValueConstraint.MIN_VALUE_PREFIX);
			s.append(minValue.toString());
		}
		if(minValue != null && maxValue != null)
		{
			s.append(NumberValueConstraint.VALUES_SEPARATOR);
		}
		if(maxValue != null)
		{
			s.append(NumberValueConstraint.MAX_VALUE_PREFIX);
			s.append(maxValue.toString());
		}
		return s.toString();
	}
	
	@Override
	public String getXPathExpression(String operand)
	{
		StringBuilder s = new StringBuilder(100);
		if (minValue != null)
		{
			s.append(operand);
			s.append(" >= ");
			s.append(minValue.toString());
		}
		if(minValue != null && maxValue != null)
		{
			s.append(" and ");
		}
		if(maxValue != null)
		{
			s.append(operand);
			s.append(" <= ");
			s.append(maxValue.toString());
		}
		return getXPathWithNilsAllowed(operand,s.toString());
			
	}
	
	@Override
	public NumberValueConstraint clone(){
		NumberValueConstraint cloned = new NumberValueConstraint(minValue, maxValue);
		return cloned;
	}

}
