package com.healthcit.cacure.utils;

import com.thoughtworks.xstream.XStream;

public class XMLUtils {
	private static XStream xmlConverter = new XStream();
	
	public static String toXML( Object object ) {
		return object == null ? null : xmlConverter.toXML( object );
	}
	
	public static Object fromXML( String xml ) {
		return xml == null ? null : xmlConverter.fromXML( xml );
	}
}
