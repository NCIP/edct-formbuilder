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
