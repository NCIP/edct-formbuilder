package com.healthcit.cacure.model.admin;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;

import com.healthcit.cacure.businessdelegates.GeneratedModuleDataManager;
import com.healthcit.cacure.utils.RandomGeneratorUtils;

/**
 * Used to generate Sample Data in the Admin module.
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
 * is part of a unique key whose target is the module and 
 * which includes this field,
 * any other fields with this constraint,
 * and the entity.
 * On the front-end, users will select "Entity Unique" to enable this constraint.  
 * 
 */
public class GeneratedModuleDataDetail {
	
	private static String SELECTED = "selected";
	private static String UNIQUE_PER_ENTITY = "uniquePerEntity";
	private static String UNIQUE_PER_ALL_MODULES = "uniquePerAllModules";
	private static String UNIQUE_PER_ENTITY_MODULES = "uniquePerEntityModules";
	private static String NULL = "null";
	private static String LOWERBOUND = "lowerbound";
	private static String UPPERBOUND = "upperbound";
	private static String LIST = "list";
	private static String ANSWERVALUES = "answerValues";
	private static String ANSWERVALUE_VALUE = "ansValue";
	private static String STATIC = "static";
	private static String COMMA = ",";
	private static String MAP_KEY_SEPARATOR = "|||";
	private static int MAP_KEY_FIRST_PART = 1;
	private static int MAP_KEY_SECOND_PART = 2;
	
	/**
	 * The GeneratedModuleDataManager delegate.
	 */
	@Autowired
	private GeneratedModuleDataManager manager;
		
	/**
	 * The module name associated with this object
	 */
	private String moduleId;
		
	/**
	 * The set of fields from this form which will be randomly generated.
	 * Each element in this JSONArray will be a JSONObject 
	 * which represents a selected question. It contains:
	 * 1) the question UUID - question[uuid]
	 * 2) the question text - question[text]
	 * 3) the question data type - question[datatype] 
	 * 4) the question shortname - question[shortname]
	 * 5) the question's associated form name - question[formName]
	 * 6) a comma-delimited range of values (for free-text strings) - question[answervalues][freetext] 
	 * 7) lower bound (for free-text numeric and date values) - question[answervalues][lowerbound]
	 * 8) upper bound (for free-text numeric and date values) - question[answervalues][upperbound]
	 * 9) a JSONArray of values (for non-free-text) - question[answervalues][nonfreetext]
	 * 
	 */
	private List<Map<String,Object>> questionFields = new ArrayList<Map<String,Object>>();
	
	/**
	 * The set of fields from this form which will not be randomly generated
	 */
	
	/**
	 * The CouchDB database host where the sample data will be generated
	 */
	private String couchDbHost;
	
	/**
	 * The CouchDB database port
	 */
	private Integer couchDbPort;
	
	/**
	 * The CouchDB database name
	 */
	private String couchDbName;
	
	/**
	 * The number of module documents requested
	 * (A "module document" is a document which contains all the questions for a specific module)
	 */
	private Integer numberOfModules;
	
	/**
	 * The number of module instances requested
	 */
	public Integer numberOfModuleInstances;
	
	/**
	 * The number of entities requested
	 */
	private Integer numberOfEntities;
	
	/**
	 * The actual number of modules which will be generated 
	 */
	private Integer actualNumberOfModules = null;
	
	/**
	 * The actual number of CouchDb documents which will be generated
	 */
	private Integer actualNumberOfCouchDbDocuments = null;
	
	/**
	 * The actual number of entities which will be generated
	 */
	private Integer actualNumberOfEntities = null;
	
	/**
	 * The list of questions which must be unique across all MODULES
	 */
	private List<Map<String,Object>> uniquePerAllModulesQuestions = null;
	
	/**
	 * The list of questions which must be unique across all ENTITIES
	 */
	private List<Map<String,Object>> uniquePerEntityQuestions = null;
	
	/**
	 * The list of questions which must be unique across a single entity's MODULES
	 */
	private List<Map<String,Object>> uniquePerEntityModulesQuestions = null;
	
	/**
	 * A pool used to track the full set of unique keys to be used to generate modules;
	 * Maps entity ids to answer value objects
	 */
	private Map<String,JSONObject> uniqueKeys = new HashMap<String,JSONObject>();
	
	/**
	 * A pool used to track the "unique-per-entity" answer value combinations
	 * that exist at a given time. 
	 * The "key" of this map is the answer value object, 
	 * while the "value" of this map is the list of questions that have  
	 * this answer value as the chosen answer.
	 */
	private Map<Object,List<Object>> uniquePerEntityQuestionCombinations = new LinkedHashMap<Object,List<Object>>();
	
	/**
	 * A pool used to track the "unique-per-all-modules" answer value combinations
	 * that exist at a given time. 
	 * The "key" of this map is the answer value object, 
	 * while the "value" of this map is the list of questions that have 
	 * this answer value as the chosen answer.
	 */
	private Map<Object,List<Object>> uniquePerAllModuleQuestionCombinations = new LinkedHashMap<Object,List<Object>>();
	
	/**
	 * A pool used to track the "unique-per-entity-modules" answer value combinations
	 * that exist at a given time. 
	 * The "key" of this map is the answer value object, 
	 * while the "value" of this map is the list of questions that have  
	 * this answer value as the chosen answer.
	 */
	private Map<Object,List<Object>> uniquePerEntityModuleQuestionCombinations = new LinkedHashMap<Object,List<Object>>();
	
	/**
	 * Used to track randomly generated data
	 */
	private Map<String,Map<Object,Integer>> tempDataTracker = new HashMap<String,Map<Object,Integer>>();
	
	/**
	 * The list of generated modules (computed based on the supplied data)
	 */
	@SuppressWarnings("unused")
	private JSONArray modules;
	
	/**
	 * Sets up the list of generated modules
	 */
	public void generateModuleList() {
		
		setModules( manager.generateModuleObjects( this ) );
		
	}

	//////////////////////////////////////////////////////////
	// Getters and Setters
	/////////////////////////////////////////////////////////

	public List<Map<String,Object>> getQuestionFields() {
		return questionFields;
	}

	public void setQuestionFields(List<Map<String,Object>> questionFields) {
		this.questionFields = questionFields;
	}
	
	public void addQuestionFields(List<Map<String,Object>> questionFields){
		if ( this.questionFields == null ) this.questionFields = new ArrayList<Map<String,Object>>();
		
		this.questionFields.addAll( questionFields );
	}
	
	public String getCouchDbHost() {
		return couchDbHost;
	}

	public void setCouchDbHost(String couchDbHost) {
		this.couchDbHost = couchDbHost;
	}

	public Integer getCouchDbPort() {
		return couchDbPort;
	}

	public void setCouchDbPort(Integer couchDbPort) {
		this.couchDbPort = couchDbPort;
	}

	public String getCouchDbName() {
		return couchDbName;
	}

	public void setCouchDbName(String couchDbName) {
		this.couchDbName = couchDbName;
	}

	public Integer getNumberOfModules() {
		return numberOfModules;
	}
	
	public Integer getNumberOfModuleInstances() {
		return numberOfModuleInstances;
	}

	public void setNumberOfModuleInstances(Integer numberOfModuleInstances) {
		this.numberOfModuleInstances = numberOfModuleInstances;
		// set number of modules
		setNumberOfModules();
	}

	private void setNumberOfModules() {
		if ( getNumberOfModuleInstances()!= null && getNumberOfEntities() != null ) {
			this.numberOfModules = getNumberOfModuleInstances() * getNumberOfEntities();
		}
	}

	public Integer getNumberOfEntities() {
		return numberOfEntities;
	}

	public void setNumberOfEntities(Integer numberOfEntities) {
		this.numberOfEntities = numberOfEntities;
		// set number of modules
		setNumberOfModules();
	}

	private void setModules(JSONArray modules) {
		this.modules = modules;
	}
		
	public String getModuleId() {
		return moduleId;
	}

	public void setModuleId(String moduleId) {
		this.moduleId = moduleId;
	}

	public Integer getActualNumberOfModules() {
		if ( actualNumberOfModules == null ) 
			calculateActualNumberOfModulesAndEntities();
		return actualNumberOfModules;
	}

	public Integer getActualNumberOfEntities() {
		if ( actualNumberOfEntities == null )
			calculateActualNumberOfModulesAndEntities();
		return actualNumberOfEntities;
	}

	public Integer getActualNumberOfCouchDbDocuments() {
		return actualNumberOfCouchDbDocuments;
	}

	public void setActualNumberOfCouchDbDocuments(
			Integer actualNumberOfCouchDbDocuments) {
		this.actualNumberOfCouchDbDocuments = actualNumberOfCouchDbDocuments;
	}

	public List<Map<String,Object>> retrieveUniquePerAllModulesQuestions() {
		if ( uniquePerAllModulesQuestions == null  )
			uniquePerAllModulesQuestions = getUniquePerEntityOrModuleQuestionFields( UNIQUE_PER_ALL_MODULES );
		return uniquePerAllModulesQuestions;
	}
	
	public List<Map<String,Object>> retrieveUniquePerEntityModulesQuestions() {
		if ( uniquePerEntityModulesQuestions == null  )
			uniquePerEntityModulesQuestions = getUniquePerEntityOrModuleQuestionFields( UNIQUE_PER_ENTITY_MODULES );
		return uniquePerEntityModulesQuestions;
	}

	public List<Map<String,Object>> retrieveUniquePerEntityQuestions() {
		if ( uniquePerEntityQuestions == null )
			uniquePerEntityQuestions = getUniquePerEntityOrModuleQuestionFields( UNIQUE_PER_ENTITY );
		return uniquePerEntityQuestions;
	}
	
	public Map<String,Map<Object,Integer>> getTracker()
	{
		return tempDataTracker;
	}
	
	public Map<Object, List<Object>> getUniquePerEntityQuestionCombinations() {
		return uniquePerEntityQuestionCombinations;
	}

	public Map<Object, List<Object>> getUniquePerAllModuleQuestionCombinations() {
		return uniquePerAllModuleQuestionCombinations;
	}

	public Map<Object, List<Object>> getUniquePerEntityModuleQuestionCombinations() {
		return uniquePerEntityModuleQuestionCombinations;
	}
	

	//////////////////////////////////////////////////////////
	// END Getters and Setters
	/////////////////////////////////////////////////////////\
	//////////////////////////////////////////////////////////
	// Public modifier methods
	/////////////////////////////////////////////////////////\
	/**
	 * Calculates the maximum number of modules/entities that can be reasonably generated.
	 */
	private void calculateActualNumberOfModulesAndEntities()
	{
		// the actual number of modules 
		int actualNumberOfModules = adjustNumberOfModules();
		
		// the actual number of entities
		int actualNumberOfEntities = adjustNumberOfEntities( actualNumberOfModules );
		
		// maximum number of modules per entity
		int numberOfModulesPerEntity = (int)Math.floor( actualNumberOfModules / actualNumberOfEntities );
		
		// re-calculate the actual number of modules based on the number of docs per entity
		actualNumberOfModules = (numberOfModulesPerEntity * actualNumberOfEntities) ;
		
		// set the actual number of modules
		this.actualNumberOfModules = actualNumberOfModules;
		
		// set up the actual number of entities
		this.actualNumberOfEntities = actualNumberOfEntities;
		
	}
	
	/**
	 * Calculates the maximum number of modules that can be reasonably generated.
	 */
	private int adjustNumberOfModules()
	{	
		List<Map<String,Object>> list = retrieveUniquePerAllModulesQuestions();
		
		// If there are no "unique-per-module" questions,
		// then leave the number of modules as is
		if ( list == null || (list != null && list.isEmpty()) ) return getNumberOfModules();
		
		int realisticNumModules = 1;
		
		for ( Map<String,Object> question : list )
		{
			int questionDomainSize = getDomainSize( question );
			
			if ( questionDomainSize == Integer.MAX_VALUE ) {
				
				realisticNumModules = questionDomainSize;
				
				break;
			}
			
			realisticNumModules *= questionDomainSize; 
		}
		
		// adjust the number of modules as necessary:
		// -if the total number of realistically possible modules 
		// is less than the total number of requested modules,
		// then return the realistic number		
		return Math.min( realisticNumModules, getNumberOfModules() );
	}
	
	/**
	 * Calculates the minimum number of entities that can be reasonably generated.
	 */
	private int adjustNumberOfEntities( int numberOfModules )
	{
		List<Map<String,Object>> uniquePerEntityList = retrieveUniquePerEntityQuestions();
		
		List<Map<String,Object>> uniquePerEntityModulesList = retrieveUniquePerEntityModulesQuestions();
		
		boolean hasUniquePerEntityQuestions          = CollectionUtils.isNotEmpty( uniquePerEntityList );
		
		boolean hasUniquePerEntityModulesQuestions = CollectionUtils.isNotEmpty( uniquePerEntityModulesList );
		
		// If there are no "unique-per-entity-modules" or "unique-per-entity" questions,
		// then leave the number of entities as is
		if ( ( ! hasUniquePerEntityQuestions ) && ( ! hasUniquePerEntityModulesQuestions ) ) return getNumberOfEntities();
		
		// set up a variable that will be used to capture either the maximum number of modules per entity
		// or the maximum number of entities, depending on the type of questions that are available
		int temp = 1;
		
		// the maximum realistic number of modules per entity
		int realisticNumModulesPerEntity = 0;
		
		// the maximum (or minimum) number of entities that is realistic
		int realisticNumEntities = 0;
		
		// list of questions to iterate through:
		// if there are "unique-per-entity" questions then this should be used
		// to calculate the minimum realistic number of entities
		// else, use the "unique-per-entity-modules" questions
		List<Map<String,Object>> list = hasUniquePerEntityQuestions ? uniquePerEntityList : uniquePerEntityModulesList ;
		
		for ( Map<String,Object> question : list )
		{
			int questionDomainSize = getDomainSize( question );
			
			if ( questionDomainSize == Integer.MAX_VALUE ) {
				
				temp = questionDomainSize;
				
				break;
			}
			
			temp *= questionDomainSize; 
		}
		
		if ( hasUniquePerEntityQuestions )
		{
			// Then "temp" represents the maximum number of realistically possible entities
			realisticNumEntities = temp;
			
			// if the maximum number of realistically possible entities
			// is greater than the total number of requested entities,
			// then use the requested number of entities
			realisticNumEntities = Math.min( realisticNumEntities, getNumberOfEntities() );
		}
		
		else if ( hasUniquePerEntityModulesQuestions )
		{
			// Then "temp" represents the maximum number of realistically possible modules per entity
			realisticNumModulesPerEntity = temp;
			
			// Determine the minimum number of realistically possible entities
			realisticNumEntities = (int)Math.floor( numberOfModules/realisticNumModulesPerEntity );
					
			// if the minimum number of realistically possible entities
			// is greater than the total number of requested entities,
			// then adjust the number of entities
			realisticNumEntities = Math.max( realisticNumEntities, getNumberOfEntities() );
		}
		// if the number of entities
		// is greater than the total number of modules,
		// then adjust the number of entities
		// by allowing only 1 module per entity;
		// that way, the unique-per-entity/unique-per-entity-module fields would always be unique for entities.
		if ( realisticNumEntities > numberOfModules ) realisticNumEntities = numberOfModules;
		
		return realisticNumEntities;
	}
	
	/**
	 * Provides a way to track the frequency of the randomly generated answers for a question
	 */
	public synchronized void trackQuestionAndAnswer( String questionId, Object answer )
	{
		Map<Object,Integer> answerFrequencies = tempDataTracker.get( questionId );
		
		if ( answerFrequencies == null ) answerFrequencies = new HashMap<Object,Integer>();
		
		Integer frequency = answerFrequencies.get( answer );
		
		if ( frequency == null ) frequency = 0;
		
		answerFrequencies.put( answer, ++frequency );
		
		tempDataTracker.put( questionId, answerFrequencies );
	}	
	
	
	public Map<String,JSONObject> getUniqueKeys() {
		return uniqueKeys;
	}

	//////////////////////////////////////////////////////////
	// UTILITY methods
	/////////////////////////////////////////////////////////\
	/**
	 * Gets the list of "unique-per-entity", "unique-per-all-modules" or "unique-per-entity-modules" fields
	 * @param form
	 * @return
	 */
	private List<Map<String,Object>> getUniquePerEntityOrModuleQuestionFields( String uniquePerEntityOrModuleFlag )
	{
		List<Map<String,Object>> list = null;
		
		if ( getQuestionFields() != null && ! getQuestionFields().isEmpty() )
		{
			list = new ArrayList<Map<String,Object>>();
			
			for ( Map<String,Object> question : getQuestionFields() )
			{
				if ( isSelected( question ) )
				{
					// If this is one of the fields that must be unique for each entity,
					// then add to the list if the flag is "uniquePerEntity"
					if ( StringUtils.equalsIgnoreCase( uniquePerEntityOrModuleFlag, UNIQUE_PER_ENTITY ) )
					{
						if ( isPartOfUniquePerEntity( question ) )
						{
							list.add( question );
						}
					}
					
					// Else, if this is one of the fields that must be unique for each module,
					// then add to the list if the flag is "uniquePerAllModules"
					else if ( StringUtils.equalsIgnoreCase( uniquePerEntityOrModuleFlag, UNIQUE_PER_ALL_MODULES ) )
					{
						if ( isPartOfUniquePerAllModules( question ) )
						{
							list.add( question );
						}
					}		
					
					// Else, if this is one of the fields that must be unique for each of an entity's modules,
					// then add to the list if the flag is "uniquePerEntityModules"
					else if ( StringUtils.equalsIgnoreCase( uniquePerEntityOrModuleFlag, UNIQUE_PER_ENTITY_MODULES ) )
					{
						if ( isPartOfUniquePerEntityModules( question ) )
						{
							list.add( question );
						}
					}		
				}
			}
		}
		
		return list;
	}
	
	/**
	 * Purges the given key from all collection which keep track of unique keys
	 */
	public void purgeQuestionCombinations( Map<String,JSONObject> uniqueKey, String entityId, int entityDocId, int docId )
	{
		for ( Map.Entry< String, JSONObject > entry: uniqueKey.entrySet() )
		{
			String key = GeneratedModuleDataDetail.getTwoPartMapKey(
					entry.getKey(), 
					entry.getValue().get( ANSWERVALUE_VALUE ).toString() );
			
			uniquePerAllModuleQuestionCombinations.get( key ).remove( docId );
			
			uniquePerEntityModuleQuestionCombinations.get( key ).remove( entityDocId );
			
			uniquePerEntityQuestionCombinations.get( key ).remove( entityId );
		}
	}
	
	/**
	 * Static method indicating whether or not the given object has been selected
	 */
	@SuppressWarnings("unchecked")
	public static boolean isSelected( Map object )
	{
		if ( (! object.containsKey( SELECTED )) || object.get( SELECTED ) == null  || object.get( SELECTED ).equals( null ) ) return false;
		
		if ( StringUtils.equalsIgnoreCase( ( String )object.get( SELECTED ), NULL ) ) return false;
		
		return StringUtils.isNotBlank( ( String )object.get( SELECTED ) );
	}
	

	
	/**
	 * Static method which returns whether or not this question is a free-text question
	 */
	@SuppressWarnings("unchecked")
	public static boolean isFreeTextQuestion( Map question )
	{
		if ( question == null ) return false;
		
		List staticAnswerValues = ((List)(( Map )question.get(ANSWERVALUES)).get( STATIC ));
				
		return ( staticAnswerValues == null || staticAnswerValues.size() <= 1 );
	}
	
	/**
	 * Static method which generates the map key for any of the questionCombination maps
	 * using the given map key parts
	 */
	public static String getTwoPartMapKey( String firstPart, String secondPart )
	{
		return StringUtils.defaultIfEmpty( firstPart, "" )  
				+ MAP_KEY_SEPARATOR  
				+ StringUtils.defaultIfEmpty( secondPart, "" );
	}
	
	/**
	 * Static method which returns the specified part of a given questionCombination map key
	 */
	public static String getMapKeyPart( String mapKey, int part )
	{
		if ( part == MAP_KEY_FIRST_PART )
			return StringUtils.substringBefore( mapKey, MAP_KEY_SEPARATOR );
		
		else if ( part == MAP_KEY_SECOND_PART )
			return StringUtils.substringAfter( mapKey, MAP_KEY_SEPARATOR );
		
		else return null;
	}
	

	/**
	 * Returns whether or not this question is one of the question fields
	 * that must be unique for each entity
	 */
	private boolean isPartOfUniquePerEntity( Map<String,Object> question )
	{
		if ( question == null || ! question.containsKey( UNIQUE_PER_ENTITY ) ) return false;
		
		return StringUtils.isNotBlank( ( String )question.get( UNIQUE_PER_ENTITY ) );
	}
	
	/**
	 * Returns whether or not this question is one of the question fields
	 * that must be unique for each module
	 */
	private boolean isPartOfUniquePerAllModules( Map<String,Object> question )
	{
		if ( question == null || ! question.containsKey( UNIQUE_PER_ALL_MODULES ) ) return false;
		
		return StringUtils.isNotBlank( ( String ) question.get( UNIQUE_PER_ALL_MODULES ) );
	}
	
	/**
	 * Returns whether or not this question is one of the question fields
	 * that must be unique for each of an entity's modules
	 */
	private boolean isPartOfUniquePerEntityModules( Map<String,Object> question )
	{
		if ( question == null || ! question.containsKey( UNIQUE_PER_ENTITY_MODULES ) ) return false;
		
		return StringUtils.isNotBlank( ( String ) question.get( UNIQUE_PER_ENTITY_MODULES ) );
	}
	
	/**
	 * Returns the maximum number of possible answers for this question.
	 */
	@SuppressWarnings({ "unchecked" })
	public static int getDomainSize( Map<String,Object> question )
	{
		int domainSize = 0;
		
		String commaDelimitedList = ( String )question.get( LIST );
		
		String lowerBound = ( String )question.get( LOWERBOUND );
		
		String upperBound = ( String )question.get( UPPERBOUND );
		
		if ( !isFreeTextQuestion(question) )
		{// domain size will be the number of preset answer values
			domainSize = ((List)(( Map )question.get(ANSWERVALUES)).get( STATIC )).size();
		}
		
		else if ( StringUtils.isNotEmpty( commaDelimitedList ) )
		{// domain size will be the number of unique tokens
			domainSize = 
				new HashSet<String>(Arrays.asList( StringUtils.split( commaDelimitedList, COMMA ) ) ).size();
		}
		
		else if ( StringUtils.isNotEmpty( lowerBound ) && StringUtils.isNotEmpty( upperBound ) )
		{// domain size will be the maximum number of elements that could be generated
	     // which fall within the specified range
			domainSize =
				RandomGeneratorUtils.getNumberOfElementsInRange( lowerBound, upperBound );
		}
		
		else domainSize = Integer.MAX_VALUE; // unlimited domain size
		
		return domainSize;
	}
	
	//////////////////////////////////////////////////////////
	// END UTILITY methods
	/////////////////////////////////////////////////////////\
	
}
