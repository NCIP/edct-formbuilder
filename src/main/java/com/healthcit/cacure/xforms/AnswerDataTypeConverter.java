package com.healthcit.cacure.xforms;

import java.util.ArrayList;
import java.util.List;

import org.jdom.Element;

import com.healthcit.cacure.model.Answer.AnswerType;

public class AnswerDataTypeConverter
{
	static public String XML_TYPE_PREFIX = "xform:";
	static public String MY_TYPE_PREFIX = XFormsConstants.HCIT_NS_PREFIX;

	static public String toXmlType(AnswerType answerType)
	{
		if (answerType == AnswerType.TEXT)
			return xsdType("string");
		else if (answerType == AnswerType.NUMBER)
			return xsdType("decimal");
		else if (answerType == AnswerType.INTEGER)
			return xsdType("integer");
		else if (answerType == AnswerType.POSITIVE_INTEGER)
			return xsdType("positiveInteger");
		/*else if (answerType == AnswerType.FLOAT)
			return xsdType("float");*/
		else if (answerType == AnswerType.DATE)
			return xsdType("date");
		else if (AnswerType.YEAR.equals(answerType))
		{
			return xsdType("gYear");
		}
		else if (AnswerType.MONTHYEAR.equals(answerType))
		{
			return customType("gMonthYear");
		}
		else
			return xsdType("string");
	}

	static private String xsdType(String localName)
	{
		return XML_TYPE_PREFIX + localName;
	}

	static private String customType(String localName)
	{
		return MY_TYPE_PREFIX + localName;
	}
	static public List<Element> createCustomTypeElements(AnswerType answerType)
	{
		List<Element> elements = null;
		if (AnswerType.MONTHYEAR.equals(answerType))
		{		
			Element customType = new Element("simpleType", XFormsConstants.XSD_NAMESPACE);
			customType.setAttribute("name", "gMonthYear");
			Element restriction = new Element("restriction", XFormsConstants.XSD_NAMESPACE);
			restriction.setAttribute("base", XFormsConstants.XSD_NAMESPACE.getPrefix() +":" + "gYearMonth");
			Element pattern = new Element("pattern", XFormsConstants.XSD_NAMESPACE);
			pattern.setAttribute("value", "(01|02|03|04|05|06|07|08|09|10|11|12)[\\/-][1,2][0-9]{3}");
			restriction.addContent(pattern);
			customType.addContent(restriction);			
			elements = XFormsUIBuilder.createNillableCustomTypeElements(customType, "gMonthYear");
	    }
		return elements;
	}
}
