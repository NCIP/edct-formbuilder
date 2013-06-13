/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.businessdelegates;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import com.healthcit.cacure.dao.CouchDBDao;
import com.healthcit.cacure.dao.FormDao;
import com.healthcit.cacure.dao.ModuleDao;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.model.admin.GeneratedModuleDataDetail;
import com.healthcit.cacure.utils.ConcurrentUtils;
import com.healthcit.cacure.utils.DateUtils;
import com.healthcit.cacure.utils.PropertyUtils;
import com.healthcit.cacure.utils.RandomGeneratorUtils;
import com.healthcit.cacure.utils.RandomGeneratorUtils.Algorithm;

/**
 * Business delegate class used for preparing sample form data and saving it to CouchDB.
 * @author Oawofolu
 *
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * NOTES on UNIQUENESS:
 * "uniquePerAllModules", "uniquePerEntity" and "uniquePerEntityModules"
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * When generating sample data, users should be able to choose
 * whether or not their generated modules should have any uniqueness constraints.
 * 
 * The following uniqueness constraints have been defined:
 * 
 * 1) Unique Per All Modules
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * In Relational DB terms, a field with this constraint
 * is part of a primary key whose target is the module.
 * On the front-end, users will select "Module Unique" to enable this constraint. 
 * 
 * 2) Unique Per Entity
 * ~~~~~~~~~~~~~~~~~~~~
 * In Relational DB terms, a field with this constraint
 * is part of a primary key whose target is the entity.
 * On the front-end, users will select "Entity Specific" to enable this constraint.
 * 
 * 3) Unique Per Entity Modules
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * In Relational DB terms, a field with this constraint
 * is part of a unique key  whose target is the module and 
 * which includes this field,
 * any other fields with this constraint,
 * and the entity.
 * On the front-end, users will select "Entity Unique" to enable this constraint.  
 * 
 */

public class GeneratedModuleDataManager {
	private static Logger log = Logger.getLogger( GeneratedModuleDataManager.class );
	private static String FORM_ID = "formId";
	private static String QUESTIONS = "questions";
	private static String FORM_NAME = "formName";
	private static String MODULE_NAME = "moduleName";
	private static String ENTITY_ID = "ownerId";
	private static String MODULE_ID = "moduleId";
	private static String UPDATED_DATE = "updatedDate";
	private static String TEXT = "text";
	private static String UUID_VALUE = "uuid";
	private static String DATATYPE = "datatype";
	private static String STATIC = "static";
	private static String LOWERBOUND = "lowerbound";
	private static String UPPERBOUND = "upperbound";
	private static String LIST = "list";
	private static String SELECTED = "selected";
	private static String DYNAMIC = "dynamic";
	private static String SHORTNAME = "shortname";
	private static String QUESTION_ID = "questionId";
	private static String LINK_ID = "linkId";
	private static String QUESTION_SN = "questionSn";
	private static String QUESTION_TEXT = "questionText";
	private static String TABLE_QUESTION_TEXT = "tableQuestionText";
	private static String TABLE_QUESTION_ID = "tableQuestionId";
	private static String TABLE_QUESTION_SN = "tableQuestionSn";
	private static String TABLE_QUESTION_FIRST_COLUMN = "tableQuestionFirstColumn";
	private static String TABLE_QUESTION_IDENTIFYING_COLUMN = "tableQuestionIdentifyingColumn";
	private static String ANSWERVALUE_ID = "ansId";
	private static String ANSWERVALUE_SN = "ansSn";
	private static String ANSWERVALUE_TEXT = "ansText";
	private static String ANSWERVALUE_VALUE = "ansValue";
	private static String ANSWERVALUES = "answerValues";
	private static String UNIQUE_PER_ENTITY = "uniquePerEntity";
	private static String UNIQUE_PER_ALL_MODULES = "uniquePerAllModules";
	private static String UNIQUE_PER_ENTITY_MODULES = "uniquePerEntityModules";
	
	@Autowired
	private FormDao formDao;
	
	@Autowired
	private ModuleDao moduleDao;
	
	@Autowired
	private CouchDBDao couchDbDao;	
	
	
	/**
	 * 
	 * @param moduleDetail
	 * @throws IOException
	 * @throws URISyntaxException
	 */
	public void generateSampleDataInCouchDB( GeneratedModuleDataDetail moduleDetail ) 
	throws IOException, URISyntaxException
	{
		log.debug( "In generateSampleDataInCouchDB method..." );
		
		// Generate the list of modules to be saved
		JSONArray modules = generateModuleObjects( moduleDetail );
		
		// From the list of modules, generate the actual documents that 
		// will be saved to CouchDB
		JSONArray couchDbDocuments = generateCouchDbReadyDocuments( modules, moduleDetail );
		
		// Save the document to CouchDB
		saveDocuments( couchDbDocuments, moduleDetail );
		
		log.debug( "Sample data generated successfully." );
	}
	
	/**
	 * Saves a list of modules to the appropriate CouchDB database
	 * TODO: Currently each document represents all the questions and answers
	 * associated with a module.
	 * Instead of saving each wholesale module,
	 * the documents should be broken down into actual forms
	 * which could then be saved individually to CouchDb.
	 * @throws URISyntaxException 
	 * @throws IOException 
	 */
	private void saveDocuments( JSONArray modules, GeneratedModuleDataDetail moduleDetail ) throws IOException, URISyntaxException
	{		
		log.debug( "Saving randomly generated documents..." );
		log.debug( "..............................." );
		log.debug( "..............................." );
		
		// Get the database host
		String couchDbHost = moduleDetail.getCouchDbHost();
		
		// Get the database port
		int couchDbPort = moduleDetail.getCouchDbPort();
		
		// Get the database name
		String couchDbName = moduleDetail.getCouchDbName();
		
		// save the documents
		couchDbDao.bulkWriteToDb( modules, couchDbHost, couchDbPort, couchDbName );
	}
	
	/**
	 * From a list of modules, generates the corresponding form documents 
	 * which will be saved to CouchDb
	 */
	private JSONArray generateCouchDbReadyDocuments( JSONArray modules, GeneratedModuleDataDetail moduleDetail )
	{
		return generateFormDocuments( modules, moduleDetail );
	}
	
	private JSONArray generateFormDocuments( JSONArray modules, GeneratedModuleDataDetail moduleDetail ) 
	{
		log.debug( "In generateFormDocuments method...");
		log.debug( ".................................." );
		log.debug( ".................................." );
		
		// metadata associated with the module
		Map<String,String> metadata = getMetadataForModule( moduleDetail.getModuleId(), false );
		
		// number of documents to be generated per module
		int numFormsPerModule = moduleDetail.getActualNumberOfCouchDbDocuments() / moduleDetail.getActualNumberOfModules();
		
		JSONObject[] documentArray = new JSONObject[ moduleDetail.getActualNumberOfCouchDbDocuments() ];
		
		JSONArray documentJSONArray = new JSONArray();
		
		log.debug( "Number of modules generated: " + modules.size() );
		log.debug( "Number of CouchDB documents to be generated: " + moduleDetail.getActualNumberOfCouchDbDocuments() );
				
		// Generate the documents in a multithreaded fashion
		List<Callable<Object>> tasks = new ArrayList<Callable<Object>>();
		
		for ( int index = 0; index < modules.size(); ++index )
		{
			Callable<Object> task = new GenerateCouchDbDocumentCommand( modules, index, numFormsPerModule, documentArray, metadata );
			
			tasks.add( task );
		}
		
		ConcurrentUtils.invokeBulkActions( tasks );
		
		// remove any null entries from the documentArray
		while ( ArrayUtils.contains( documentArray, null ) )
		{
			documentArray = (JSONObject[])ArrayUtils.removeElement( documentArray, null );
		}
		
		// add the documents to the JSON array
		documentJSONArray.addAll( Arrays.asList( documentArray ) );
		
		documentArray = null;
		
		//debugging
		log.debug( "Number of documents actually generated and ready to save: " + documentJSONArray.size() );
        if ( documentJSONArray.size() > 0 ) log.debug( "First document to be saved: " + documentJSONArray.getJSONObject( 0 ) );

		// return the JSON array
		return documentJSONArray;
	}
	
	/**
	 * Generates a list of modules to be saved to CouchDB
	 */
	public JSONArray generateModuleObjects( GeneratedModuleDataDetail formDetail )
	{
		log.debug( "Generating list of modules..." );
		log.debug( "..............................." );
		log.debug( "..............................." );
		
		// list of generated modules
		JSONArray list = new JSONArray();
		
		// actual number of modules to be generated
		int actualNumberOfModules = formDetail.getActualNumberOfModules() ;
		
		// actual number of entities to be generated
		int actualNumberOfEntities = formDetail.getActualNumberOfEntities();
		
		// actual number of CouchDb documents to be generated
		int numberOfDocumentsPerModule = formDao.getNumberOfFormsForModuleId( new Long( formDetail.getModuleId() ) ).intValue();
		
		int actualNumberOfDocuments = numberOfDocumentsPerModule * actualNumberOfModules;
		
		formDetail.setActualNumberOfCouchDbDocuments( actualNumberOfDocuments );			
		
		// maximum number of modules per entity
		int numberOfModulesPerEntity = (int)Math.floor( actualNumberOfModules / actualNumberOfEntities );
		
		// debugging
		log.debug( "Number of modules to be generated: "+ actualNumberOfModules  );
		log.debug( "Number of entities to be generated: " + actualNumberOfEntities );
					
		// entity Id
		String entityId = null;
		
		// keep track of the last generated unique key
		Map<String,JSONObject> lastUniqueKey = new HashMap<String,JSONObject>();
		
		for ( int index = 0; index < actualNumberOfModules; ++index )
		{
			// Get an "entity-module" id
			int entityModuleId = index % numberOfModulesPerEntity;
			
			// Get a new entity Id, whenever appropriate
			if ( entityModuleId == 0 ) entityId = UUID.randomUUID().toString();
			
			// Set up the unique keys for this module
			Map<String,JSONObject> uniqueKey = generateUniqueKey( formDetail, lastUniqueKey, entityId, index, entityModuleId );
						
			JSONObject module = generateModuleData( formDetail, uniqueKey, lastUniqueKey, entityId );

			// track this unique key for later
			lastUniqueKey.clear();
			lastUniqueKey.putAll( uniqueKey );
			
			list.add( module );			
		}
		
		return list;
	}
	
	/**
	 * Takes a GeneratedFormDataDetail object and uses it to generate random CouchDb data
	 * (a JSON object) for a module.
	 */
	@SuppressWarnings("unchecked")
	private JSONObject generateModuleData( GeneratedModuleDataDetail form, Map<String,JSONObject> uniqueKey, Map<String,JSONObject> lastUniqueKey, String entityId )
	{
		JSONObject jsonForm = new JSONObject();
				
		// set up entity ID
		jsonForm.put( ENTITY_ID, entityId );
		
		// set up module ID (random string)
		jsonForm.put( MODULE_ID, UUID.randomUUID().toString() );
		
		// set up the updatedDate (current timestamp)
		jsonForm.put( UPDATED_DATE, DateUtils.formatDateUTC( DateUtils.now() ) );
		
		// set up questions
		JSONObject questions = new JSONObject();

		for ( Map<String,Object> obj : form.getQuestionFields() )
		{
			JSONObject jsonQuestion = new JSONObject();
			
			if ( GeneratedModuleDataDetail.isSelected( obj ) )
			{			
				Map<String,Object> selectedQuestion = obj;
				
				// debugging
				JSONObject debugObj = new JSONObject();
				debugObj.putAll( selectedQuestion );				
				log.debug( "Selected question..." + debugObj );
				
				// question UUID
				String questionUUID = ( String )selectedQuestion.get( UUID_VALUE );
	
				// set "questionId"
				jsonQuestion.put( QUESTION_ID, questionUUID );
				
				// set "linkId"
				jsonQuestion.put( LINK_ID, selectedQuestion.get(LINK_ID) );
						
				// set "questionSn"
				jsonQuestion.put( QUESTION_SN, selectedQuestion.get( SHORTNAME ) );
						
				// set "questionText"
				jsonQuestion.put( QUESTION_TEXT, selectedQuestion.get( TEXT ) );
				
				// set "answer values"
				jsonQuestion.put( ANSWERVALUES, selectedQuestion.get( ANSWERVALUES ) );
				
				// set "form name" - temporary value which will be used to generate CouchDB-ready documents later
				jsonQuestion.put( FORM_NAME, selectedQuestion.get( FORM_NAME ) );
				
				// set "module name" - temporary value which will be used to generate CouchDB-ready documents later
				jsonQuestion.put( MODULE_NAME, selectedQuestion.get( MODULE_NAME ) );
				
				// check if this is one of the unique key questions
				boolean isUniqueKeyQuestion = uniqueKey.containsKey( questionUUID );
								
				// set up answer values
				// NOTE: Currently we will only generate one answer value for each question
				// 
				JSONArray jsonAnswerValuesArray = new JSONArray();
				
				JSONArray randomQuestionAnswerValues = new JSONArray();
				
				// If this question is one of the "unique-per-entity", "unique-per-entity-modules" or "unique-per-all-modules" questions,
				// then get the answer value from the uniqueKey map;
				// else, generate a random answer value object.
				Object lastRandomQuestionAnswerValue = lastUniqueKey.get( questionUUID ) == null ?
														null : 
														getAnswerValue( lastUniqueKey.get( questionUUID ));
				
				Map randomQuestionAnswerValue = 
					isUniqueKeyQuestion ?
					uniqueKey.get( questionUUID ) :
					generateRandomAnswerValue( selectedQuestion, lastRandomQuestionAnswerValue, Algorithm.PSEUDORANDOM );
				
				randomQuestionAnswerValues.add( randomQuestionAnswerValue );
	
				for( Object obj2 : randomQuestionAnswerValues ){
					
					JSONObject answerValue = ( JSONObject ) obj2;
					
					JSONObject jsonAnswer = new JSONObject();
					
					// get answer value text 
					String answerValueText = ( String )answerValue.get( ANSWERVALUE_TEXT );
					
					// get answer value value
					String answerValueValue = answerValue.get( ANSWERVALUE_VALUE ).toString();
					
					// answer value id
					jsonAnswer.put( ANSWERVALUE_ID, answerValue.get( ANSWERVALUE_ID ) );
					
					// answer value shortname
					jsonAnswer.put( ANSWERVALUE_SN, answerValue.get( ANSWERVALUE_SN ) );
					
					// answer value text
					jsonAnswer.put( ANSWERVALUE_TEXT, answerValueText );
					
					// answer value value
					jsonAnswer.put( ANSWERVALUE_VALUE, answerValueValue );
					
					jsonAnswerValuesArray.add( jsonAnswer );
					
					// track this answer for future frequency analysis
					form.trackQuestionAndAnswer( questionUUID, StringUtils.defaultIfEmpty( answerValueText, answerValueValue ) );
				}								
				
				jsonQuestion.put( ANSWERVALUES, jsonAnswerValuesArray );
				
				questions.put( questionUUID, jsonQuestion);
			}
		}
		jsonForm.put( QUESTIONS, questions);
		
		return jsonForm;
	}
	
	/**
	 * This method generates the "questionFields" collection in the GeneratedFormDataDetail entity
	 * from the given form UUID.
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String,Object>> generateQuestionFields( QuestionnaireForm form )
	{
		log.debug( "In generateQuestionFields method..." );
		
		// Initialize a JSONArray
		List<Map<String,Object>> list = new ArrayList<Map<String,Object>>();
				
		// Get the form's questions
		List<FormElement> formElements = form.getElements();
		
		for ( FormElement formElement : formElements )
		{
			Object questionsObject = PropertyUtils.readProperty( formElement, "questions" );
			
			if ( questionsObject instanceof Collection )
			{
				Collection<? extends BaseQuestion> questions = ( Collection<? extends BaseQuestion> )questionsObject;
				
				for ( BaseQuestion baseQuestion : questions )
				{
					if ( baseQuestion instanceof Question || baseQuestion instanceof TableQuestion ) // do not add ExternalQuestions
					{
						// Add a questionField to the array
						Map questionField = getQuestionField( formElement, baseQuestion, form );
						
						// Add to the array if it's not null
						if ( questionField != null ) list.add( questionField );
					}
				}
			}
		}
		
		return list;
	}
	
	/**
	 * This method generates a "questionField" from a Question object.
	 * The structure is as follows:
	 *  // question UUID, text, Shortname, type, etc
	 *  { questionId: ..., questionText: ..., questionSn: ..., 
	 *    list:COMMA DELIMITED LIST,lowerbound:...,upperbound:...,
	 *  // static answer values  are answer values that can be selected (not free text) 
	 *        {answervalues : { static : [{ansId:...,ansVal:...,ansText:...,ansSn:...}],
	 *  // dynamic answer values are the free text answer values
	 *                        dynamic : [{ansId:...,ansVal:...,ansText:...,ansSn:...}]}}}
	 */
	@SuppressWarnings("unchecked")
	private Map getQuestionField( FormElement formElement, BaseQuestion q, QuestionnaireForm form )
	{
		// If this is a Table Question then initialize an object casting it as a TableQuestion entity;
		// else,  initialize an object casting it as a Question entity
		TableQuestion tableQuestion = null;
		
		Question question = null;
		
		if ( q instanceof TableQuestion )
		{
			tableQuestion = ( TableQuestion ) q;
		}
		
		if ( q instanceof Question )
		{
			question = ( Question ) q;
		}
		
		// If this is not a Table Question then initialize an object casting it as a Question entity
		
		// Get the answer element associated with the question
		Answer a = q.getAnswer();
		
		// Get the question UUID (use the FormElement uuid)
		String uuid = formElement.getUuid();
		
		// Get the link ID, if it exists
		String linkId = ( formElement instanceof LinkElement ) ?
				        ( (LinkElement)formElement ).getSourceId() :
				        "";
		
		// Get the question text
		String text =  ( tableQuestion != null ) ? 
						tableQuestion.getDescription() : 
						question.getQuestionElement().getDescription();
		
		// Get the question shortname
		String shortname = q.getShortName();
		
		// Get the question type 
		String datatype = ( a != null ) ? a.getType().name() : null; 
		
		// Get the question's form name
		String formname = form.getName();
		
		// Get the question's associated module name
		String modulename = form.getModule().getDescription();
		
		// Get the table question's text (if it is a table question)
		String tableQuestionText = null;
		
		// Get the table question's ID (if it is a table question)
		String tableQuestionId = null;
		
		// Get the table question's shortname (if it is a table question)
		String tableQuestionSn = null;
		
		// Get the first question associated with this table question (if it is a table question)
		String tableQuestionFirstColumn = null;
		
		// Get the identifying column associated with this table question (if it is a table question)
		String tableQuestionIdentifyingColumn = null;
		
		// Set up various properties associated with this question (if it is a table question)
		if ( tableQuestion != null )
		{
			tableQuestionText = tableQuestion.getTable().getDescription();
			
			tableQuestionId = tableQuestion.getTable().getUuid();
			
			tableQuestionSn = tableQuestion.getTable().getTableShortName();
			
			tableQuestionFirstColumn = tableQuestion.getTable().getFirstQuestion().getUuid();
			
			TableQuestion identifyingColumn = tableQuestion.getTable().getIdentifyingQuestion();
			
			tableQuestionIdentifyingColumn = ( identifyingColumn == null ? null : identifyingColumn.getUuid() );			
		}
				
		// Set up the Map representing the question		
		Map questionMap = new HashMap();
		
		questionMap.put( UUID_VALUE, uuid );
		
		questionMap.put( LINK_ID, linkId );
		
		questionMap.put( TEXT, text );
		
		questionMap.put( SHORTNAME, shortname );
		
		questionMap.put( FORM_NAME, formname );
		
		questionMap.put( MODULE_NAME, modulename );
		
		questionMap.put( SELECTED, null );
		
		questionMap.put( LIST , null );
		
		questionMap.put( UPPERBOUND , null );
		
		questionMap.put( LOWERBOUND, null );
		
		questionMap.put( UNIQUE_PER_ENTITY, null );
		
		questionMap.put( UNIQUE_PER_ALL_MODULES, null );
		
		questionMap.put( UNIQUE_PER_ENTITY_MODULES, null );
		
		questionMap.put( TABLE_QUESTION_TEXT, tableQuestionText );
		
		questionMap.put( TABLE_QUESTION_ID, tableQuestionId );
		
		questionMap.put( TABLE_QUESTION_SN, tableQuestionSn );
		
		questionMap.put( TABLE_QUESTION_FIRST_COLUMN, tableQuestionFirstColumn );
		
		questionMap.put( TABLE_QUESTION_IDENTIFYING_COLUMN, tableQuestionIdentifyingColumn );
		
		if ( datatype != null ) questionMap.put( DATATYPE, datatype );
		
		// set up the answer values
		Map<String,List> answerValues = new HashMap<String,List>();
		
		if ( a != null )
		{	
			// set up the array of static answer values, if any
			List staticAvArray = new ArrayList();
			
			for ( AnswerValue av : a.getAnswerValues() )
			{
				Map o = new HashMap();
				
				// set the answer value id
				if ( av.getId() != null ) o.put( ANSWERVALUE_ID , av.getId() );
				
				// set the answer value value
				if ( av.getValue() != null ) o.put( ANSWERVALUE_VALUE , av.getValue() );
				
				// set the answer value text, if it exists
				if ( av.getDescription() != null ) o.put( ANSWERVALUE_TEXT , av.getDescription() );
				
				// set the answer value shortname
				if ( av.getName() != null ) o.put( ANSWERVALUE_SN , av.getName() );
				
				// set whether or not this answer value is selected by the user
				o.put( SELECTED, null );
				
				// add to the array of static answer values
				staticAvArray.add( o );
			}
			
			answerValues.put( STATIC, staticAvArray );
			
			// now, set up the set of dynamic (free text) answer values (contains ONE answer value for now).
			// Originally the answer value's value is null;
			// it will get populated once the user submits the form IF this question permits free text.
			List dynamicAvArray = new ArrayList();
			
			Map o = new HashMap();
			
			o.put( ANSWERVALUE_ID, a.getId() );
			
			o.put( SELECTED, null );
						
			dynamicAvArray.add( o );
				
			answerValues.put( DYNAMIC, dynamicAvArray );
			
		}
		
		questionMap.put( ANSWERVALUES , answerValues );
		
		return questionMap;
	}
	
	@SuppressWarnings({"unchecked"})
	private JSONObject generateRandomAnswerValueForUniqueKey( Map question, Map uniqueKey, Map<String,JSONObject> lastUniqueKey, Map<Object,List<Object>> previousAnswers, Object groupId  )
	{
		JSONObject randomAnswerValueObject;
		
		// Get the question's UUID
		String questionUUID = ( String )question.get( UUID_VALUE );
		
		// If a random answer has already been generated for this question
		// (example, if this is a unique-per-all-modules question that is also
		// a unique-per-entity question, and the unique-per-entity question was processed first),
		// then simply copy the previously generated random answer for this unique key
		
		if ( uniqueKey.containsKey( questionUUID ) )
		{
			randomAnswerValueObject = (JSONObject)uniqueKey.get( questionUUID );
			
			return randomAnswerValueObject;
		}
		
		// else:
		else 
		{
			// Get the previously generated unique keys as an ordered list
			LinkedList<Map.Entry> previousUniqueKeys  =
				new LinkedList( ((LinkedHashMap)previousAnswers).entrySet() );
			
			// Get the value of the field which identifies the last unique group which was processed
			Map.Entry last = ( previousUniqueKeys.isEmpty() ? null : previousUniqueKeys.getLast() );
			
			List list = ( last == null ? null : (List)last.getValue() );
			
			Object lastGroupId = 
					list == null ? 
					null : 
					Collections.synchronizedList( list ).get( list.size() - 1 );
			
			// If the current groupId matches the lastGroupId,
			// then it means that the same answer value should be used for the current unique key
			// ( since uniqueness is determined by the group )
			if ( groupId.equals( lastGroupId ) )
			{
				randomAnswerValueObject = new JSONObject();
				
				randomAnswerValueObject.putAll( lastUniqueKey.get( questionUUID ) );
				
				return randomAnswerValueObject;
			}
			
			// Otherwise, a new group is being processed, so generate a new random answer value
			else
			{
				// Determine the last generated random value for this question
				JSONObject lastRandomAnswerValueObject = lastUniqueKey.get( questionUUID ); 
				
				Object lastRandomAnswerValue = 
					lastRandomAnswerValueObject == null ? 
					null : 
					getAnswerValue( lastRandomAnswerValueObject );
					
				return generateRandomAnswerValue( question, lastRandomAnswerValue, ( lastRandomAnswerValue == null ? Algorithm.PSEUDORANDOM : Algorithm.EVEN ) );
			}
		}
	}
	
	
	/**
	 * This method generates a JSONObject which represents a possible answervalue
	 * for the given question.
	 * The answer value may be generated one of 2 ways:
	 * 1) Static answer values: 
	 *       - randomly select one of the static answer value objects
	 * 2) Dynamic answer values (free text):
	 * 		 - if the "list" field is not null, then
	 *         split the comma-delimited list into tokens and randomly select one of the tokens
	 *       - else (if the "list" field is null), then
	 *         use the lower/upper bounds to generate a value based on the datatype,
	 *         or if no lower/upper bounds exist then simply generate a random value.
	 * @param question
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private JSONObject generateRandomAnswerValue( Map question, Object lastRandomlyGeneratedValue, Algorithm algorithm )
	{
		List dynamicAnsValues = ( List )( (Map) question.get( ANSWERVALUES ) ).get( DYNAMIC );
				
		Object randomAnswerValue = null;
		
		JSONObject randomAnswerValueObject = new JSONObject();
		
		if ( GeneratedModuleDataDetail.isFreeTextQuestion( question ) )
		{
			String commaDelimitedList = ( String )question.get( LIST );
			
			String lowerBound = ( String )question.get( LOWERBOUND );
			
			String upperBound = ( String )question.get( UPPERBOUND );
			
			if ( StringUtils.isNotBlank( commaDelimitedList ) ) 				
			{
				// This means there is a comma-delimited list of tokens
				String[] tokens = StringUtils.split( commaDelimitedList, "," );
				
				randomAnswerValue = RandomGeneratorUtils.selectRandomElement( tokens, lastRandomlyGeneratedValue, algorithm );
			}
			
			else if ( StringUtils.isNotBlank( lowerBound ) || StringUtils.isNotBlank( upperBound ))
			{
				// This means the random value should be selected from a range of values
				randomAnswerValue = RandomGeneratorUtils.selectRandomElementFromRange(lowerBound, upperBound, ( String )lastRandomlyGeneratedValue, algorithm );
			}
			
			else
			{
				//  else, generate a random string
				// TODO: Generate a different random answer value based on the data type of the question
				randomAnswerValue = RandomGeneratorUtils.generateRandomString();
			}
			
			// Update the JSON object representing the random answer value
			randomAnswerValueObject = new JSONObject();
			
			randomAnswerValueObject.putAll( (Map) dynamicAnsValues.get( 0 ) );
				
			randomAnswerValueObject.put( ANSWERVALUE_VALUE, randomAnswerValue );
		}
		
		// Otherwise this is NOT a free-text question, 
		// i.e. there is a predefined set of answers for this question.
		else
		{
			// Generate the list of answer values that were selected for this question
			List allAnswerValues = ( List )((Map)question.get( ANSWERVALUES )).get( STATIC ) ;
			List selectedAnswerValues = new ArrayList(); 
			Map<String,Object> lastSelectedAnswer = new HashMap<String,Object>();
			
			for ( Object selectedAnswerValue : allAnswerValues )
			{
				if ( GeneratedModuleDataDetail.isSelected( (Map) selectedAnswerValue ) )
				{
					selectedAnswerValues.add( selectedAnswerValue );
										
					if ( lastSelectedAnswer.isEmpty() &&
						 lastRandomlyGeneratedValue != null &&
						 StringUtils.equals( lastRandomlyGeneratedValue.toString(), 
								 			 ((Map)selectedAnswerValue).get( ANSWERVALUE_VALUE ).toString()))
					{
						lastSelectedAnswer.putAll( (Map)selectedAnswerValue );
					}
				}
			}
			
			// Randomly pick one of the selected answer values
			randomAnswerValueObject = new JSONObject();
			
			randomAnswerValueObject.putAll( (Map) RandomGeneratorUtils.selectRandomElement( selectedAnswerValues.toArray(), lastSelectedAnswer, algorithm ) );
		}
		
		return randomAnswerValueObject;
	}
	
	/**
	 * Updates the GeneratedFormDataDetail object with 
	 * randomly generated unique key field values.
	 */
	private Map<String,JSONObject> generateUniqueKey( GeneratedModuleDataDetail form, Map<String,JSONObject> lastUniqueKey, String entityId, int moduleId, int entityModuleId )
	{
		log.debug( "Generating unique key.............."  );
		log.debug( "==========================" );
	   	// Get the list of "unique-per-entity" fields
		List<Map<String,Object>> uniquePerEntityQuestions = form.retrieveUniquePerEntityQuestions();
		
		// Get the list of "unique-per-all-modules" fields
		List<Map<String,Object>> uniquePerAllModulesQuestions = form.retrieveUniquePerAllModulesQuestions();
		
		// Get the list of "unique-per-entity-modules" fields
		List<Map<String,Object>> uniquePerEntityModulesQuestions = form.retrieveUniquePerEntityModulesQuestions();
		
		// Generate the answer values: first for "unique-per-entity", then "unique-per-entity-modules", then "unique-per-all-modules"
		Map<String,JSONObject> uniqueKey = new HashMap<String,JSONObject>();				

		// Get the map of answer-value to "unique-per-entity" question fields
		Map<Object, List<Object>> uniquePerEntityCombinations = form.getUniquePerEntityQuestionCombinations();
		
		// Get the map of answer-value to "unique-per-all-modules" question fields
		Map<Object, List<Object>> uniquePerAllModulesCombinations = form.getUniquePerAllModuleQuestionCombinations();
		
		// Get the map of answer-value to "unique-per-entity-modules" question fields
		Map<Object,List<Object>> uniquePerEntityModulesCombinations = form.getUniquePerEntityModuleQuestionCombinations();
								
		// Generate the answer values: first for "unique-per-entity", then "unique-per-entity-modules", then "unique-per-all-modules"
		uniqueKey.clear();
		
		// First, generate the unique answer values for "unique-per-entity" fields
		buildNewKey( uniqueKey, lastUniqueKey, uniquePerEntityQuestions, uniquePerEntityCombinations, entityId );
		
		// Then, generate the unique answer values for "unique-per-entity-modules" fields
		buildNewKey( uniqueKey, lastUniqueKey, uniquePerEntityModulesQuestions, uniquePerEntityModulesCombinations, entityModuleId );
		
		// Then, generate the unique answer values for "unique-per-all-modules" fields
		buildNewKey( uniqueKey, lastUniqueKey, uniquePerAllModulesQuestions, uniquePerAllModulesCombinations, moduleId );
			
		// Debugging
		log.debug("Generated unique key fields: " + (uniqueKey.isEmpty() ? "NONE" : ""));
		for ( Map.Entry<String,JSONObject> entry: uniqueKey.entrySet() )
		{
			log.debug( "==========Key: "  + entry.getKey() );
			log.debug( "==========Text:" + StringUtils.defaultIfEmpty( ( String )entry.getValue().get(ANSWERVALUE_TEXT), "")
					  +"==========Value:" + entry.getValue().get(ANSWERVALUE_VALUE).toString() );
		}
		
		return uniqueKey;
	}
	
	/**
	 * Generates a random unique key for a given module.
	 * Returns whether or not this key is actually a duplicate 
	 * within the appropriate scope (per-module, per-entity or per-entitymodule).
	 */
	private void buildNewKey( Map<String,JSONObject> uniqueKey, 
							  Map<String,JSONObject> lastUniqueKey,
							  List<Map<String,Object>> keyQuestions, 
							  Map<Object,List<Object>> keyQuestionCombinations, 
							  Object uniqueGroupId )
	{	
		for ( int i = 0; i < keyQuestions.size(); ++i )
		{
			// Get the unique key question
			Map<String,Object> uniquePerEntityOrModuleQuestion =  keyQuestions.get( i );
			
			// Get the question UUID
			String questionUUID = ( String )uniquePerEntityOrModuleQuestion.get( UUID_VALUE );
									
			// Generate a random answer value for this question
			JSONObject randomAnswerValue = 
				generateRandomAnswerValueForUniqueKey( uniquePerEntityOrModuleQuestion, uniqueKey, lastUniqueKey, keyQuestionCombinations, uniqueGroupId );
			
			uniqueKey.put( questionUUID, randomAnswerValue );	
			
			// Track the newly generated key in the questionCombinations collection
			if ( i == keyQuestions.size() - 1 )
			{
				for ( Map.Entry<String, JSONObject> entry : uniqueKey.entrySet() )
				{
					
					String key = GeneratedModuleDataDetail.getTwoPartMapKey(
							entry.getKey(), 
							entry.getValue().get(ANSWERVALUE_VALUE).toString() );
					
					List<Object> list = keyQuestionCombinations.get( key );
					
					if ( list == null ) {
						list = Collections.synchronizedList( new ArrayList<Object>() );
					}
					
					if ( ! list.contains( uniqueGroupId ) ) list.add( uniqueGroupId );
					
					keyQuestionCombinations.put( key, list );
				}
			}
		}
	}
		
	/**
	 * Gets a Map of FormNames => FormIDs and ModuleNames => ModuleIDs.
	 * This represents the metadata associated with a given module.
	 * 
	 */
	public Map<String,String> getMetadataForModule( String moduleId, boolean useExistingIds ) 
	{
		// The map which will store the metadata for this module
		Map<String,String> metadata = new HashMap<String,String>();
		
		// The module associated with this "moduleId"
		BaseModule module = moduleDao.getById(new Long(moduleId));
		
		// Generate a map of name-to-id pairings for each form in this module as applicable
		for ( BaseForm form : module.getForms() )
		{
			if ( form instanceof QuestionnaireForm ) 
			{
				metadata.put( form.getName(), ( useExistingIds ? form.getUuid() : UUID.randomUUID().toString() ) );
			}
		}
		
		// Add the moduleName-to-moduleId pairing to the map
		metadata.put( module.getDescription(), ( useExistingIds ? moduleId : UUID.randomUUID().toString() ) );
				
		return metadata;
	}
	
	/**
	 * Method which retrieves the answer value from a given JSON answer value object.
	 * 
	 */
	private String getAnswerValue( JSONObject answerValueObject )
	{
		return answerValueObject.get( ANSWERVALUE_VALUE ).toString();
	}
	
	public void setFormDao(FormDao formDao) {
		this.formDao = formDao;
	}

	public void setCouchDbDao(CouchDBDao couchDbDao) {
		this.couchDbDao = couchDbDao;
	}
	
	public void setModuleDao(ModuleDao moduleDao) {
		this.moduleDao = moduleDao;
	}

	/**
	 * Used to handle the generation of CouchDb-ready form documents 
	 * in a multithreaded fashion.
	 */
	private class GenerateCouchDbDocumentCommand implements Callable<Object>
	{
		/**
		 * The list of modules to be converted into CouchDb-ready form documents
		 */
		private JSONArray modules;
		
		/**
		 * The index of the module that this runnable will be converting (in the list)
		 */
		private int moduleIndex;
		
		/**
		 * The number of forms associated with a module
		 */
		private int numberOfFormsPerModule;
		
		/**
		 * The metadata associated with a module
		 */
		private Map<String,String> moduleMetadata;
		
		/**
		 * The array of JSONObjects to which this runnable will be adding
		 * newly generated CouchDb-ready documents
		 */
		private JSONObject[] documentArray;
		
		private GenerateCouchDbDocumentCommand( JSONArray modules, int index, int numberOfFormsPerModule, JSONObject[] documentArray, Map<String,String> moduleMetadata ) 
		{
			this.modules = modules;
			
			this.moduleIndex = index;
			
			this.numberOfFormsPerModule = numberOfFormsPerModule;
			
			this.documentArray = documentArray;
			
			this.moduleMetadata = moduleMetadata;
		}

		@Override
		public Object call() 
		{
			// Get the module that this thread will be working on
			JSONObject module = ( JSONObject )modules.get( moduleIndex );
			
			// Get the questions associated with this module
			JSONObject questions = module.getJSONObject( QUESTIONS );
			
			// we can set up a Map to keep track of the generated documents
			Map<String,JSONObject> generatedDocuments = new HashMap<String,JSONObject>();
			
			// Iterate through all the questions, re-associating each question with 
			// a brand new document which will be saved to CouchDb	
			for ( Object question : questions.values() )
			{					
				// The current question
				JSONObject jsonQuestion = ( JSONObject ) question;
				
				// The current question ID
				String jsonQuestionId  = jsonQuestion.getString( QUESTION_ID );
				
				// The name of the form associated with the current question
				// (since this attribute was only added as a temporary store,
				// remove it from the CouchDb-ready version of the question)
				String formName = ( String )jsonQuestion.remove( FORM_NAME );
				
				// The name of the module associated with the current question
				// (since this attribute was only added as a temporary store,
				// remove it from the CouchDb-ready version of the question)
				String moduleName = ( String )jsonQuestion.remove( MODULE_NAME );
				
				// The link ID associated with this question
				// (since this attribute was only added as a temporary store,
				// remove it from the CouchDb-ready version of the question)
				String linkId = ( String )jsonQuestion.remove( LINK_ID );
				
				// If the linkId is not blank, then
				// the questionId should be reset to be equal to the link
				if ( StringUtils.isNotBlank( linkId ))
				{
					jsonQuestionId = linkId;
					jsonQuestion.put( QUESTION_ID, jsonQuestionId );					
				}
				
				
				// Create the new CouchDB document.
				// It will clone most of the properties of the original module document, 
				// while maintaining form-specific properties as well
				JSONObject couchDbDoc = generatedDocuments.get( formName );
				
				if ( couchDbDoc == null )
				{
					couchDbDoc = new JSONObject();
					
					// set the module name
					couchDbDoc.put( MODULE_NAME, moduleName );
					
					// set the module ID
					couchDbDoc.put( MODULE_ID, moduleMetadata.get( moduleName ));
																				
					// set the form name
					couchDbDoc.put( FORM_NAME, formName );
					
					// set the form ID
					couchDbDoc.put( FORM_ID, moduleMetadata.get( formName ) );
					
					// set the entity ID
					couchDbDoc.put( ENTITY_ID, module.get( ENTITY_ID ) );
					
					// set the updated Date
					couchDbDoc.put( UPDATED_DATE, module.get( UPDATED_DATE ) );
					
					// set the questions
					couchDbDoc.put( QUESTIONS, new JSONObject() );					

					// set the module ID
					String moduleId = ( String ) moduleMetadata.get( moduleName );
					
					if ( StringUtils.isNotEmpty( moduleId ) ) 
					{
						couchDbDoc.put( MODULE_ID, moduleId );
					}
					
					// set the form ID
					String formId = ( String ) moduleMetadata.get( formName );
					
					if ( StringUtils.isNotEmpty( formId ) )
					{
						couchDbDoc.put( FORM_ID, formId );
					}
				}	
				
				// Add this question to the document
				couchDbDoc.getJSONObject( QUESTIONS ).put( jsonQuestionId, question );
				
				// Add this document to the generatedDocuments map
				generatedDocuments.put( formName, couchDbDoc );								
			}
			
			// Add the newly generated documents to the documentArray
			
			int startIndex = moduleIndex * numberOfFormsPerModule; // start of the loop to add documents
			
			int endIndex = startIndex + generatedDocuments.size(); // end of the loop to add documents
			
			Iterator<JSONObject> generatedDocumentIterator = generatedDocuments.values().iterator();
			
			for ( int i = startIndex; i < endIndex; ++i )
			{
				if ( generatedDocumentIterator.hasNext() )
				{
					documentArray[ i ] = generatedDocumentIterator.next();
					
					// debugging (just views the first 5 documents)
					if ( i < 5 ) log.debug("Document added at index " + i + ": " + documentArray[ i ] );
				}
			}
			
			// Clear unused collections
			generatedDocuments.clear();			
			
			return null;
		}
	}
}

