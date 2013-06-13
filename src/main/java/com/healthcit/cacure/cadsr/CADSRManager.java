/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


 
/**
 * Utility class which handles interfacing with the CADSR metadata repository.
 * @author Oawofolu
 */
package com.healthcit.cacure.cadsr;

import gov.nih.nci.cadsr.domain.DataElement;
import gov.nih.nci.cadsr.domain.EnumeratedValueDomain;
import gov.nih.nci.cadsr.domain.PermissibleValue;
import gov.nih.nci.cadsr.domain.ValueDomainPermissibleValue;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseQuestion.QuestionType;
import com.healthcit.cacure.model.ExternalQuestion;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.ExternalQuestionElement.QuestionSource;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.utils.AppConfig;
import com.healthcit.cacure.utils.IOUtils;
import com.healthcit.cacure.utils.XMLUtils;
import com.healthcit.cacure.web.FormElementSearchCriteria;

public class CADSRManager {
	private static Logger log = Logger.getLogger( CADSRManager.class );
	private static String DATE = "Date";
	private static String CADSR_URL_KEY = "cadsr.serviceurl";
	private static String CADSR_SEARCH_CRITERIA_PARAM = "crit";
	private static String CADSR_SEARCH_CRITERIA_PARAM_TYPE = "critType";
	private static enum CADSRSearchType { SINGLEIDSEARCH, MULTIIDSEARCH, TEXTSEARCH, SINGLEPUBLICIDSEARCH, CARTUSERSEARCH };
	
	/**
	 * Queries CADSR repository for questions with the given UUIDs.
	 * @param idList
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public Map<String,gov.nih.nci.cadsr.domain.DataElement> findCADSRQuestionsById( String idList )
	{	
		try 
		{
			String xmlResults = queryCADSR( idList, CADSRSearchType.MULTIIDSEARCH );
			@SuppressWarnings("rawtypes")
			List<gov.nih.nci.cadsr.domain.DataElement> results = ( List ) XMLUtils.fromXML( xmlResults );
			return transformCADSRResultsToMap(results);
		} 
		catch (Exception ex) 
		{
			ex.printStackTrace();
		}
		
		return null;
	}
	
	/**
	 * Transforms a given CADSR DataElement into a FormBuilder Question entity.
	 * @param sourceQuestion
	 * @param answerType 
	 * @return
	 */
	public ExternalQuestionElement transformCADSRQuestion(gov.nih.nci.cadsr.domain.DataElement sourceQuestion)
	{
		return transformCADSRQuestion(sourceQuestion, null, null);
	}
	
	public ExternalQuestionElement transformCADSRQuestion(gov.nih.nci.cadsr.domain.DataElement sourceQuestion, AnswerType answerType, Set<String> deletedAnswerValues)
	{
//		int numAnswers = 1;
		ExternalQuestionElement targetElement = new ExternalQuestionElement();

		targetElement.setExternalUuid          ( sourceQuestion.getId() );
		targetElement.setDescription   ( getQuestionDescription( sourceQuestion ) );

		targetElement.setLearnMore     ( sourceQuestion.getPreferredDefinition() );
		targetElement.setSourceId(String.valueOf(sourceQuestion.getPublicID()) );
//		targetElement.setType          ( getQuestionType( sourceQuestion ) );	
		targetElement.setLink          ( QuestionSource.CA_DSR, String.valueOf( sourceQuestion.getPublicID() ) );
		targetElement.setExternalVersion( sourceQuestion.getVersion() );
		
		
		AnswerType finalAnswerType = answerType == null ? getAnswerType(sourceQuestion) : answerType;
		//create a question
		ExternalQuestion targetQuestion = new ExternalQuestion();
		targetQuestion.setShortName     ( sourceQuestion.getPreferredName() );
		targetQuestion.setType(AnswerType.CHECKBOX.equals(finalAnswerType) ? QuestionType.MULTI_ANSWER : QuestionType.SINGLE_ANSWER);
		targetElement.setQuestion(targetQuestion);
		
		// set answers/answer-related properties
		
		Answer answer = new Answer();
		answer.setType        ( finalAnswerType );
		answer.setDescription ( sourceQuestion.getLongName() );	
		targetElement.setAnswerType(answer.getType());
		if ( sourceQuestion.getValueDomain() instanceof EnumeratedValueDomain ) 
		{
			// Set the answer values
			Collection<ValueDomainPermissibleValue> coll =
				((EnumeratedValueDomain)sourceQuestion.getValueDomain()).getValueDomainPermissibleValueCollection();
			int numAnswerValues = 0;
			for ( ValueDomainPermissibleValue val : coll ) 
			{		
				AnswerValue answerValue = new AnswerValue();
				PermissibleValue permissibleValue = val.getPermissibleValue();
				if(deletedAnswerValues != null && deletedAnswerValues.contains(permissibleValue.getId())) {
					continue;
				}
				answerValue.setExternalId    ( permissibleValue.getId() );
				answerValue.setValue          ( permissibleValue.getValue() );
				answerValue.setDescription    ( permissibleValue.getValue() );
				answerValue.setName           ( permissibleValue.getValue() );
				answerValue.setCadsrPublicId  ( permissibleValue.getValueMeaning() == null ? 
						                        null : 
						                        permissibleValue.getValueMeaning().getPublicID() );
				answerValue.setOrd            ( ++numAnswerValues );
				answer.addAnswerValues        ( answerValue );	
			}			
		} 
		
		// If there were no answer values, then 
		// add a dummy value to prevent the AnswerPresenter custom tag from crashing
		if ( CollectionUtils.isEmpty( answer.getAnswerValues()) ) 
		{
			answer.addDefaultAnswerValue();
		}
	
		targetQuestion.setAnswer( answer );
		
		return targetElement;
	}
	
	@SuppressWarnings("unchecked")
	public static List<?> getSearchResults( String questionSearchString, int questionSearchType ) 
	{
		List<?> results = new ArrayList<Question>();
		try {
			CADSRSearchType caDSRSearchType = 
			 ( questionSearchType == FormElementSearchCriteria.SEARCH_BY_CADSR_TEXT      ? CADSRSearchType.TEXTSEARCH :
			   questionSearchType == FormElementSearchCriteria.SEARCH_BY_CADSR_CART_USER ? CADSRSearchType.CARTUSERSEARCH :
			   null );			
			String xmlResults = queryCADSR( questionSearchString, caDSRSearchType );
			results = ( List<DataElement> ) XMLUtils.fromXML( xmlResults );
		} catch (Exception ex) {
			log.debug("Error occurred during CADSR search");
			ex.printStackTrace();
		}		
		return results;
	}
	
	// returns the description associated with this question
	private static String getQuestionDescription( DataElement question ) {
		String description = null;
		Iterator<gov.nih.nci.cadsr.domain.ReferenceDocument> iterator = question.getReferenceDocumentCollection().iterator();
		if ( iterator.hasNext() ) description = iterator.next().getDoctext();
		return description;
	}
	
	//TODO: Handle all possible data types (currently only handles Date and TEXT)
	private static AnswerType getAnswerType( DataElement question ) {
		String cadsrDataType = question.getValueDomain().getDatatypeName();
		
		AnswerType dataType = null;
		
		if ( question.getValueDomain() instanceof EnumeratedValueDomain ) {
			dataType = AnswerType.RADIO;
		}
		else if ( StringUtils.equalsIgnoreCase( cadsrDataType, DATE )) {
			dataType = AnswerType.DATE;
		}
		else { 
			dataType = AnswerType.TEXT;
		}
		
		return dataType;
	}
	
	// TODO: Handle all possible types for questions (currently only handles SINGLE_ANSWER questions)
	/*
	private static QuestionType getQuestionType( DataElement question ) {		
		return QuestionType.SINGLE_ANSWER;
	}
	*/
	/**
	 * Invokes an HTTP Get Request which will query the CADSR metadata repository.
	 * @param object
	 * @return
	 */
	private static String queryCADSR( String object, CADSRSearchType searchType ) {
		String url, str = null;
		try {
			url = IOUtils.constructLocalUrl( AppConfig.getString( CADSR_URL_KEY  ), 
					                         new String[]{ CADSR_SEARCH_CRITERIA_PARAM, CADSR_SEARCH_CRITERIA_PARAM_TYPE },
					                         new String[]{ object, searchType.name() });
			log.debug( "CADSR Query URL is " );
			log.debug( url );
			str = IOUtils.getURLContent( url, true );
		} catch( Exception ex ) {
			ex.printStackTrace();
		}
		return StringUtils.defaultIfEmpty( str, null );
	}
	
	private static Map<String,DataElement> transformCADSRResultsToMap( List<DataElement> list){
		Map<String,DataElement> results = new HashMap<String,DataElement>();
		if ( list != null ) 
		{
			for ( Iterator<DataElement> iterator = list.iterator(); iterator.hasNext(); ) {
				DataElement dataElement = iterator.next();
				if ( dataElement.getId() != null ) results.put( dataElement.getId(), dataElement );				
			}
		}
		return results;
	}

}
