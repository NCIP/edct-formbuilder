/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.utils;

import net.sf.json.JSONObject;

public class JSONUtils {
	public static Object getProperty( JSONObject source, String property )
	{
		Object propertyValue = null;
		
		if ( source.containsKey( property) )
		{
			propertyValue = source.get( property );
			if ( isNull( propertyValue ) )
			{
				propertyValue = null;
			}
		}
		
		return propertyValue;
	}
	
	public static boolean isNull(Object obj)
	{
		return net.sf.json.util.JSONUtils.isNull(obj);
	}
}
