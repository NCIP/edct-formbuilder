package com.healthcit.cacure.model;

import java.io.Serializable;
import java.util.List;

import org.apache.commons.lang.xwork.StringUtils;

public abstract class AnswerValueConstraint implements Serializable{
	
    private static final long serialVersionUID = 1l;

    public abstract String getValueAsString();  
	
    public abstract List<ConstraintValue> getValuesAsList();
    
    public abstract void createFromList(List<ConstraintValue> constraintValues);
    
    public abstract String getXPathExpression(String operand);
    
 	@Override
	public boolean equals( Object a)
	{
		boolean result = false;
		if (a == null)
		{
			result = false;
		}
		else if (this == a)
		{
			result = true;
		}
		else if(!(a instanceof AnswerValueConstraint))
		{
			result = false;
		}
		else
		{
			String s = this.getValueAsString();
			result = s.equals(((AnswerValueConstraint)a).getValueAsString());
		}
		return result;
	}
	
	@Override
	public int hashCode()
	{
		String s = this.getValueAsString();
		return s.hashCode();
	}
	
	@Override
	public abstract AnswerValueConstraint clone();
	
	// Allows empty XPath result values
	public final String getXPathWithNilsAllowed( String operand, String xpath ) 
	{
		if (StringUtils.isNotBlank(xpath)) 
		{		
			StringBuilder s = new StringBuilder(100);			
			s.append("normalize-space(");
			s.append(operand);
			s.append(")='' or (");
			s.append(xpath);
			s.append(")");			
			return s.toString();
		}
		else
		{
			return xpath;
		}
	}
}
