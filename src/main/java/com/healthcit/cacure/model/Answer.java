package com.healthcit.cacure.model;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.ListIterator;
import java.util.UUID;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.OrderBy;
import javax.persistence.PostLoad;
import javax.persistence.PrePersist;
import javax.persistence.PreRemove;
import javax.persistence.PreUpdate;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.lang.ArrayUtils;
import org.apache.log4j.Logger;

import com.healthcit.cacure.model.BaseQuestion.ChildrenRemovalType;
import com.healthcit.cacure.model.BaseQuestion.QuestionType;
import com.healthcit.cacure.utils.StringUtils;

/**
 * @author User
 *
 */
@Entity
@Table(name="ANSWER")
//@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class Answer implements StateTracker, Cloneable {
	private static final Logger log = Logger.getLogger(Answer.class);

	public enum AnswerType {
		TEXT( "text",
			   new QuestionType[]{QuestionType.SINGLE_ANSWER},
			   AnswerValueType.SINGLE, 
			   Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.LENGTH } ), 
			   TextValueConstraint.class,
			   Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION )),
			   
		NUMBER( "text",
			   new QuestionType[]{QuestionType.SINGLE_ANSWER},
			   AnswerValueType.SINGLE, 
			   Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.LENGTH } ),
			   NumberValueConstraint.class,
			   Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION )),
			   
	   INTEGER( "text",
			   new QuestionType[]{QuestionType.SINGLE_ANSWER},
			   AnswerValueType.SINGLE, 
			   Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.LENGTH } ),
			   NumberValueConstraint.class,
			   Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION )),
			   
	   POSITIVE_INTEGER( "text",
			   new QuestionType[]{QuestionType.SINGLE_ANSWER},
			   AnswerValueType.SINGLE, 
			   Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.LENGTH } ),
			   NumberValueConstraint.class,
			   Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION )),

		RADIO( "radio",
				new QuestionType[]{QuestionType.SINGLE_ANSWER},
				AnswerValueType.MULTIPLE,
				Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.ALIGNMENT } ),
				null,
				Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.SIMPLE_TABLE_QUESTION )),

		DROPDOWN( "dropdown",
				new QuestionType[]{QuestionType.SINGLE_ANSWER},
				AnswerValueType.MULTIPLE,
				new ArrayList<AnswerDisplayStyle>(),
				null,
				Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION )),

		CHECKBOX( "checkbox",
				new QuestionType[]{QuestionType.MULTI_ANSWER},
				AnswerValueType.MULTIPLE,
				Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.ALIGNMENT } ),
				null,
				Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.SIMPLE_TABLE_QUESTION )),
				
		YEAR( "text",
			  new QuestionType[]{QuestionType.SINGLE_ANSWER},
			  AnswerValueType.SINGLE,
			  Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.LENGTH } ), 
			  null,
			  Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION )),
			  
		MONTHYEAR( "text",
					new QuestionType[]{QuestionType.SINGLE_ANSWER},
					AnswerValueType.SINGLE,
					Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.LENGTH } ), 
					null,
					Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION )),

		DATE( "text",
				new QuestionType[]{QuestionType.SINGLE_ANSWER},
				AnswerValueType.SINGLE,
				new ArrayList<AnswerDisplayStyle>(),
				null,
				Arrays.asList( QuestionElementType.SIMPLE_QUESTION, QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION )),
				
		TEXTAREA( "text",
				new QuestionType[]{QuestionType.SINGLE_ANSWER},
				AnswerValueType.SINGLE,
				Arrays.asList( new AnswerDisplayStyle[]{ AnswerDisplayStyle.LENGTH } ), 
				null,
				Arrays.asList( QuestionElementType.SIMPLE_QUESTION )),
				
		CHECKMARK( "checkbox",
				new QuestionType[]{QuestionType.SINGLE_ANSWER},
				AnswerValueType.MULTIPLE,
				new ArrayList<AnswerDisplayStyle>(),
				null,
				Arrays.asList( QuestionElementType.STATIC_TABLE_QUESTION, QuestionElementType.DYNAMIC_TABLE_QUESTION ));

		/**
		 * The HTML control associated with this Answer Type
		 */
		private final String inputType;

		/**
		 * The Question Types associated with this Answer Type
		 */
		private final QuestionType[] questionTypes;

		/**
		 *
		 * Enum of Answer Value Types
		 *
		 */
		public enum AnswerValueType { SINGLE, MULTIPLE }

		/**
		 * Whether or not this Answer Type is associated with multiple answer values
		 */
		private final AnswerValueType answerValueType;
		
		/**
		 * Enum of Answer Table Types
		 */
		public enum QuestionElementType { SIMPLE_QUESTION, SIMPLE_TABLE_QUESTION, STATIC_TABLE_QUESTION, DYNAMIC_TABLE_QUESTION }
		
		/**
		 * Display question element types that may be associated with this Answer Type
		 */
		private List<QuestionElementType> questionElementTypes;

		/**
		 * Display Style(s) associated with this Answer Type; not required; defaults to empty list
		 */
		private List<AnswerDisplayStyle> displayStyles;
		
		private Class<? extends AnswerValueConstraint> constraintClass;
		
		private AnswerType( String inputType, QuestionType[] questionTypes, AnswerValueType answerValueType, List<AnswerDisplayStyle> displayStyle, Class<? extends AnswerValueConstraint> constraintClass){
			this(inputType, questionTypes, answerValueType, displayStyle, constraintClass, Arrays.asList(QuestionElementType.values()));
		}		

		private AnswerType( String inputType, QuestionType[] questionTypes, AnswerValueType answerValueType, List<AnswerDisplayStyle> displayStyle, Class<? extends AnswerValueConstraint> constraintClass, List<QuestionElementType> answerTableTypes) {
			this.inputType = inputType;
			this.questionTypes = questionTypes;
			this.answerValueType = answerValueType;
			this.displayStyles = displayStyle;
			this.constraintClass = constraintClass;
			this.questionElementTypes = answerTableTypes;
		}
		
		public String getInputType() {
			return inputType;
		}

		public Class<? extends AnswerValueConstraint> getConstraintClass(){
			return constraintClass;
		}
		public QuestionType[] getQuestionTypes() {
			return questionTypes;
		}

		public AnswerValueType getAnswerValueType() {
			return answerValueType;
		}

		public List<AnswerDisplayStyle> getDisplayStyles() {
			return displayStyles;
		}
		
		public List<QuestionElementType> getQuestionElementTypes() {
			return questionElementTypes;
		}

		public JSONObject toJSONObject(){
			JSONObject jsonObject = new JSONObject();

			// Input Type
			jsonObject.put( "inputType", getInputType() );

			// Answer Value Type
			jsonObject.put( "answerValueType", getAnswerValueType().name() );

			// Display Styles
			JSONObject displayStyles = new JSONObject();
			for ( AnswerDisplayStyle a : getDisplayStyles() ) {
				JSONArray array = new JSONArray();
				for ( String str : a.getTypes() ) {
					array.add( str );
				}
				displayStyles.put( a.name(), array );
			}
			jsonObject.put( "displayStyle", displayStyles );
			
			// Question Element Types
			JSONArray questionElementTypes = new JSONArray();
			for ( QuestionElementType a : getQuestionElementTypes() ) {
				questionElementTypes.add( a.name() );
			}
			jsonObject.put( "questionElementTypes", questionElementTypes );

			// Question Types
			JSONArray questionTypes = new JSONArray();
			for ( QuestionType qt : getQuestionTypes() ) {
				questionTypes.add( qt.name() );
			}
			jsonObject.put( "questionType", questionTypes );

			// Return JSON object
			return jsonObject;
		}

	}

	/**
	 * AnswerDisplayStyle provides an enumeration of display styles used by an Answer entity
	 * @author Oawofolu
	 *
	 */
	public enum AnswerDisplayStyle {
		NONE , ALIGNMENT( new String[]{ "Vertical", "Horizontal" } ), LENGTH(new String[]{"Short", "Medium", "Long"});

		private String[] types;
		public String[] getTypes() {
			return types;
		}

		private AnswerDisplayStyle(){
			this( new String[]{} );
		}
		private AnswerDisplayStyle( String[] types ) {
			this.types = types;
		}
	}

	@Transient
	private static final List<ValueLabelPair<String, String>> listOfTypes;
	@Transient
	public static final JSONObject answerMappings;
	@Transient 
	public static final JSONObject answerTypeConstraintMappings;

	static
	{
		listOfTypes = new ArrayList<ValueLabelPair<String, String>>();
		for(AnswerType qt:  AnswerType.values())
		{
			listOfTypes.add(new ValueLabelPair<String, String>(qt.name(), qt.name()));
		}

		answerMappings = new JSONObject();
		answerTypeConstraintMappings = new JSONObject();

		for ( AnswerType at : AnswerType.values() )
		{
			answerMappings.put( at.name(), at.toJSONObject() );
			Class<? extends AnswerValueConstraint> constraintClass = at.getConstraintClass();
			if (constraintClass != null)
			{
				AnswerValueConstraint constraint;
				try 
				   {
					   Constructor<? extends AnswerValueConstraint> constructor = constraintClass.getConstructor();
					   constraint = constructor.newInstance();
					   List<ConstraintValue> constraintValues = constraint.getValuesAsList();
					   answerTypeConstraintMappings.put(at.name(), constraintValues);
				   }
				   catch(NoSuchMethodException e)
				   {
					   log.error("There are no String argument constructor present in class " + constraintClass);
					   log.error(e.getMessage(), e);
					   throw new UnsupportedOperationException("There are no String argument constructor present in class " + constraintClass, e);
				   }
				   catch (InvocationTargetException e)
				   {
					   log.error("Error constructing object of type " + constraintClass);
					   log.error(e.getMessage(), e);
					   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

				   }
				   catch(IllegalAccessException e)
				   {
					   log.error("Error constructing object of type " + constraintClass);
					   log.error(e.getMessage(), e);
					   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

				   }
				   catch(InstantiationException e)
				   {
					   log.error("Error constructing object of type " + constraintClass);
					   log.error(e.getMessage(), e);
					   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);
				   }
			}
		}

	}

	@Id
	@SequenceGenerator(name="genericSequence", sequenceName="\"GENERIC_ID_SEQ\"", allocationSize=5)
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="genericSequence")
	private Long id;

	@Column(name="uuid", nullable=false)
	private String uuid;
	
	@OneToOne(cascade={CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH}, fetch=FetchType.LAZY)
	@JoinColumn(name="question_id", nullable=false)
	private BaseQuestion question;

	@Column(nullable=false)
	@Enumerated (EnumType.STRING)
	private AnswerType type = AnswerType.TEXT;  // default to regular text

	private String description;

	@Column(name="GROUP_NAME")
	private String groupName;
/*
	@Column(name="ord", nullable=false)
	private Integer ord;
*/
	@Column(name="answer_column_heading")
	private String answerColumnHeading;

	@Column(name="display_style")
	private String displayStyle;

	@Transient
	private boolean valid=true;
	
	@Transient
	private List<Long> cadsrPublicIdList = null;

	// JPA does not have DELETE_ORPHAN - using hibernate mix-in here
	@OneToMany(orphanRemoval=true, mappedBy="answer",cascade=CascadeType.ALL, fetch=FetchType.EAGER)
//	@Cascade( { org.hibernate.annotations.CascadeType.DELETE_ORPHAN })
//	@Fetch(FetchMode.SUBSELECT)
	@OrderBy("ord ASC")
	private List<AnswerValue> answerValues = new ArrayList<AnswerValue>(); // need to be initialized to add AnswersValues to it
	
	@Transient
	private AnswerValueConstraint constraint;
	
	@Column(name="VALUE_CONSTRAINT")
	private String formattedConstraint;

	/**
	 * Helper constructor to generate invalid objects
	 * @param valid
	 */
	public Answer() {
	}

	/**
	 * Helper constructor to generate invalid objects
	 * @param valid
	 */
	public Answer(boolean valid) {
		this.valid = valid;
	}

	/**
	 * @return the description
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * @return the Constraint for the answer
	 */
	public AnswerValueConstraint getConstraint() {
		return constraint;
	}
	
	/**
	 * 
	 * @param constraint the constraint to set
	 */
	public void setConstraint(AnswerValueConstraint constraint)
	{
		this.constraint = constraint;
	}
	
	public void setUuid(String uuid)
	{
		this.uuid = uuid; 
	}
	public String getUuid()
	{
		return this.uuid;
	}
	
	
	public void setConstraint(List<ConstraintValue> constraintValues)
	{
		Class<? extends AnswerValueConstraint> constraintClass = type.getConstraintClass();
		if (constraintClass != null)
		{
			try 
			   {
				   Constructor<? extends AnswerValueConstraint> constructor = constraintClass.getConstructor();
				   AnswerValueConstraint constraint = constructor.newInstance();
				   constraint.createFromList(constraintValues);
				   this.constraint = constraint;
			   }
			   catch(NoSuchMethodException e)
			   {
				   log.error("There are no String argument constructor present in class " + constraintClass);
				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("There are no String argument constructor present in class " + constraintClass, e);
			   }
			   catch (InvocationTargetException e)
			   {
				   log.error("Error constructing object of type " + constraintClass);
				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

			   }
			   catch(IllegalAccessException e)
			   {
				   log.error("Error constructing object of type " + constraintClass);
				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

			   }
			   catch(InstantiationException e)
			   {
				   log.error("Error constructing object of type " + constraintClass);
				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);
			   }
		}
	}
	
	public void storeConstraint()
	{
    	if (constraint != null)
    	{
		    formattedConstraint = constraint.getValueAsString();
    	}
    	else 
    	{
    		formattedConstraint = null;
    	}
	}
	
	@SuppressWarnings("unused")
	@PostLoad
	private void loadConstraint()
	{
		AnswerValueConstraint constraint = null;
		Class<? extends AnswerValueConstraint> constraintClass = type.getConstraintClass();
		if (constraintClass != null)
		{
			try 
			   {
				   Constructor<? extends AnswerValueConstraint> constructor = constraintClass.getConstructor(String.class);
				   constraint = constructor.newInstance(this.formattedConstraint);
			   }
			   catch(NoSuchMethodException e)
			   {
				   log.error("There are no String argument constructor present in class " + constraintClass);
				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("There are no String argument constructor present in class " + constraintClass, e);
			   }
			   catch (InvocationTargetException e)
			   {
				   log.error("Error constructing object of type " + constraintClass);
				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

			   }
			   catch(IllegalAccessException e)
			   {
				   log.error("Error constructing object of type " + constraintClass);
				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);

			   }
			   catch(InstantiationException e)
			   {
				   log.error("Error constructing object of type " + constraintClass);
				   log.error(e.getMessage(), e);
				   throw new UnsupportedOperationException("Error constructing object of type " + constraintClass, e);
			   }
		}
		this.constraint = constraint;
	}
	
	/**
	 * @param description the description to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	/**
	 * @return the groupName
	 */
	public String getGroupName() {
		return groupName;
	}

	/**
	 * @param groupName the groupName to set
	 */
	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}

	/**
	 * @return the id
	 */
	public Long getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(Long id) {
		this.id = id;
	}

	/**
	 * @return the type
	 */
	public AnswerType getType() {
		return type;
	}

	/**
	 * @param type the type to set
	 */
	public void setType(AnswerType type) {
		this.type = type;
	}
/*
	public Integer getOrd() {
		return ord;
	}

	public void setOrd(Integer ord) {
		this.ord = ord;
	}
*/
	@Override
	public boolean isNew() {
		return (id == null);

	}

	/**
	 * isEmpty returns true if valid flag is false and ID is null
	 * @return boolean
	 */
	@Transient
	public boolean isEmpty()
	{
		return (! valid && id == null);
	}

	public boolean isValid() {
		return valid;
	}

	public void setValid(boolean valid) {
		this.valid = valid;
	}

	public List<ValueLabelPair<String, String>> getAnswerTypes()
	{
		return listOfTypes;
	}

	/**
	 * @return the question
	 */
	public BaseQuestion getQuestion() {
		return question;
	}

	/**
	 * @param question the question to set
	 */
	public void setQuestion(BaseQuestion question) {
		this.question = question;
	}

	@Transient
	public String getDisplayStyle() {
		return displayStyle;
	}

	public void setDisplayStyle(String displayStyle) {
		this.displayStyle = displayStyle;
	}

	@Override
	public Answer clone() {
		Answer o = copy();
		
		if (getAnswerValues() != null) {
			for (AnswerValue answerValue : getAnswerValues()) {
				o.addAnswerValues(answerValue.clone());
			}
		}
		return o;
	}
	
	public Answer copy() {
		Answer o = new Answer();
		o.setDescription(description);
		o.setGroupName(groupName);
		o.setType(type);
		o.setValid(valid);
		o.setDisplayStyle(displayStyle);
		o.setAnswerColumnHeading(answerColumnHeading);
		if(this.constraint != null) {
			o.setConstraint(constraint.clone());
			o.storeConstraint();
		}
		
		
		return o;
	}
	
	public void resetId()
	{
		this.id= null;
		if (answerValues != null)
		{
			for (AnswerValue av: answerValues)
			{
				av.resetId();
			}
		}
	}

	
	
	@SuppressWarnings("unused")
	@PrePersist
	private void prePersist()
	{
		if ( this.getUuid() == null )
			this.setUuid(UUID.randomUUID().toString());
		setDescription(StringUtils.normalizeString(getDescription()));
		updateLastUpdated();
		
	}
	@PreUpdate
	@PreRemove
	@SuppressWarnings("unused")
	private void onUpdate() {
		setDescription(StringUtils.normalizeString(getDescription()));
		updateLastUpdated();

	}

	private void updateLastUpdated()
	{
		BaseForm form = getQuestion().getParent().getForm();
		form.setLastUpdatedBy(form.getLockedBy());
	}
	
	public List<AnswerValue> getAnswerValues() {
		return answerValues;
	}

	public void setAnswerValues(List<AnswerValue> answersValues) {
		if ( this.answerValues==null ) {
			this.answerValues = new ArrayList<AnswerValue>();
		}
		else {
			this.answerValues.clear();
			for ( AnswerValue v : answersValues ) {
				this.addAnswerValues( v );
			}
		}
	}
	
	/**
	 * Method which determines whether or not 
	 * the associated question has answer values with duplicate unique identifiers
	 * (For caDSR, it will return questions with answer values 
	 * that have the same Public ID)
	 * @author Oawofolu
	 * @return
	 */
	public Boolean getHasDuplicateAnswerValues() {
		boolean hasDuplicates = false;
		if ( question != null ) {
			if ( question.isCadsrQuestion() ) {
				HashSet<Long> tempSet = new HashSet<Long>( cadsrPublicIdList == null ? getCadsrPublicIdList() : cadsrPublicIdList );
				hasDuplicates = ( tempSet.size() != cadsrPublicIdList.size() );
				tempSet.clear();
			}
		}
		return hasDuplicates;
	}
	
	public List<Long> getCadsrPublicIdList(){
		if ( cadsrPublicIdList == null ) {
			cadsrPublicIdList = new ArrayList<Long>();
			for ( AnswerValue av : answerValues ) {
				if ( av.getCadsrPublicId() != null ) {
					cadsrPublicIdList.add( av.getCadsrPublicId() );
				}
			}
		}
		return cadsrPublicIdList;
	}

	public void addAnswerValues(AnswerValue answerValue) {
		this.answerValues.add(answerValue);
		answerValue.setAnswer(this);
	}
	
	public void addDefaultAnswerValue() {
		String description = this.getDescription();
		AnswerValue av = new AnswerValue();
		av.setDescription( description );
		av.setName( description );
		av.setValue( description );
		av.setOrd( 1 );
		addAnswerValues( av );
	}
	
	/**
	 * Returns permissible data types
	 * @return
	 */
	public String[] getDataTypes(){
		List<String> dataTypes = new ArrayList<String>();
		
		// all answers can have type = "text"
		dataTypes.add( "text" );
		
		// NumberValueConstraints imply type = "number"
		if ( getType().getConstraintClass() != null &&
			 getType().getConstraintClass().equals( NumberValueConstraint.class ) )
		{
			dataTypes.add( "number" );
		}
		
		// The AnswerTypes DATE, MONTHYEAR and YEAR will have type = "date"
		if ( ArrayUtils.contains( 
				new String[]{ 
					AnswerType.DATE.name(), 
					AnswerType.YEAR.name(), 
					AnswerType.MONTHYEAR.name() }, 
						getType().name() ) )
		{
			dataTypes.add( "date" );
		}
		
		return dataTypes.toArray( new String[ dataTypes.size() ]);
	}

	/**
	 * help function
	 * @return first AnserValue object from a collection or null
	 */
	public AnswerValue getFirstAnswerValue()
	{
		if (answerValues != null && answerValues.size() > 0)
		{
			return answerValues.get(0);
		}
		else
			return null;
	}

	public String getAnswerColumnHeading() {
		return answerColumnHeading;
	}

	public void setAnswerColumnHeading(String answerColumnHeading) {
		this.answerColumnHeading = answerColumnHeading;
	}

	public void removeExtraneousChildren(ChildrenRemovalType removalType)
	{
		removeExtraneousAnswers(removalType);
	}

	private void removeExtraneousAnswers(ChildrenRemovalType removalType)
	{
		if (answerValues == null)
			return;
		// going in reverse, as most invalid answers are in the back
		ListIterator<AnswerValue> iter = this.answerValues.listIterator(answerValues.size());
		while (iter.hasPrevious())
		{
			@SuppressWarnings("unused")
			AnswerValue a = iter.previous();
			{
				iter.remove();
			}
		}

	}
	
}
