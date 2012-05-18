package com.healthcit.cacure.model;


import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.PrePersist;
import javax.persistence.PreRemove;
import javax.persistence.PreUpdate;
import javax.persistence.Transient;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

@Entity
@DiscriminatorValue("table")
public class TableElement extends FormElement{
	
	@Transient
	private static final Logger logger = Logger.getLogger(TableElement.class);
	
	@OneToMany(orphanRemoval = true, mappedBy="table",cascade=CascadeType.ALL,fetch=FetchType.LAZY)
	@OrderBy("ord")
	protected List<TableQuestion> questions = new ArrayList<TableQuestion>();

	@OneToMany(mappedBy="table", cascade={CascadeType.PERSIST,CascadeType.MERGE,CascadeType.REFRESH}, fetch=FetchType.LAZY)
	@OrderBy("order")
	private List<TableColumn> columns = new ArrayList<TableColumn>();
	
	public enum TableType {SIMPLE, STATIC, DYNAMIC};
	@Column(name="table_type")
	@Enumerated (EnumType.STRING)
	private TableType tableType = TableType.SIMPLE;
	
	@Column(name="table_short_name")
	private String tableShortName;
	
	/* default constructor
	 *
	 */
	public TableElement()
	{
		
	}
	
	public List<AnswerValue> getIdentifyingAnswerValues() {
		ArrayList<AnswerValue> results = new ArrayList<AnswerValue>();
		TableQuestion identifyingQuestion = null;
		for (TableQuestion question : questions) {
			if(question.isIdentifying()) {
				identifyingQuestion = question;
				break;
			}
		}
		if(identifyingQuestion != null) {
			results.addAll(identifyingQuestion.getAnswer().getAnswerValues());
		}
		return results;
	}
	
	public TableQuestion getIdentifyingQuestion() {
		for (TableQuestion question : questions) {
			if(question.isIdentifying()) {
				return question;
			}
		}
		return null;
	}
	
	public TableQuestion getFirstQuestion()
	{
		TableQuestion question = null;
		if(questions != null && questions.size()>0)
		{
			question = questions.get(0);
		}
		return question;
	}
	/**
	 * Returns whether or not the given question is the first question in this table
	 * @param question
	 * @return
	 */
	public boolean isFirstQuestion( TableQuestion question )
	{
		TableQuestion firstQuestion = getFirstQuestion();
		
		if ( question == null || firstQuestion == null ) return false;
		
		return ( StringUtils.equals( question.getTable().getUuid(), firstQuestion.getTable().getUuid() ));
	}

	
	public List<TableColumn> getTableColumns()
	{
		return columns;
	}
	
	public void setTableColumns(List<TableColumn> columns)
	{
		this.columns.clear();
		for(TableColumn column: columns)
		{
			addTableColumn(column);
		}
	}
	
	public void addTableColumn(TableColumn column)
	{
		columns.add(column);
		column.setTable(this);
	}

	@Override
	public List<? extends BaseQuestion> getQuestions() {
		return questions;
	}
	
	public void setQuestions(List<TableQuestion> questions) {
		this.questions.clear();
		for (TableQuestion q : questions)
		{
			addQuestion(q);
		}
	}
	public void addQuestion(TableQuestion question)
	{
		questions.add(question);
		question.setTable(this);
	}
	
	@Override
	@PrePersist
	public void onPrePersist()
	{
		if ( this.getUuid() == null )
			this.setUuid(UUID.randomUUID().toString());
		updateForm();
	}

	@PreUpdate
	@PreRemove
	@SuppressWarnings("unused")
	private void onUpdate() {
		//updateForm();
		this.onPrePersist();
	}

	private void updateForm() {
		BaseForm form = getForm();
		form.setLastUpdatedBy(form.getLockedBy());
	}
	
	/**
	 * Returns whether or not this refers to a Table Question
	 * @author Oawofolu
	 * @return
	 */
	public boolean isTableQuestion(){
		return true ;
	}


  public void removeExtraneousChildren(ChildrenRemovalType removalType)
	{
//		removeExtraneousAnswers(removalType);
		removeExtraneousSkipPatterns(removalType);
		//removeExtraneousCategories();
	}
/*
	private void removeExtraneousAnswers(ChildrenRemovalType removalType)
	{
		if (answers == null)
			return;
		// going in reverse, as most invalid answers are in the back
		ListIterator<Answer> iter = this.answers.listIterator(answers.size());
		while (iter.hasPrevious())
		{
			Answer a = iter.previous();
			if(
				(removalType == ChildrenRemovalType.EMPTY_CHILDREN && a.isEmpty()) ||
				(removalType == ChildrenRemovalType.INVALID_CHILDREN && ! a.isValid())
			  )
			{
				iter.remove();
			}
		}

	}

	public void setAnswerType( String answerType ){
		if ( answerType != null ) {
			AnswerType at = AnswerType.valueOf( answerType );
			setType( CollectionUtils.containsAny( Arrays.asList( at.getQuestionTypes() ),
					                 Arrays.asList( QuestionType.MULTI_ANSWER, QuestionType.MULTI_ANSWER_TABLE )) ?
					                 QuestionType.MULTI_ANSWER : QuestionType.SINGLE_ANSWER );
			for ( Answer answer : getAnswers() ) {
				answer.setType( at );
			}
		}
	}

	@SuppressWarnings("unused")
	@Deprecated
	private void removeExtraneousCategories() {
		if (categories == null || categories.isEmpty()) {
			return;
		}
		Iterator<Category> iter = this.categories.iterator();
		while (iter.hasNext()) {
			Category category = iter.next();
			if (!category.isValid()) {
				iter.remove();
			}
		}
	}

*/

	@Override
	public void prepareForPersist() {
		for(TableQuestion question: questions)
		{
			question.prepareForPersist();
		}
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

	@Override
	public void prepareForUpdate() {
		for(TableQuestion question: questions)
		{
			question.prepareForUpdate();
		}
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

	@Override
	public void prepareForDelete() {
		for(TableQuestion question: questions)
		{
			question.prepareForDelete();
		}
		removeExtraneousChildren(ChildrenRemovalType.INVALID_CHILDREN);
	}

	@Override
	public TableElement clone() {
		TableElement o = new TableElement();
		deepCopy(this, o);
		return o;
	}
	@Override
	public void resetId()
	{
		this.id = null;
		if(questions != null)
		{
			for (BaseQuestion question: questions)
			{
				question.resetId();
			}
		}
	}
	public static void copy(TableElement source, TableElement target)
	{
		FormElement.copy(source, target);
		target.setTableType(source.getTableType());
		
	}
	
	public static void deepCopy(TableElement source, TableElement target)
	{
		copy(source, target);
		for(BaseQuestion question: source.getQuestions())
		{
			TableQuestion newQuestion = ((TableQuestion)question).clone();
			target.addQuestion(newQuestion);
		}
		
	}


	/**
	 * Returns whether or not this question has any skips associated with it
	 */
//	public boolean hasSkips() {
//		return !getQuestionSkip().isEmpty();
//	}


	
	/**
	 * Returns the full list of questions whose visibility could possibly be affected
	 * when this question is hidden.
	 * This list will consist of:
	 * a) The list of skip affectees for this question,
	 * b) The list of skip affectees for each of the skip affectees in (a),
	 * c) The list of skip affectees for each of the skip affectees in (b), etc.
	 * @author Oawofolu
	 */
	/*
	public Set<QuestionTable> getAllPossibleSkipAffectees() {
		
		return getAllPossibleSkipAffectees(this, null, new HashMap<QuestionTable,String>());
	}
	
	private Set<QuestionTable> getAllPossibleSkipAffectees(QuestionTable q, String parentId, Map<QuestionTable,String> tree) {

		tree.put( q, parentId );
		
		for ( BaseSkipPatternDetail affectee : q.getSkipAffectees() ) {
			
			Question skipOwner = affectee.getQuestion();			
			
			if ( skipOwner != null ) {				

				// Since we are not currently checking for circular dependencies in skips,
				// we must make sure we are only adding this question
				// if it has not already been added to the master list;
				// otherwise we will have an infinite loop
				
				boolean hasCircularDependency = tree.values().contains( skipOwner.getUuid() );
				if ( ! hasCircularDependency ) {
					
				//	getAllPossibleSkipAffectees( skipOwner, q.getUuid(), tree );
					
				}
				
			}
			
		}
		
		// return a Set in order to remove duplicates that may exist
		
		return tree.keySet();
		
	}

*/
	@Override
	public boolean isPureContent(){
		return false;
	}
	
	@Override
	public boolean isLink()
	{
		return false;
	}
	@Override
	public boolean isTable()
	{
		return true;
	}
	@Override
	public boolean isExternalQuestion()
	{
		return false;
	}
	@Override
	public boolean isSimpleQuestion() {
		return false;
	}

	public TableType getTableType() {
		return tableType;
	}

	public void setTableType(TableType tableType) {
		this.tableType = tableType;
	}

	public String getTableShortName() {
		return tableShortName;
	}

	public void setTableShortName(String tableShortName) {
		this.tableShortName = tableShortName;
	}
}
