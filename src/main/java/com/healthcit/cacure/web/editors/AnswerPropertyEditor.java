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
package com.healthcit.cacure.web.editors;

import java.beans.PropertyEditorSupport;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import net.sf.json.JSONArray;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;

import org.apache.commons.lang.StringUtils;

import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.AnswerValueConstraint;
import com.healthcit.cacure.model.ConstraintValue;


public class AnswerPropertyEditor extends PropertyEditorSupport {

		public AnswerPropertyEditor()
		{
		}

	    @SuppressWarnings("unchecked")
		@Override
	    public void setAsText(String jsonText) throws IllegalArgumentException
	    {
	    	JSONObject jsonAnswer = JSONObject.fromObject(jsonText);
			Answer answer = new Answer();
			answer.setId(jsonAnswer.getString("id").length() == 0 ? null:jsonAnswer.getLong("id"));
			try{
				answer.setUuid(jsonAnswer.getString("uuid").length() == 0 ? null:jsonAnswer.getString("uuid"));
			}
			catch (JSONException e)
			{
				answer.setUuid(null);
			}
			
			answer.setDescription(jsonAnswer.getString("answerDescription"));
			answer.setGroupName(jsonAnswer.getString("groupName"));
			String answerType = StringUtils.defaultIfEmpty( jsonAnswer.getString("type"), "RADIO" );
			answer.setType(AnswerType.valueOf( answerType ));
			answer.setAnswerColumnHeading(jsonAnswer.getString("answerColumnHeading"));
			answer.setDisplayStyle( jsonAnswer.getString("answerDisplayStyle"));

			// create constraints
			if (jsonAnswer.containsKey("answerConstraintsArray"))
			{
				JSONArray constraints = jsonAnswer.getJSONArray("answerConstraintsArray");
				List<ConstraintValue> constraintValues = new ArrayList<ConstraintValue>();
				Iterator<JSONObject> cvIter = constraints.iterator();
				while (cvIter.hasNext())
				{
					JSONObject jsonCV = cvIter.next();
					ConstraintValue constraint = new ConstraintValue(jsonCV.getString("name"), jsonCV.getString("value"));
				    constraintValues.add(constraint);
				}
				answer.setConstraint(constraintValues);
		    }
			// create all AswerValues
			JSONArray answerValues = jsonAnswer.getJSONArray("answerValuesArray");
			Iterator<JSONObject> avIter = answerValues.iterator();
			int answerValueCtr = 0;
			while (avIter.hasNext())
			{
				JSONObject jsonAV = avIter.next();
				AnswerValue av = new AnswerValue();
				av.setId(jsonAV.getString("id").length() == 0 ? null:jsonAV.getLong("id"));
				av.setDescription(jsonAV.getString("answerValueDescription"));
				av.setValue(jsonAV.getString("answerValue"));
				av.setName(jsonAV.getString("shortname"));
				av.setDefaultValue(jsonAV.getBoolean("defaultValue"));
				av.setOrd(++answerValueCtr);

				if( jsonAV.getString("permanentId").length() == 0 || jsonAV.getString("permanentId").equals("") || jsonAV.getString("permanentId").equalsIgnoreCase("undefined") ){
					av.setPermanentId(null);
				} else {
					av.setPermanentId(jsonAV.getString("permanentId"));
				}

				answer.addAnswerValues(av);
			}
	    	setValue(answer);
	    }

	    @Override
	    public String getAsText()
	    {
    		Answer a = (Answer)getValue();
    		Long formId = a.getQuestion().getParent().getForm().getId();
    		JSONObject jsonAnswer = new JSONObject();
    		jsonAnswer.put("id", a.getId());
    		jsonAnswer.put("uuid", a.getUuid());
    		jsonAnswer.put("answerDescription", a.getDescription());
    		jsonAnswer.put("groupName", a.getGroupName());
    		jsonAnswer.put("type", a.getType());
    		jsonAnswer.put("answerColumnHeading", a.getAnswerColumnHeading());
    		jsonAnswer.put("answerDisplayStyle", a.getDisplayStyle());
    		
    		/* populate constraints for answer values */
    		JSONArray jsonAnswerConstraints = new JSONArray();
    		AnswerValueConstraint constraint = a.getConstraint();
    		if (constraint != null)
    		{
	    		List<ConstraintValue> constraintValues = constraint.getValuesAsList();
	    		if (constraintValues != null)
	    		{
	    			for (ConstraintValue constraintValue: constraintValues)
	    			{
	    				jsonAnswerConstraints.add(constraintValue);
	    			}
	    		}
    		}
    		
    		jsonAnswer.put("answerConstraintsArray", jsonAnswerConstraints);

    		// set answer values
	    	JSONArray jsonAnswerValues = new JSONArray();

    		for (AnswerValue av: a.getAnswerValues())
    		{
	    		JSONObject jsonAV = new JSONObject();
	    		jsonAV.put("id", av.getId());
	    		jsonAV.put("answerValueDescription", av.getDescription());
	    		jsonAV.put("answerValue", av.getValue());
	    		jsonAV.put("shortname", av.getName());
	    		jsonAV.put("permanentId", av.getPermanentId());
	    		jsonAV.put("formId", formId);
	    		jsonAV.put("defaultValue", av.isDefaultValue());

	    		jsonAnswerValues.add(jsonAV);
    		}
    		
    		jsonAnswer.put("answerValuesArray", jsonAnswerValues);

//	    	}

    		return jsonAnswer.toString();
	    }
}
