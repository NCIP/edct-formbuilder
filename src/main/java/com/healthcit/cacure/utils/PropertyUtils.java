/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


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
