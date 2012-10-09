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
