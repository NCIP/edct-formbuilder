package com.healthcit.cacure.web.editors;

import java.beans.PropertyEditorSupport;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import net.sf.json.JSONArray;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;

import org.apache.commons.lang.StringUtils;

import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.AnswerValueConstraint;
import com.healthcit.cacure.model.BaseQuestion.QuestionType;
import com.healthcit.cacure.model.ConstraintValue;
import com.healthcit.cacure.model.TableQuestion;

public class QuestionPropertyEditor extends PropertyEditorSupport {

		public QuestionPropertyEditor()
		{
		}

	    @SuppressWarnings("unchecked")
		@Override
	    public void setAsText(String jsonText) throws IllegalArgumentException
	    {
	    	List<TableQuestion> questionList = new ArrayList<TableQuestion>();
	    	JSONObject jsonDoc = JSONObject.fromObject(jsonText);
			Iterator<JSONObject> iter = jsonDoc.getJSONArray("questionList").iterator();
			int answerValueCtr = 1;
			int questionCtr = 1;
			while (iter.hasNext())
			{
				JSONObject jsonQuestion = iter.next();
				TableQuestion question = new TableQuestion();
				Answer answer = new Answer();
				question.setAnswer(answer);
				question.setOrd(questionCtr++);
				question.setDescription(jsonQuestion.getString("description"));
				String questionType = StringUtils.defaultIfEmpty( jsonQuestion.getString("type"), "SINGLE_ANSWER" );
				question.setType(QuestionType.valueOf(questionType));
				if(jsonQuestion.containsKey("isIdentifying") && jsonQuestion.getBoolean("isIdentifying")) {
					question.setIsIdentifying(jsonQuestion.getBoolean("isIdentifying"));
					question.setShortName("identifyingRowShortName-" + ( jsonQuestion.getString("uuid").length() == 0 ? UUID.randomUUID().toString() : jsonQuestion.getString("uuid")));
				} else {
					question.setShortName(jsonQuestion.getString("shortName"));
				}
				question.setId(!jsonQuestion.containsKey("id") || jsonQuestion.getString("id").length() == 0 ? null:jsonQuestion.getLong("id"));
				try{
					question.setUuid(jsonQuestion.getString("uuid").length() == 0 ? null:jsonQuestion.getString("uuid"));
				}
				catch (JSONException e)
				{
					question.setUuid(null);
				}
				
				JSONObject jsonAnswer = jsonQuestion.getJSONObject("answer");
				answer.setId(!jsonAnswer.containsKey("id") || jsonAnswer.getString("id").length() == 0 ? null:jsonAnswer.getLong("id"));
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
				while (avIter.hasNext())
				{
					JSONObject jsonAV = avIter.next();
					AnswerValue av = new AnswerValue();
					av.setId(!jsonAV.containsKey("id") || jsonAV.getString("id").length() == 0 ? null:jsonAV.getLong("id"));
					av.setDescription(jsonAV.getString("answerValueDescription"));
					av.setValue(jsonAV.getString("answerValue"));
					av.setName(jsonAV.getString("shortname"));
					av.setOrd(answerValueCtr++);

					if( jsonAV.getString("permanentId").length() == 0 || jsonAV.getString("permanentId").equals("") || jsonAV.getString("permanentId").equalsIgnoreCase("undefined") ){
						av.setPermanentId(null);
					} else {
						av.setPermanentId(jsonAV.getString("permanentId"));
					}

					answer.addAnswerValues(av);
				}
				questionList.add(question);
			}

	    	setValue(questionList);
	    }

	    @SuppressWarnings("unchecked")
		@Override
	    public String getAsText()
	    {
	    	List<TableQuestion> questionList = (List<TableQuestion>)getValue();

	    	JSONObject jsonQuestionList = new JSONObject();
	    	JSONArray jsonQuestions = new JSONArray();

	    	for (TableQuestion q: questionList)
	    	{
	    		Long formId = q.getParent().getForm().getId();
	    		
	    		JSONObject jsonQuestion = new JSONObject();
	    		jsonQuestion.put("id", q.getId());
	    		jsonQuestion.put("uuid", q.getUuid());
//				This is only present for table question not for Question or BaseQuestion
//	    		jsonQuestion.put("answerDescription", q.getDescription());
	    		jsonQuestion.put("shortName", q.getShortName());
	    		jsonQuestion.put("type", q.getType());
	    		jsonQuestion.put("description", q.getDescription());
	    		jsonQuestion.put("isIdentifying", q.isIdentifying());
	    		
	    		/* populate constraints for answer values */


	    		// set answer values
                    
		    	Answer answer = q.getAnswer();
		    	/*for (Answer a: answers)
		    	{
		    	*/
		    	
		    		JSONObject jsonAnswer = new JSONObject();
		    		jsonAnswer.put("id", answer.getId());
		    		jsonAnswer.put("uuid", answer.getUuid());
		    		jsonAnswer.put("answerDescription", answer.getDescription());
		    		jsonAnswer.put("groupName", answer.getGroupName());
		    		jsonAnswer.put("type", answer.getType());
		    		jsonAnswer.put("answerColumnHeading", answer.getAnswerColumnHeading());
		    		jsonAnswer.put("answerDisplayStyle", answer.getDisplayStyle());
		    		JSONArray jsonAnswerConstraints = new JSONArray();
		    		AnswerValueConstraint constraint = answer.getConstraint();
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
			    	JSONArray jsonAnswerValues = new JSONArray();
					int avCounter = 1;
		    		for (AnswerValue av: answer.getAnswerValues())
		    		{
		    			
			    		JSONObject jsonAV = new JSONObject();
			    		jsonAV.put("id", av.getId());
			    		jsonAV.put("answerValueDescription", av.getDescription());
			    		jsonAV.put("answerValue", av.getValue());
			    		jsonAV.put("shortname", av.getName());
			    		jsonAV.put("permanentId", av.getPermanentId());
			    		jsonAV.put("formId", formId);
			    		jsonAV.put("internalId", "avInternalId" + avCounter++);
			    		jsonAnswerValues.add(jsonAV);
		    		}
		    		jsonAnswer.put("answerValuesArray", jsonAnswerValues);
		    	//}
	    		jsonQuestion.put("answer", jsonAnswer);
	    		jsonQuestions.add(jsonQuestion);

	    	}

	    	jsonQuestionList.put("questionList", jsonQuestions);
	    	//String tmpStr = jsonAnswerList.toString();

	    	return jsonQuestionList.toString();
	    }
}
