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
package com.healthcit.cacure.businessdelegates;


import gov.nih.nci.cadsr.domain.DataElement;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.UUID;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.businessdelegates.beans.SkipAffecteesBean;
import com.healthcit.cacure.cadsr.CADSRManager;
import com.healthcit.cacure.dao.AnswerDao;
import com.healthcit.cacure.dao.ContentElementDao;
import com.healthcit.cacure.dao.ExternalQuestionElementDao;
import com.healthcit.cacure.dao.FormElementDao;
import com.healthcit.cacure.dao.LinkElementDao;
import com.healthcit.cacure.dao.QuestionDao;
import com.healthcit.cacure.dao.QuestionElementDao;
import com.healthcit.cacure.dao.QuestionTableDao;
import com.healthcit.cacure.dao.SkipPatternDao;
import com.healthcit.cacure.dao.TableElementDao;
import com.healthcit.cacure.enums.ItemOrderingAction;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerSkipRule;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.BaseSkipPatternDetail;
import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.Description;
import com.healthcit.cacure.model.ExternalQuestion;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.QuestionSkipRule;
import com.healthcit.cacure.model.TableColumn;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.web.FormElementSearchCriteria;


public class QuestionAnswerManager {
	private static final Logger logger = Logger.getLogger(QuestionAnswerManager.class);
	private static String SPLITTER = ",";

	@Autowired
	QuestionDao qstDao;
	@Autowired
	QuestionTableDao tqDao;
	@Autowired
	AnswerDao answerDao;
	@Autowired
	SkipPatternDao skipDao;
	@Autowired
	FormManager formManager;
	@Autowired
	QuestionElementDao qeDao;
	@Autowired
	TableElementDao teDao;
	@Autowired
	ExternalQuestionElementDao eqeDao;
	@Autowired
	ContentElementDao cDao;
	@Autowired
	LinkElementDao linkDao;
	@Autowired
	FormElementDao formElementDao;
	@Autowired
	CADSRManager cadsrManager;
	
	@Transactional
	public FormElement updateFormElement( FormElement fe) {
		if(!fe.getForm().isEditable()) {
			throw new UnauthorizedException("A locked form and its entities can be edited only by the user who has locked the form");
		}
		
		//Commented since we don't have possibility to edit such question from UI
		/*if (fe.getForm().isLibraryForm() && isLinked(fe))
		{
			throw new UnauthorizedException("This FormElement belongs to the library and cannot be modified");
		}*/
		//prepare question entity for being updated
		fe.prepareForUpdate();
		// update all links associated with this FormElement, as appropriate
		// (NOTE: This method must be invoked BEFORE the actual updates to the FormElement are executed,
		// since we need to be able to access the pre-update values)
		updateAssociatedLinks(fe);
		
		FormElement mergedElement = null;
		/* If Links are edited then we need to break the link and do a deep copy of the parent element
		 *  with newly generated UUIDs all the way down
		 */
		if (fe instanceof LinkElement)
		{
			//create new FormElement
			//remove linkElement
			LinkElement link = (LinkElement)fe;
			String sourceUuid = link.getSourceId();
			FormElement source = linkDao.getLinkSource(sourceUuid);
			FormElement clone = source.clone();
			mergedElement = createFormElement(clone);
			linkDao.delete(link);
			
		}
		else
		{	
			formElementDao.update(fe);
			if (fe instanceof QuestionElement) 
			{
				QuestionElement questionElement = (QuestionElement) fe;
				this.answerDao.removeNotActualQuestionAnswers(questionElement
						.getQuestion().getId(), questionElement.getQuestion()
						.getAnswer().getId());
			}
			mergedElement = fe;
		}
		skipDao.skipPatternCleanup();
		
//		processLinkedFormElements(fe);
		return mergedElement;
	}
	
	private boolean isLinked(FormElement fe)
	{
		/*List<LinkElement> links = linkDao.getLinkedFormElements(fe);
		boolean isLinked = false;
		if(links != null && links.size()>0)
		{
			isLinked = true;
		}*/
		boolean isLinked = false;
		int linkCount = fe.getLinkCount();
		if(linkCount>0)
		{
			isLinked = true;
		}
		return isLinked;
//		return this.linkDao.hasLinkedFormElements(fe);
	}
	public FormElement createFormElement(FormElement fe)
	{
		FormElement mergedElement = null;
		formElementDao.create(fe);
		return mergedElement;
	}

	@Transactional
	public void deleteFormElementByID(Long id) {
		FormElement fe = formElementDao.getById(id);
		if (fe.getForm().getModule().isLibrary() && isLinked(fe))
		{
			throw new UnauthorizedException("This FormElement belongs to the library and cannot be modified");
		}
		deleteFormElement(fe);
	}
	
	private void deleteFormElement( FormElement e ) {
		//prepare question entity for being deleted
		if(!e.getForm().isEditable()) {
			throw new UnauthorizedException("A locked form and its entities can be modified only by the user who has locked the form");
		}
		if (e.getForm().getModule().isLibrary() && isLinked(e))
		{
			throw new UnauthorizedException("This FormElement belongs to the library and cannot be modified");
		}
		
		/* Check if Element has links if there are no links pointing t it, delete it */
		if (hasLinks(e))
		{
			throw new UnauthorizedException("the Form Element has links and cannot be deleted.");
		}
		e.prepareForDelete();
//		feDao.deleteLinks(e);
		formElementDao.delete(e);
		skipDao.skipPatternCleanup();
	}
	
	public boolean hasLinks(FormElement element)
	{
		boolean hasLinks = false;
		List<LinkElement> links = linkDao.getLinkedFormElements(element);
		if (links != null && links.size() >0)
		{
			hasLinks = true;
		}
		return hasLinks;
	}
	
	public boolean isSkip(Long questionId){

		if(skipDao.isSkip(questionId)){
				return true;
		}
		return false;
	}
	
	public Set<String> getSkipsUuidsFrom(Set<String> uuids){
		return skipDao.getSkipsUuidsFrom(uuids);
	}

	public boolean isAnswerValueSkip(String permAnswerValueId, Long formId){

		if(skipDao.isAnswerValueSkip(permAnswerValueId, formId)){
				return true;
		}
		return false;
	}

	public boolean isAnswerValueSkipTableRow(Long answerId){

		if(skipDao.isAnswerValueSkipTableRow(answerId)){
				return true;
		}
		return false;
	}

	public Map<String, String> getQuestionIdbyAnswerValueId(String answerValueId){
		return skipDao.getQuestionIdbyAnswerValueId(answerValueId);
	}

	@Deprecated
	public void deleteAnswerValueSkip(String  permAnswerValueId) {

		skipDao.deleteAnswerValueSkip(permAnswerValueId);
	}

	public List<BaseQuestion> getAllFormQuestions(Long formId) {
		return qstDao.getAllFormQuestions(formId);
	}
/*
	public Question getQuestion(Long id) {
		return qstDao.getById(id);
	}
	*/
	
	public FormElement getFormElement(Long id)
	{
		FormElement formElement = formElementDao.getById(id);
		return formElement;
	}
	
	public FormElement getFormElement(String uuid)
	{
		FormElement formElement = formElementDao.getByUUID(uuid);
		return formElement;
	}
	
	public ContentElement getContentElement(Long id)
	{
		return cDao.getById(id);
	}
	
	public QuestionElement getQuestionElement(Long id)
	{
		return qeDao.getById(id);
	}
	public TableElement getTableElement(Long id)
	{
		return teDao.getById(id);
	}
	public ExternalQuestionElement getExternalQuestionElement(Long id)
	{
		return eqeDao.getById(id);
	}

	/**
	 * changes the order in list between two consecutive items.
	 * <b>questionId</b> is id of target item.
	 * @param questionId Long
	 * @param ordType ItemOrderingAction
	 */
	
	public void moveFormElementInForm(Long elementId, ItemOrderingAction ordType) {
		//get pair of items to be changed between themselves
		List<FormElement> list = formElementDao.getAdjacentPairOfFormElements(elementId, ordType);
		// if single form returned - no need to move
		if (list.size() == 2) {

			FormElement element0 = list.get(0); //target item
			FormElement element1 = list.get(1); //item to be replaced with
			if(!element0.getForm().isEditable()) {
				throw new UnauthorizedException("A locked form and its entities can be modified only by the user who has locked the form");
			}
			//change the order between items
			Integer ord0 = element0.getOrd();
			Integer ord1 = element1.getOrd();

			// first must use invalid order to work around unique constraint
			// it works because save method has it's own transaction
			// it's important to update question1, not question0!
			element1.setOrd(-1);
			saveFormElement(element1);

			// modify ord to an actual value
			element0.setOrd(ord1);
			element1.setOrd(ord0);

			//persist changes - the order is important here!
			saveFormElement(element0);
			saveFormElement(element1);
		}

	}

	@Transactional
	public void saveFormElement(FormElement fe)
	{
		formElementDao.save(fe);
	}
	/**
	 * @param formId Long
	 * @return List<Question> ordered by ord that fetches list of answers
	 */
	public List<FormElement> getAllFormElements(Long formId) {
		return qeDao.getAllFormElements(formId);
	}

	public List<FormElement> getFormElementsByTextWithinCategories(long formId, String q, long... categoryIds) {
		if(StringUtils.isBlank(q)
				&& (categoryIds == null || categoryIds.length == 0)) {
			return qeDao.getAllFormElements(formId);
		}
		return qeDao.getFormElementsByTextWithinCategories(formId, q, categoryIds);
	}
	
	public List<FormElement> searchFormElements( int searchCriteria, String searchText, Long categoryId )
	{
		FormElementSearchCriteria criteria = new FormElementSearchCriteria( searchCriteria, searchText, categoryId );
		return getFormElementBySearchCriteria( criteria );
	}


	public List<FormElement> getFormElementsByUuid(Set<String> uuids) {
		return qeDao.getFormElementsByUuid(uuids);
	}
	
	/**
	 * @param criteria String
	 * @return List<Question>
	 */
	public List<FormElement> getFormElementBySearchCriteria(FormElementSearchCriteria criteria) {
		List<FormElement> list = null;
		switch (criteria.getSearchType()) {
		case FormElementSearchCriteria.SEARCH_BY_TEXT :
		  list = qeDao.getFormElementsByText(criteria.getSearchText());
			break;
		case FormElementSearchCriteria.SEARCH_BY_CATEGORY :
			list = qeDao.getQuestionLibraryFormElementsByCategory(criteria.getCategoryId());
			break;
		case FormElementSearchCriteria.SEARCH_BY_TEXT_WITHIN_CATEGORY:
			list = qeDao.getQuestionLibraryFormElementsByTextWithinCategories(criteria.getSearchText(), criteria.getCategoryId());
			break;
		case FormElementSearchCriteria.SEARCH_BY_CADSR_TEXT:
			logger.debug( "CADSR Search by text...");
			list = showCADSRFormElementSearchResults(criteria);
			break;
		case FormElementSearchCriteria.SEARCH_BY_CADSR_CART_USER:
			logger.debug( "CADSR Search by Cart User..." );
			list = showCADSRFormElementSearchResults(criteria);
			break;
		}
		return list;
	}

	/**
	 * @param questionId Long
	 * @return Question
	 */
	public BaseQuestion getQuestionFetchesChildren(Long questionId) {
		return qstDao.getQuestionFetchesChildren(questionId);
	}


	public FormElement getFormElementFetchesChildrenByUuid(String uuid) {
		return qeDao.getFormElementFetchesChildrenByUuid(uuid);
	}
	/**
	 * @param formId Long
	 * @param uuid String
	 * @return true if question exists in form
	 */
	public boolean isQuestionAlreadyExistsInForm(Long formId, String uuid) {
		return qstDao.isQuestionAlreadyExistsInForm(formId, uuid);
	}

	/**
	 * @param formId Long
	 * @param questionId Long
	 * @return true if question exists in form
	 * NOTE: Currently using the question's UUID to identify whether the question exists in the form,
	 * instead of the primary key.
	 * See: isQuestionAlreadyExistsInForm(Long formId, String uuid).
	 */
	@Deprecated
	public boolean isQuestionAlreadyExistsInForm(Long formId, Long questionId) {
		return qstDao.isQuestionAlreadyExistsInForm(formId, questionId);
	}

	/**
	 * Adding a Question entity.
	 * @param q Question
	 * @param formId Long
	 * @return Question
	 */
	@Transactional
	public Question addNewQestion(Question q, Long qElementId) {
		QuestionElement qElement = qeDao.getById(qElementId);
		q.setQuestionElement(qElement);
		//prepare question entity for being persisted
		q.prepareForPersist();
		qstDao.create(q);
		return q;
	}
	
	@Transactional
	public TableQuestion addNewTableQestion(TableQuestion q, Long qElementId) {
		TableElement qElement = teDao.getById(qElementId);
		q.setTable(qElement);
		//prepare question entity for being persisted
		q.prepareForPersist();
		tqDao.create(q);
		return q;
	}
	
	
	private FormElement _addNewFormElement(FormElement fe, Long formId)
	{
		//This is used when linkElement is editied, the newly created formElement should inherit the 
		// order from the LinkElement rather than creating the new one.
		Integer ord = fe.getOrd();
		if (ord == null)
		{
			ord = qeDao.calculateNextOrdNumber(formId);
		if (ord == null) {
			ord = 1;
		}
	}
		
		BaseForm form = formManager.getForm(formId);
		form.addElement(fe);
		//prepare question entity for being persisted
		fe.prepareForPersist();
		//calculate and set Ord Number for question

		fe.setOrd(ord);
		if(fe instanceof QuestionElement)
		{
			qeDao.create((QuestionElement)fe);
		}
		else if(fe instanceof ContentElement)
		{
			cDao.create((ContentElement)fe);
		}
		else if (fe instanceof TableElement)
		{
			teDao.create((TableElement)fe);
		}
		else if (fe instanceof ExternalQuestionElement)
		{
			eqeDao.create((ExternalQuestionElement)fe);
		}
		else if (fe instanceof LinkElement) {
			linkDao.create((LinkElement)fe);
		}
		return fe;
	}
	
	@Transactional
	public FormElement addNewFormElement(FormElement fe, Long formId) {
		//taken out into a separate method in order to be able to call it as part of other transaction
		fe = _addNewFormElement(fe, formId);
		return fe;
	}

	@Transactional
	public void importFormElements(Long formId, String[][] elementSet, int searchCriteria) {
		logger.debug( "In import FormElements method" );
		if ( elementSet == null ) elementSet = new String[][]{};
		List<FormElement> newElements = buildNewQuestions( elementSet, searchCriteria );

		for ( int i = 0; i < newElements.size(); ++i ) {
			FormElement newElement = newElements.get( i );
			@SuppressWarnings("unused")
			FormElement persistedQuestion = addNewFormElement(newElement, formId);
		}
	}
	
	@Transactional
	public List<FormElement> buildNewQuestions( String[][] questionSet, int searchCriteria ) {
		List<FormElement> newElements = new ArrayList<FormElement>();
		Map<String,DataElement> dataElements = new HashMap<String,DataElement>();
		int numElements = questionSet.length;
		String[] questionIdList =            new String[ numElements ];
		String[] answerTypeList =            new String[ numElements ];
		String[] deletedAnswerValuesList =   new String[ numElements ];
		for ( int i = 0; i < numElements; ++i )
		{
			questionIdList[i] = questionSet[i][0];
			answerTypeList[i] = questionSet[i][1];
			if ( questionSet[i].length > 2 )
				deletedAnswerValuesList[i] = questionSet[i][2];
		}

		for ( int i = 0; i < numElements; ++i ) {

			String uuid = questionIdList[ i ];

			// The following 2 variables are not used. I am leaving them in case the accessors are used 
			// to load lazy collections - LK
			String answerType = answerTypeList[ i ];
			HashSet<String> deletedAnswerValues = new HashSet<String>();
			if(StringUtils.isNotBlank(deletedAnswerValuesList[ i ])) {
				deletedAnswerValues.addAll(Arrays.asList(deletedAnswerValuesList[ i ].split("\\s*,\\s*")));
			}
			
			if ( searchCriteria == FormElementSearchCriteria.SEARCH_BY_CADSR_TEXT  // CADSR Text Search
			  || searchCriteria == FormElementSearchCriteria.SEARCH_BY_CADSR_CART_USER ) // CADSR Cart User Search
			{
				if ( i== 0 ) dataElements = cadsrManager.findCADSRQuestionsById( StringUtils.join( questionIdList, SPLITTER ) );
				DataElement dataElement = dataElements.get( uuid );
				if ( dataElement != null ) {
					FormElement newElement;
					AnswerType answerTypeEnumEntry = AnswerType.valueOf(answerType);
					newElement = cadsrManager.transformCADSRQuestion(dataElement, answerTypeEnumEntry, deletedAnswerValues);
					newElements.add( newElement );
				}
			}
			else // local
			{
				LinkElement linkElement = new LinkElement();
				FormElement source = linkDao.getLinkSource(uuid);
				linkElement.setLearnMore(source.getLearnMore());
				linkElement.setVisible(source.isVisible());
				linkElement.setRequired(source.isRequired());
				linkElement.setReadonly(source.isReadonly());
				linkElement.setDescription(source.getDescription());
				linkElement.setSource(source);
				newElements.add( linkElement );
			}
		}
		modifyShortNames(newElements);
		return newElements;
	}

	/**
	 * This method returns a list of (non-persisted) FormBuilder Question entities
	 * that correspond to the CADSR Question elements that match the search criteria
	 * provided in the given string.
	 * @author Oawofolu
	 */
	public List<FormElement> showCADSRFormElementSearchResults( FormElementSearchCriteria searchCriteria )
	{
		List<?> originalList = CADSRManager.getSearchResults( searchCriteria.getSearchText(), searchCriteria.getSearchType() );
		List<FormElement> transformedList = new ArrayList<FormElement>();
		for ( Object obj : originalList )
		{
			gov.nih.nci.cadsr.domain.DataElement question = (gov.nih.nci.cadsr.domain.DataElement) obj;
			ExternalQuestionElement transformedQuestion = cadsrManager.transformCADSRQuestion( question );
			transformedList.add( transformedQuestion );
		}
		return transformedList;
	}

	public List<Long> getLinkedFormElementIds(String linkId) {
	  return linkDao.getLinkedFormElementIds(linkId);
	}
	
	public List<String> getLinkedFormElementDescriptions(String linkId) {
		if ( NumberUtils.isNumber(linkId)){
			FormElement formElement = formElementDao.getById(new Long(linkId));
			String uuid = formElement.isLink() ? (( LinkElement )formElement).getSourceId() : formElement.getUuid();
			return linkDao.getLinkedFormElementDescriptions(uuid);
		}
		else{
			return new ArrayList<String>();
		}
	}
	
	public Set<String> getLinkedFormElementUuids(Set<String> linkUuids) {
		return linkDao.getLinkedFormElementUuids(linkUuids);
	}

	public List<Long> getLinkedSkippedFormElementIds(String linkId) {
	  return linkDao.getLinkedSkippedFormElementIds(linkId);
	}

	public List<Long> getLinkedReadOnlyFormElementIds(String linkId) {
	  return linkDao.getLinkedReadOnlyFormElementIds(linkId);
	}

  public void reorderTableQuestions(Long sourceQuestionId, Long targetQuestionId, boolean before) {
	TableQuestion question = getTableQuestion(targetQuestionId);
	if(!formManager.isEditableInCurrentContext(question.getParent().getForm())) {
		// The UI should never get the user here
		throw new UnauthorizedException(
				"The QuestionnaireForm is not editable in the current context");
	}
    tqDao.reorderQuestions(sourceQuestionId, targetQuestionId, before);
  }
  
  public void reorderFormElements(Long sourceElementId, Long targetElementId, boolean before) {
	 FormElement formElement = this.formElementDao.getById(targetElementId);
	 if(!formManager.isEditableInCurrentContext(formElement.getForm())) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The QuestionnaireForm is not editable in the current context");
		}
	    formElementDao.reorderFormElements(sourceElementId, targetElementId, before);
	  }
  
  public TableQuestion getTableQuestion(Long questionId)
  {
	  return tqDao.getById(questionId);
  }
  @Transactional
  public void deleteLink(Long id)
  {
	  linkDao.delete(id);
  }
  
  public SkipAffecteesBean getAllPossibleSkipAffectees(final BaseForm form) {
	  SkipAffecteesBean affecteesBean = new SkipAffecteesBean();
	  getAllPossibleSkipAffectees(affecteesBean, form);
	  return affecteesBean;
  }
  
  public SkipAffecteesBean getAllPossibleSkipAffectees(final FormElement element) {
	  SkipAffecteesBean affecteesBean = new SkipAffecteesBean();
	  getAllPossibleSkipAffectees(affecteesBean, element);
	  return affecteesBean;
  }
  
  protected void getAllPossibleSkipAffectees(final SkipAffecteesBean affecteesBean, final BaseForm form) {
	  affecteesBean.add(form);
	  List<FormElement> elements = form.getElements();
	  for (FormElement element : elements) {
		  getAllPossibleSkipAffectees(affecteesBean, element);
	  }
  }
  
  protected void getAllPossibleSkipAffectees(final SkipAffecteesBean affecteesBean, final FormElement element) {
	affecteesBean.add(element);
	if(element.getQuestions() == null) {
		return;
	}
	for(BaseQuestion question: element.getQuestions())
	{
		for ( BaseSkipPatternDetail affectee : question.getSkipAffectees() ) {
			
			Long affectedElementId = affectee.getFormElementId();
			Long affectedFormId = affectee.getFormId();
			
			if ( affectedElementId != null ) {				
				FormElement affectedElement = formElementDao.getById(affectedElementId);
				// Since we are not currently checking for circular dependencies in skips,
				// we must make sure we are only adding this question
				// if it has not already been added to the master list;
				// otherwise we will have an infinite loop
				boolean hasCircularDependency = affecteesBean.getFormElements().contains( affectedElement );
				if ( !hasCircularDependency ) {
					getAllPossibleSkipAffectees(affecteesBean, affectedElement);
				}
			} else if(affectedFormId != null) {
				BaseForm affectedForm = formManager.getForm(affectedFormId);
				boolean hasCircularDependency = affecteesBean.getForms().contains( affectedForm );
				if ( !hasCircularDependency ) {
					getAllPossibleSkipAffectees(affecteesBean, affectedForm);
				}
			}
		}
	}
  }

	@Transactional
	public void unlink(FormElement fe, Long linkId, Long formId) {
		LinkElement link = (LinkElement) formElementDao.getById(linkId);
		FormElement source = link.getSourceElement();
		updateSkips(fe, formId, source);
	
		Set<Category> categories = new LinkedHashSet<Category>(source.getCategories());
		fe.setCategories(categories);
	
		// The new formelement will have its own separate list of descriptions
		Set<Description> descriptionList = new LinkedHashSet<Description>(fe.getDescriptionList());
		for (Description description : descriptionList)
			description.setId(null);
	
		if (fe instanceof TableElement) {
			TableElement tableElement = (TableElement) fe;
			tableElement.setTableColumns(new ArrayList<TableColumn>());
			TableQuestion identifyingQuestion = tableElement
					.getIdentifyingQuestion();
			if (identifyingQuestion != null) {
				identifyingQuestion.setShortName("identifyingRowShortName-"
						+ UUID.randomUUID().toString());
			}
		}
		fe.resetId();
		_addNewFormElement(fe, formId);
		deleteLink(linkId);
		// update the new FormElement with the new description list
		updateDescriptionList(fe, descriptionList);
		skipDao.skipPatternCleanup();
	}
	
	public void updateSkips(FormElement newFormElement, Long newFormElementFormId, FormElement copiedFromFormElement) {
		Map<String, String> uuidMap = regenerateAnswerValuesPermanentIds(newFormElement);
		updateAnswerValuesPermanentIds(newFormElementFormId, copiedFromFormElement, uuidMap);
	}

	public void updateAnswerValuesPermanentIds(Long newFormElementFormId, FormElement formElement, Map<String, String> uuidMap) {
		
		List<? extends BaseQuestion> sourceQuestions = formElement.getQuestions();
		
		/* Update skips with new permanentId of the answer and new formId */
		for(BaseQuestion question: sourceQuestions)
		{
			Set<BaseSkipPatternDetail> skipAffectees = question.getSkipAffectees();
			for(BaseSkipPatternDetail detail: skipAffectees)
			{
				//BaseSkipPattern skip = detail.getSkip();
				if(detail.getFormElementId() != null) {
					FormElement skipOwner = formElementDao.getById(detail.getFormElementId());
					if(skipOwner.getForm().getId().equals(newFormElementFormId)) {
						QuestionSkipRule skip = detail.getSkip();
						if(skip.getIdentifyingAnswerValueUuId() != null) {
							String newUuid = uuidMap.get(skip.getIdentifyingAnswerValueUuId());
							skip.setIdentifyingAnswerValueUuId(newUuid);
						}
						List<AnswerSkipRule> parts = skip.getSkipParts();
						for (AnswerSkipRule part: parts)
						{
							String newUuid = uuidMap.get(part.getAnswerValueId());
							if (newUuid != null && part.getFormId().equals(newFormElementFormId))
							{
								part.setAnswerValueId(newUuid);
							}
						}
					}
				}
			}
		}
	}

	public Map<String, String> regenerateAnswerValuesPermanentIds(FormElement newFormElement) {
		Map<String, String> uuidMap = new HashMap<String, String>();
		List<?extends BaseQuestion> questions = newFormElement.getQuestions();
		if(questions != null) {
			for (BaseQuestion question: questions)
			{
				question.setId(null);
				question.setUuid(UUID.randomUUID().toString());
				question.setSkipAffectees(new LinkedHashSet<BaseSkipPatternDetail>());
				List<AnswerValue> answerValues = question.getAnswer().getAnswerValues();
				//replace permanentId to the new one
				for(AnswerValue answerValue: answerValues) {
					if(StringUtils.isNotBlank(answerValue.getPermanentId())) {
						String newUuid = UUID.randomUUID().toString();
						uuidMap.put(answerValue.getPermanentId(), newUuid);
						answerValue.setPermanentId(newUuid);
					}
				}
				
			}
		}
		return uuidMap;
	}
	
	@Transactional
	public void updateLink(FormElement fe) {
		LinkElement linkElement = (LinkElement)getFormElement(fe.getId());
		prepareLinkSourceForUpdateLink(linkElement.getSourceElement(), fe);
		linkElement.setLearnMore(fe.getLearnMore());
		linkElement.setRequired(fe.isRequired());
		linkElement.setVisible(fe.isVisible());
		linkElement.setReadonly(fe.isReadonly());
		linkElement.setDescription(fe.getDescription());		
		if(linkElement.getSkipRule() != null)
			skipDao.delete(linkElement.getSkipRule());
		linkElement.setSkipRule(fe.getSkipRule());
		linkDao.update(linkElement);
		skipDao.skipPatternCleanup();
	}
	
	@Transactional
	public void updateSourceCategories(long linkId, Set<Category> categories) {
		LinkElement linkElement = (LinkElement)getFormElement(linkId);
		FormElement sourceElement = linkElement.getSourceElement();
		sourceElement.setCategories(categories);
		formElementDao.save(sourceElement);
	}
	
	/**
	 * Makes any necessary updates to a LinkElement's source element before making updates to the link.
	 * 
	 * (NOTE: These updates to the link source 
	 * are NOT to be applied when a LinkElement is being unlinked, 
	 * because the source element will be detached from the link.)
	 * @param sourceElement
	 * @param targetElement
	 */
	@Transactional
	public void prepareLinkSourceForUpdateLink(FormElement sourceElement,FormElement targetElement) {
		//update the list of descriptions in the source element before updating the link
		updateDescriptionList(sourceElement,targetElement.getDescriptionList());	

		
		// Whenever a LinkElement is being updated,
		// updates to the "main" description from the "descriptionList" collection
		// need to be manually propagated back to the source
		resetDescriptionInLinkSource(sourceElement,targetElement);
	}
	
	/**
	 * When necessary, updates to the "main" description from the "descriptionList" collection
		are manually propagated back to the source
	 * @param sourceElement
	 * @param description
	 */
	
	@Transactional
	public void resetDescriptionInLinkSource(FormElement linkSourceElement,FormElement targetElement) {
		if (wasMainDescriptionChangedInLink(linkSourceElement,targetElement.getDescriptionList())){
			linkSourceElement.setDescription( targetElement.getDescription() );
		}
	}
	
	public boolean wasMainDescriptionChangedInLink(FormElement linkSource,Set<Description> descriptionList){
		boolean changed = true;
		
		for ( Description description : descriptionList )
		{
			if ( StringUtils.equals( linkSource.getDescription(), description.getDescription()))
			{
				return (changed = false);
			}
		}
		
		return changed;
	}
	
	/**
	 * updates the list of descriptions in the source element before updating the link
	 * @param linkSourceElement
	 * @param descriptionList
	 */
	@Transactional
	public void updateDescriptionList(FormElement linkSourceElement,Set<Description> descriptionList) {
		Set<Description> oldDescriptionList = linkSourceElement.getDescriptionList();
		Set<Description> newDescriptionList = new LinkedHashSet<Description>();
		
		for ( Description description : descriptionList ) {			
			if ( description.isNew() ) // if the description had never been previously persisted, perform an insert
			{
				newDescriptionList.add( description );
			}
			else  // else perform an update
			{ 
				for ( Description originalDescription : oldDescriptionList ) {
					if ( description.getId().equals(originalDescription.getId())){
						
						originalDescription.setDescription( description.getDescription() );
						
						newDescriptionList.add( originalDescription );
					}
				}
			}
		}
		
		// persist the decription list changes to the DB
		linkSourceElement.setDescriptionList(newDescriptionList);
		formElementDao.save(linkSourceElement);
		
		
	}
	
	@Transactional
	public void updateAssociatedLinks(FormElement fe) {
		// 1. Update the description of all link elements associated with this FormElement, as appropriate
		// (When the description list is modified, any modified descriptions should also be propagated to the link elements as appropriate)
		formElementDao.updateAllFormElementsWithDescriptionChanged( fe );
		
		//2. .....ANY OTHER UPDATES......
	}
	
	public void skipsDeepCopy(FormElement from, FormElement to) {
		FormElementSkipRule feSkipRule = from.getSkipRule();
		if(feSkipRule == null) return;
		FormElementSkipRule _feSkipRule = feSkipRule.clone();
		List<QuestionSkipRule> qSkipRules = feSkipRule.getQuestionSkipRules();
		if(qSkipRules == null || qSkipRules.isEmpty()) return;
		for (QuestionSkipRule qSkipRule : qSkipRules) {
			QuestionSkipRule _qSkipRule = qSkipRule.clone();
			for (AnswerSkipRule aSkipRule : qSkipRule.getAnswerSkipRules()) {
				AnswerSkipRule _aSkipRule = aSkipRule.clone();
				_qSkipRule.addAnswerSkipRule(_aSkipRule);
			}
			_feSkipRule.addQuestionSkipRule(_qSkipRule);
		}
		to.setSkipRule(_feSkipRule);
		formElementDao.save(to);
	}
	public void moveSkips(FormElement from, FormElement to) {
		FormElementSkipRule feSkipRule = from.getSkipRule();
		if(feSkipRule == null) return;
		from.removeSkipRule();
		feSkipRule.setFormElement(to);
		to.setSkipRule(feSkipRule);
		formElementDao.save(from);
		formElementDao.save(to);
	}
	
	public FormElement getFantom(Long linkId) {
		LinkElement linkElement = (LinkElement) getFormElement(linkId);
		FormElement sElement = linkElement.getSourceElement();
		FormElement fElement = null;
		if(sElement instanceof QuestionElement)
		{
			fElement = new QuestionElement();
		}
		else if (sElement instanceof TableElement)
		{
//			TODO Improve
			TableElement tableElement = new TableElement();
			tableElement.setTableType(((TableElement) sElement).getTableType());
			List<TableColumn> tableColumns = ((TableElement) sElement).getTableColumns();
			ArrayList<TableColumn> clonedTableColumns = new ArrayList<TableColumn>();
			for (TableColumn tableColumn : tableColumns) {
				clonedTableColumns.add(tableColumn.clone());
			}
			tableElement.setTableColumns(clonedTableColumns);
			fElement = tableElement;
		}
		else if (sElement instanceof ExternalQuestionElement)
		{
			fElement = new ExternalQuestionElement();
		}
		else if  (sElement instanceof ContentElement)
		{
			fElement = new ContentElement();
		}
		FormElement.copy(sElement, fElement);
		fElement.setLearnMore(linkElement.getLearnMore());
		fElement.setVisible(linkElement.isVisible());
		fElement.setRequired(linkElement.isRequired());
		fElement.setReadonly(linkElement.isReadonly());
		fElement.setForm(linkElement.getForm());
		fElement.setUuid(linkElement.getUuid());
		fElement.setOrd(linkElement.getOrd());
		fElement.setDescription(linkElement.getDescription());
		if ( fElement instanceof TableElement ) 
		{
			((TableElement)fElement).setTableShortName(linkElement.getTableShortName());
		}
//		fElement.setSkipRule(linkElement.getSkipRule());
		FormElementSkipRule skipRule = linkElement.getSkipRule();
		if(skipRule != null) {
			FormElementSkipRule newSkipRule = skipRule.clone();
			
			List<QuestionSkipRule> skips = skipRule.getQuestionSkipRules();
			//List<FormElementSkip> clonedSkips = new ArrayList<FormElementSkip>();
			for(QuestionSkipRule skip: skips)
			{
				QuestionSkipRule clonedSkip = skip.clone();
				clonedSkip.setDetails(skip.getDetails());
				clonedSkip.setIdentifyingAnswerValue(skip.getIdentifyingAnswerValue());
				List<AnswerSkipRule> answerSkipRules = skip.getAnswerSkipRules();
				for (AnswerSkipRule answerSkipRule : answerSkipRules) {
					AnswerSkipRule _answerSkipRule = answerSkipRule.clone();
					_answerSkipRule.setAnswerValue(answerSkipRule.getAnswerValue());
					clonedSkip.addAnswerSkipRule(_answerSkipRule);
				}
//				skip.getDetails().getSkipTriggerQuestion().getId();
				newSkipRule.addQuestionSkipRule(clonedSkip);
			}
			fElement.setSkipRule(newSkipRule);
		}
		
		/* preserve answerValue permanent_ids in order for skips to work. 
		 * if clone() method is used instead than it is not possible to match source answerValues to copied ones without the permanentId on the target
		 * */
		
		List<? extends BaseQuestion> sourceQuestions = sElement.getQuestions();
		if (sourceQuestions != null && sourceQuestions.size() >0)
		{
			for(BaseQuestion question: sourceQuestions)
			{
				BaseQuestion newQuestion = question.copy();
				newQuestion.setSkipAffectees(question.getSkipAffectees());
				newQuestion.setId(question.getId());
				newQuestion.setUuid(question.getUuid());
				Answer answer = question.getAnswer();
				Answer newAnswer = answer.copy();
				newAnswer.setUuid(answer.getUuid());
				List<AnswerValue> answerValues = question.getAnswer().getAnswerValues();
				newQuestion.setAnswer(newAnswer);
				for(AnswerValue answerValue: answerValues)
				{
					AnswerValue newAnswerValue = answerValue.clone();
					//This is done to preserve the skips that might depend on this linkElement
					newAnswerValue.setPermanentId(answerValue.getPermanentId());
					newAnswer.addAnswerValues(newAnswerValue);
				}
				if(sElement instanceof QuestionElement)
				{
					((QuestionElement)fElement).setQuestion((Question)newQuestion);
				}
				else if (sElement instanceof TableElement)
				{
					((TableElement)fElement).addQuestion((TableQuestion)newQuestion);
				}
				else if (sElement instanceof ExternalQuestionElement)
				{
					((ExternalQuestionElement)fElement).setQuestion((ExternalQuestion)newQuestion);
				}
			}
			
		}
		return fElement;
	}

	public void modifyShortNames(List<FormElement> newElements) {
		//Make unique among this collection		
		HashMap<String, Object> shortNamesMap = new HashMap<String, Object>();
		for (FormElement formElement : newElements) {
			if(formElement instanceof TableElement) {
				TableElement tableElement = (TableElement) formElement;
				String tableShortName = com.healthcit.cacure.utils.StringUtils.prepareForShortName(tableElement.getTableShortName());
				if(StringUtils.isBlank(tableShortName)) {
					tableShortName = "tableShortName";
				}
				if(shortNamesMap.containsKey(tableShortName)) {
					int counter = 1;
					while(shortNamesMap.containsKey(tableShortName + counter)) {
						counter += 1;
					}
					shortNamesMap.put(tableShortName + counter, tableElement);
				} else {
					shortNamesMap.put(tableShortName, tableElement);
				}
			}
			
			List<? extends BaseQuestion> questions = formElement.getQuestions();
			if(questions != null) {
				for (BaseQuestion baseQuestion : questions) {
					String shortName = com.healthcit.cacure.utils.StringUtils.prepareForShortName(baseQuestion.getShortName());
					if(StringUtils.isBlank(shortName)) {
						shortName = "tableShortName";
					}
					if(shortNamesMap.containsKey(shortName)) {
						int counter = 1;
						while(shortNamesMap.containsKey(shortName + counter)) {
							counter += 1;
						}
						shortNamesMap.put(shortName + counter, baseQuestion);
					} else {
						shortNamesMap.put(shortName, baseQuestion);
					}
				}
			}
		}
		if(shortNamesMap.isEmpty()) {
			return;
		}
		//Check similar short names in DB		
		Set<String> similarShortNamesInDb = qstDao.getQuestionsShortNamesLike(shortNamesMap.keySet(), false);
		similarShortNamesInDb.addAll(teDao.getTableShortNamesLike(shortNamesMap.keySet(), false));
		
		for (Entry<String, Object> entry : shortNamesMap.entrySet()) {
			String shortName = entry.getKey();
			if(similarShortNamesInDb.contains(shortName)) {
				int counter = 1;
				while(similarShortNamesInDb.contains(shortName + counter)) {
					counter += 1;
				}
				shortName = shortName + counter;
			}
			if(entry.getValue() instanceof BaseQuestion) {
				((BaseQuestion)entry.getValue()).setShortName(shortName);
			} else if(entry.getValue() instanceof TableElement) {
				((TableElement)entry.getValue()).setTableShortName(shortName);
			}
		}
	}

	private List<String> collectAllShortNames(FormElement formElement) {
		ArrayList<String> shortNamesList = new ArrayList<String>();
		if(formElement instanceof TableElement) {
			TableElement tableElement = (TableElement) formElement;
			if(tableElement.getTableShortName() != null) {
				shortNamesList.add(tableElement.getTableShortName());
			}
		}
		
		List<? extends BaseQuestion> questions = formElement.getQuestions();
		for (BaseQuestion baseQuestion : questions) {
			if(baseQuestion.getShortName() != null) {
				shortNamesList.add(baseQuestion.getShortName());
			}
		}
		return shortNamesList;
	}
	
	public DuplicateResultBean hasShortNameDuplicates(FormElement formElement) {
		List<String> collectedShortNames = collectAllShortNames(formElement);
		return hasShortNameDuplicates(collectedShortNames);
	}

	public DuplicateResultBean hasShortNameDuplicates(List<String> collectedShortNames) {
		HashSet<String> uniqShortnamesSet = new HashSet<String>(collectedShortNames);
		HashSet<String> duplShortnamesSet = new HashSet<String>();
		if(uniqShortnamesSet.size() != collectedShortNames.size()) {
			for (String uniqSn : uniqShortnamesSet) {
				collectedShortNames.remove(uniqSn);
			}
			duplShortnamesSet.addAll(collectedShortNames);
		}
		Set<String> exactQuestionsShortNames = qstDao.getQuestionsShortNamesLike(uniqShortnamesSet, true);
		duplShortnamesSet.addAll(exactQuestionsShortNames);
		Set<String> exactTableShortNames = teDao.getTableShortNamesLike(uniqShortnamesSet, true);
		duplShortnamesSet.addAll(exactTableShortNames);
		if(duplShortnamesSet.isEmpty()) {
			return new DuplicateResultBean(DuplicateResultType.OK, null);
		} else {
			return new DuplicateResultBean(DuplicateResultType.NOT_UNIQUE, duplShortnamesSet.toArray(new String[0]));
		}
	}
	
}
