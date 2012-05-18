package com.healthcit.cacure.utils;

import net.sf.json.JSONObject;

public class JSONUtils {
	public static Object getProperty( JSONObject source, String property )
	{
		Object propertyValue = null;
		
		if ( source.containsKey( property) )
		{
			propertyValue = source.get( property );
		}
		
		return propertyValue;
	}
}
