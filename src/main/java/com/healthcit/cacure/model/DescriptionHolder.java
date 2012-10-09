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
package com.healthcit.cacure.model;

import java.util.Set;

import org.apache.commons.lang.StringUtils;

import com.healthcit.cacure.utils.PropertyUtils;


/**
 * Extended by entities that have description mappings.
 * @author oawofolu
 *
 */
public abstract class DescriptionHolder {

	public void updateEmptyDescriptionList(String description) {
		if(StringUtils.isNotBlank(description)) {
			@SuppressWarnings("unchecked")
			Set<Description> descriptionList = (Set<Description>)PropertyUtils.readProperty( this, "descriptionList" );
			
			if ( descriptionList != null && descriptionList.isEmpty() ) {
				
				Description newDescription = new Description();
				
				newDescription.setDescription( description );
				
				descriptionList.add( newDescription );
			}
		}
	}
	
}
