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

public class PropertyUtils {
	
	/**
	 * Returns the value of a property in a given bean.
	 * @param obj
	 * @param property
	 * @return
	 */
	public static Object readProperty(Object obj, String property) {
		Object value = null;
		try {
			value = org.apache.commons.beanutils.PropertyUtils.getProperty(obj, property);
		} catch (Exception ex){}
		return value;
	}
	
	/**
	 * Sets the value of a property in a given bean.
	 */
	public static void setProperty(Object obj, String property, Object value){
		try{
			org.apache.commons.beanutils.PropertyUtils.setProperty(obj, property, value);
		} catch (Exception ex){}
	}

}
