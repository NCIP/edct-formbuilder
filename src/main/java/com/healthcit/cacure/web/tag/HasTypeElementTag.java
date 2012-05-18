package com.healthcit.cacure.web.tag;

import java.io.IOException;
import java.util.Collection;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * Checks is collection <code>objects</code> contains object of type <code>clazz</code>.<br/>
 */
public class HasTypeElementTag extends TagSupport {

	private static final long serialVersionUID = 1L;
	
	private Collection<Object> objects;
	
	@SuppressWarnings("rawtypes")
	private Class clazz;
	
	public void setObjects(Collection<Object> objects) {
		this.objects = objects;
	}
	
	public void setClazz(@SuppressWarnings("rawtypes") Class clazz) {
		this.clazz = clazz;
	}
	
	@Override
	public int doStartTag() throws JspException {
		boolean hasObject = false;
		if(this.objects != null)
		{
			for(Object object : this.objects)
			{
				if(object.getClass().equals(this.clazz))
				{
					hasObject = true;
					break;
				}
			}
		}
		try {
			this.pageContext.getOut().write(String.valueOf(hasObject));
		} catch (IOException e) {
			throw new JspTagException("Error: IOException while writing to the user");
		}
		return SKIP_BODY;
	}
}
