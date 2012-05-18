package com.healthcit.cacure.xforms;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.jdom.Attribute;
import org.jdom.Element;
import org.jdom.filter.ElementFilter;

/**
 * This utility class can be used to generate JDOM elements
 * @author Oawofolu
 *
 */
public class XFormsUIBuilder implements XFormsConstants {
	
	public static Element createElement( Element element ){
		return createElement(element, null, null);
	}
	
	public static Element createElement( Element element, Attribute[] attributeArray ){
		return createElement(element, attributeArray, null);
	}
	
	public static Element createElement( Element element, Attribute[] attributeArray, String text ) {
		List<Attribute> attributes = ( attributeArray == null ? new ArrayList<Attribute>() : Arrays.asList( attributeArray ) );
		for ( Attribute attribute : attributes ) {
			element.setAttribute( attribute );
		}
		
		if ( isTextElement( element ) ) {
			if ( StringUtils.isNotBlank( text )) {
				element.addContent( XFormsUtils.parseStringAsXML( text ) );
			}
		}
		
		return element;
	}
	
	public static Element addChild( Element parent, Element child ) {
		if ( child == null ) return parent;
		return addChild( parent, new Element[]{ child } );
	}
	
	public static Element addChild( Element parent, Element[] array ) {
		Collection<Element> collection = Arrays.asList( array );
		parent.addContent( collection );
		return parent;
	}
	
	@SuppressWarnings("unchecked")
	public static Element removeChildByName( Element parent, String elementName ) {
		List<Element> children = parent.getContent( new ElementFilter( elementName, XFormsConstants.XFORMS_NAMESPACE ));
		if ( children.isEmpty() ) return null;
		Element child = (Element)children.get( 0 ).clone();
		parent.removeChild( elementName, XFormsConstants.XFORMS_NAMESPACE );
		return child;
	}
	
	private static boolean isTextElement(Element element) {
		return StringUtils.contains( element.getName(), LABEL_TAG ) ||
		       StringUtils.contains( element.getName(), ALERT_TAG) ||
		       StringUtils.contains( element.getName(), SPAN_TAG);
	}
	
	/**
	 * Given a custom XSD data type declaration,
	 * this method will add to the declaration 
	 * a collection of elements that will allow the data type to mark null entries as valid.
	 * @author oawofolu
	 */
	public static List<Element> createNillableCustomTypeElements(Element customType, String customTypeName){
		List<Element> customTypeElements = new ArrayList<Element>();
		
		Element base = ( Element )customType.clone();
		String baseElementName = StringUtils.defaultIfEmpty(customTypeName,"") + "Base";
		base.setAttribute("name", baseElementName);
		customTypeElements.add( base );
		
		Element emptyString = new Element("simpleType", XFormsConstants.XSD_NAMESPACE);
		emptyString.setAttribute("name", "emptyString");
		Element restriction = new Element("restriction", XFormsConstants.XSD_NAMESPACE);
		restriction.setAttribute("base", XML_TYPE_PREFIX + "string");
		Element pattern = new Element("length", XFormsConstants.XSD_NAMESPACE);
		pattern.setAttribute("value", "0");
		restriction.addContent(pattern);
		emptyString.addContent(restriction);
		customTypeElements.add(emptyString);
		
		Element element = new Element("simpleType", XFormsConstants.XSD_NAMESPACE);
		element.setAttribute("name", customTypeName);
		Element union = new Element("union", XFormsConstants.XSD_NAMESPACE);
		union.setAttribute("memberTypes", "emptyString " + baseElementName);
		element.addContent(union);
		customTypeElements.add(element);
		
		return customTypeElements;
	}
}
