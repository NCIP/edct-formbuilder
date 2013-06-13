/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.web.editors;

import java.beans.PropertyEditorSupport;
import java.util.List;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.lang.math.NumberUtils;

import com.healthcit.cacure.dao.SkipPatternDao;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.BaseSkipRule;
import com.healthcit.cacure.model.QuestionSkipRule;

/**
 * Property Editor for the BaseSkipPattern model.
 * @author Oawofolu
 *
 */
public class SkipPatternPropertyEditor<T extends BaseSkipRule> extends PropertyEditorSupport 
{
	Class<T> skipPatternClass;
	
	SkipPatternDao skipDao;
	/**
	 * Explicit constructor
	 */
//	public SkipPatternPropertyEditor( final Class<T> skipPatternClass )
//	{
//		this.skipPatternClass = skipPatternClass;
//	}
	
	public SkipPatternPropertyEditor( final Class<T> skipPatternClass, SkipPatternDao skipDao )
	{
		this.skipPatternClass = skipPatternClass;
		this.skipDao = skipDao;
	}
	
	public T createNewInstance()
	{
		try {
			return skipPatternClass.newInstance();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	public String getAsText()
	{
		BaseSkipRule skipRule = (BaseSkipRule)getValue();
		if (skipRule == null)
		{
			skipRule = createNewInstance();
		}
		List<QuestionSkipRule> skips = skipRule.getQuestionSkipRules();
		//List<T> skips = (List<T>) getValue();

		JSONObject skipObject = new JSONObject();
		JSONArray skipList = new JSONArray();

		for ( QuestionSkipRule skip : skips ) 
		{
			BaseQuestion skipTriggerQuestion = skip.getDetails().getSkipTriggerQuestion();
			Long questionId = skipTriggerQuestion.getId();
			Long skipTriggerElementId = skipTriggerQuestion.getParent().getId();
			JSONObject obj = new JSONObject();
			//wonder if I need to worry about null values
			obj.put( "questionId", questionId);
			if(skip.getIdentifyingAnswerValueUuId() != null) {
				obj.put( "rowUuId", skip.getIdentifyingAnswerValueUuId());
			}
			obj.put( "id", skip.getId() );
			obj.put( "description", skip.getDescription().replaceAll("\n", "<br/>") );
			obj.put( "answerValueId", skip.getAnswerValueId() );
			obj.put( "formId", skip.getDetails().getSkipTriggerForm().getId() );
			obj.put("formElementId", skipTriggerElementId);
			skipList.add( obj );
		}
		
		skipObject.put("skipList", skipList );
		skipObject.put("logicalOp", skipRule.getLogicalOp());
		skipObject.put("id", skipRule.getId());
		return skipObject.toString(); 
	}

	@SuppressWarnings("unchecked")
	@Override
	public void setAsText(String text) throws IllegalArgumentException 
	{
		JSONObject skipObject = JSONObject.fromObject( text );
		String ruleSkipLogicalOp = skipObject.getString("logicalOp");
		JSONArray questionSkipRules = skipObject.getJSONArray( "skipList");
		
		T skipRule = null;// createNewInstance();
		
		Long skipRuleId = null;
		try{
		if ( NumberUtils.isNumber( skipObject.getString( "id" ) ) )
			skipRuleId = skipObject.getLong("id");
		}
		catch(Exception e)
		{
			//id is null
		}
		if(skipRuleId != null)
		{
	
			skipRule = (T)skipDao.getById(skipRuleId);
		}
		else
		{
			skipRule = createNewInstance();
		}
		if ( !questionSkipRules.isEmpty() ) 
		{


			skipRule.setLogicalOp(ruleSkipLogicalOp);
		//	JSONArray skipList = skipObject.getJSONArray( getSkipPatternListPropertyName() );
			skipRule.getQuestionSkipRules().clear();
//			List<QuestionSkipRule> skips = new ArrayList<QuestionSkipRule> ();
			for ( Object obj : questionSkipRules )
			{
				JSONObject jsonObject = ( JSONObject ) obj;

				// if the skip pattern already exists, mark it as true
				// otherwise, a new skip pattern will be added
				//T qs = createNewInstance();
				QuestionSkipRule qs = new QuestionSkipRule();
				qs.setValid( true );

				// Set the Skip properties
				
//				if ( NumberUtils.isNumber( jsonObject.getString( "id" ) ) )
//					qs.setId( jsonObject.getLong("id") );
				String formId = jsonObject.getString( "formId" );
				qs.setAnswerValue( jsonObject.getString( "answerValueId" ), Long.parseLong(formId));
				qs.setRuleValue( "show" );
				if ( jsonObject.containsKey("rowUuId") 
						&& jsonObject.getString("rowUuId").length() != 0 ) {
					qs.setIdentifyingAnswerValueUuId(jsonObject.getString("rowUuId"));
				}
				skipRule.addQuestionSkipRule( qs );
			}
			//skipRule.setQuestionSkipRule(skips);
		// Finally, set the collection of skips
		}
		else
		{
			if(skipRuleId != null)
			{
				skipDao.delete(skipRule);
			}
			skipRule = createNewInstance();
	//		skipRule.removeSkips();
		//	skipRule = createNewInstance();
		}
		setValue( skipRule );

	}

/*	private String getSkipPatternListPropertyName()
	{
		if ( this.skipPatternClass.equals( FormElementSkipRule.class ) )
		{
			return "questionSkipList";
		}
		else 
		{
			return "formSkipList";
		}
		
	}
	*/

}
