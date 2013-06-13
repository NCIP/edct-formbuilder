/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


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
