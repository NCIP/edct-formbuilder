package com.healthcit.cacure.web.editors;

import java.beans.PropertyEditorSupport;
import java.util.LinkedHashSet;
import java.util.Set;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.healthcit.cacure.model.Description;
import com.healthcit.cacure.utils.JSONUtils;

public class DescriptionPropertyEditor extends PropertyEditorSupport {
	
	private static final String DESCRIPTION_LIST = "descriptionList";
	private static final String ID = "id";
	private static final String DESCRIPTION = "description";
	
	public DescriptionPropertyEditor(){}

	@Override
	public String getAsText() {
		@SuppressWarnings("unchecked")
		Set<Description> descriptionList = ( Set<Description> ) getValue();
		
		JSONObject json = new JSONObject();
		
		JSONArray jsonDescriptionArray = new JSONArray();
				
		for ( Description description: descriptionList )
		{
			JSONObject jsonDescription = new JSONObject();
			
			jsonDescription.put( ID, description.getId() );
			
			jsonDescription.put( DESCRIPTION, description.getDescription() );
			
			jsonDescriptionArray.add( jsonDescription );
		}
		
		json.put( DESCRIPTION_LIST, jsonDescriptionArray );
		
		return json.toString();
	}

	@Override
	public void setAsText(String jsonText) throws IllegalArgumentException {
		JSONObject doc = JSONObject.fromObject( jsonText );
		
		Set<Description> descriptionList = new LinkedHashSet<Description>();
		
		JSONArray jsonDescriptionList = doc.getJSONArray( DESCRIPTION_LIST );
		
		for ( Object jsonDescription : jsonDescriptionList )
		{
			Description description = new Description();
			
			Object id =JSONUtils.getProperty( (JSONObject)jsonDescription, ID );
						
			if ( !JSONUtils.isNull(id) )
			{
				description.setId( new Long((String)id) );
			}
						
			description.setDescription( (String) JSONUtils.getProperty( (JSONObject)jsonDescription, DESCRIPTION ) );
			
			descriptionList.add( description );
		}
		
		setValue( descriptionList );
	}
	
	

}
