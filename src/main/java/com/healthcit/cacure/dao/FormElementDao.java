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
package com.healthcit.cacure.dao;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.persistence.EntityManager;
import javax.persistence.FlushModeType;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.Validate;
import org.apache.log4j.Logger;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.enums.ItemOrderingAction;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.Description;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.FormElementSkipRule;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.Question;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.QuestionSkipRule;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.utils.CollectionUtils;

public class FormElementDao
{
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(FormElementDao.class);
	@PersistenceContext
	protected EntityManager em;

	
	public FormElement findFormElementById(Long id)
	{
		Query query = em.createQuery("from FormElement fe where id = :Id");
		query.setParameter("Id", id);
	    return (FormElement) query.getSingleResult();
	}

	/**
	 * @param formId Long
	 * @return List<Question> ordered by ord that fetches list of answers and skipPatterns
	 */
	@SuppressWarnings("unchecked")
	public List<FormElement> getAllFormElements(Long formId) {
		Query query = em.createQuery("select q from FormElement q left join fetch q.skipRule where q.form.id = :formId order by q.ord" );
		query.setHint("org.hibernate.cacheable", true);
		query.setParameter("formId", formId);
		
        List<FormElement> elements = (List<FormElement>) query.getResultList();

        // Notice empty statement in order to start each subselect
/*
        for (FormElement e : elements) {
        	if (e instanceof QuestionElement) 
        	{
        		((QuestionElement)e).getQuestion();
        	}
        	if (e instanceof ExternalQuestionElement) 
        	{
        		((ExternalQuestionElement)e).getQuestion();
        	}
        	else if (e instanceof TableElement)
        	{
        		for (@SuppressWarnings("unused") BaseQuestion question: ((TableElement)e).getQuestions())
        		{
        			break; // just to load it
        		}
        	}
        	FormElementSkipRule rule = e.getSkipRule();
        	if (rule != null)
        	{
        		for (@SuppressWarnings("unused") QuestionSkipRule sp: rule.getQuestionSkipRules())
        		{
        			break; // just to load it
        		}
        	}
        	//Why is there a break after the first question?
  //          break;
        }
*/
		return elements;
	}
	
	/**
	 * If the description list of a source element was changed,
	 * this ensures that the description(s) of its associated LinkElements is up-to-date.
	 */
	public void updateAllFormElementsWithDescriptionChanged(FormElement formElement) {
		Iterator<Description> newDescriptionIterator = formElement.getDescriptionList().iterator();
		
		while ( newDescriptionIterator.hasNext() )
		{
			Description newDescription = newDescriptionIterator.next();
			
			if ( ! newDescription.isNew() )
			{			
				Query query = em.createNativeQuery("update form_element set description = :desc from description d where form_element.link_id=:uuid and form_element.description = d.source_description_text and d.id = :id");
								
				query.setParameter("desc", newDescription.getDescription() );
				
				query.setParameter("uuid", formElement.isLink() && !formElement.isExternalQuestion() ? (( LinkElement )formElement).getSourceId() : formElement.getUuid() );
				
				query.setParameter("id", newDescription.getId() );
				
				query.setFlushMode(FlushModeType.COMMIT);
				
				query.executeUpdate();
			}
		}
	}
	
	public List<FormElement> getAllFormElementsWithChildrenChanged(Long formId) {
		List<FormElement> elements = new ArrayList<FormElement>();
		Query query1 = em.createQuery("select q from QuestionElement q left join fetch q.skipRule left join fetch q.question where q.form.id = :formId order by q.ord" );
		Query query2 = em.createQuery("select q from TableElement q left join q.questions left join q.columns left join fetch q.skipRule where q.form.id = :formId order by q.ord" );
		Query query3 = em.createQuery("select q from ContentElement q where q.form.id = :formId order by q.ord" );
		Query query4 = em.createQuery("select q from ExternalQuestionElement q left join q.question where q.form.id = :formId order by q.ord" );
		query1.setParameter("formId", formId);
		query2.setParameter("formId", formId);
		query3.setParameter("formId", formId);
		query4.setParameter("formId", formId);
        List<FormElement> elements1 = (List<FormElement>) query1.getResultList();
        List<FormElement> elements2 = (List<FormElement>) query2.getResultList();
        List<FormElement> elements3 = (List<FormElement>) query3.getResultList();
        List<FormElement> elements4 = (List<FormElement>) query4.getResultList();

        elements.addAll(elements1);
        elements.addAll(elements2);
        elements.addAll(elements3);
        elements.addAll(elements4);
        // Notice empty statement in order to start each subselect
/*        for (FormElement e : elements1) {
       		((QuestionElement)e).getQuestion().getAnswer().getAnswerValues();
       		
        	FormElementSkipRule rule = e.getSkipRule();
        	if (rule != null)
        	{
        		for (@SuppressWarnings("unused") QuestionSkipRule sp: rule.getQuestionSkipRules())
        		{
        			break; // just to load it
        		}
        	}
        }
        for (FormElement e : elements2) {
        	List<? extends BaseQuestion> qs  = ((TableElement)e).getQuestions();
        	for(BaseQuestion q: qs)
        	{
        		q.getAnswer().getAnswerValues();
        	}
     
        	FormElementSkipRule rule = e.getSkipRule();
        	if (rule != null)
        	{
        		for (@SuppressWarnings("unused") QuestionSkipRule sp: rule.getQuestionSkipRules())
        		{
        			break; // just to load it
        		}
        	}
        	//Why is there a break after the first question?
  //          break;
        }
        */
//        for (FormElement e : elements3) {
//        	if (e instanceof QuestionElement) 
//        	{
//        		((QuestionElement)e).getQuestion();
//        	}
//        	if (e instanceof ExternalQuestionElement) 
//        	{
//        		((ExternalQuestionElement)e).getQuestion();
//        	}
//        	else if (e instanceof TableElement)
//        	{
//        		for (@SuppressWarnings("unused") BaseQuestion question: ((TableElement)e).getQuestions())
//        		{
//        			break; // just to load it
//        		}
//        	}
//        	FormElementSkipRule rule = e.getSkipRule();
//        	if (rule != null)
//        	{
//        		for (@SuppressWarnings("unused") QuestionSkipRule sp: rule.getQuestionSkipRules())
//        		{
//        			break; // just to load it
//        		}
//        	}
//        	//Why is there a break after the first question?
//  //          break;
//        }
/*        for (FormElement e : elements4) {
        	((ExternalQuestionElement)e).getQuestion();
        	FormElementSkipRule rule = e.getSkipRule();
        	if (rule != null)
        	{
        		for (@SuppressWarnings("unused") QuestionSkipRule sp: rule.getQuestionSkipRules())
        		{
        			break; // just to load it
        		}
        	}
        	//Why is there a break after the first question?
  //          break;
        }
*/
		return elements;
	}

	/**
	 * @param categoryId Long
	 * @return List<Question>
	 */
	@SuppressWarnings("unchecked")
	public List<FormElement> getQuestionLibraryFormElementsByCategory(Long categoryId) {
		String jpql = "select distinct q from FormElement q "
				+ "inner join q.categories as c "
				+ "inner join q.form as f "
				+ "where c.id = :categoryId and (type(f) = QuestionLibraryForm) and (type(q) != LinkElement))"
//				+ "order by q.shortName";
				+ "order by q.description";
		Query query = em.createQuery(jpql);
		query.setParameter("categoryId", categoryId);
		List<FormElement> elements = (List<FormElement>) query.getResultList();
		return elements;
	}

	public List<FormElement> getQuestionLibraryFormElementsByTextWithinCategories(String q, long... categoryIds) {
		return getFormElementsByTextWithinCategories(null, q, categoryIds);
	}
	
	public List<FormElement> getFormElementsByTextWithinCategories(long formId, String q, long... categoryIds) {
		return getFormElementsByTextWithinCategories((Long)formId, q, categoryIds);
	}
	
	/**
	 * 
	 * @param formId - form to search in. When form is not defined question library form is used.
	 * @param q
	 * @param categoryIds
	 * @return
	 */
	@SuppressWarnings("unchecked")
	protected List<FormElement> getFormElementsByTextWithinCategories(Long formId, String q, long... categoryIds) {
		String sql = "SELECT fe.id" +
			" FROM form_element fe" +
			" INNER JOIN form f ON fe.form_id = f.id AND "+ (formId == null ? "f.form_type = 'questionLibraryForm'" : "f.id = " + formId);
		
		if(categoryIds != null && categoryIds.length > 0) {
			StringBuilder ids = new StringBuilder();
			for (int i = 0; i < categoryIds.length; i++) {
				ids.append(categoryIds[i]);
				if(i + 1 < categoryIds.length)
					ids.append(",");
			}
			sql +=
				" INNER JOIN question_categries cat ON cat.question_id = fe.id AND cat.category_id in (" + ids.toString() + ")";
		}
		
		if (StringUtils.isBlank(q)) {
			sql +=
				" ORDER BY fe.ord;";
		} else {
			String query = q.replaceAll("'", "''");
			sql +=
				" CROSS JOIN plainto_tsquery('ts_config', '" + query + "') query" +
				" WHERE fe.ts_data @@ query" +
				" ORDER BY ts_rank_cd(fe.ts_data, query) desc;";
		}
			
			Query nativeQuery = em.createNativeQuery(sql);
		List<BigInteger> result = nativeQuery.getResultList();
		List<Long> ids = CollectionUtils.convertAllElementsToLong(result);
		
		if(org.apache.commons.collections.CollectionUtils.isEmpty(ids)) {
			return new ArrayList<FormElement>();
			}
		
		Query selectElement = em.createQuery("from FormElement fe where id in (" + StringUtils.join(ids, ",") + ")");
		return selectElement.getResultList();
		}
	/**
	 * @param q String
	 * @param categoryId 
	 * @return List<Question>
	 */
	@SuppressWarnings("unchecked")
	public List<FormElement> getQuestionLibraryFormElementsByCategoryText(final String q) {
		Query query = em.createQuery("select distinct q from FormElement q "
				+ "inner join q.categories as c "
				+ "inner join q.form as f "
				+ "where (c.name like :q OR c.description like :q) and (type(f) = QuestionLibraryForm) and (type(q) != LinkElement) "
//				+ "order by q.shortName");
				+ "order by q.description");
		query.setParameter("q", "%" + q + "%");
		List<FormElement> elements = (List<FormElement>) query.getResultList();
		return elements;
	}

	/**
	 * <b>questionId</b> is id of target item.
	 * @param questionId Long
	 * @param ordType ItemOrderingAction
	 * @return pair of two consecutive Question items
	 */
	@SuppressWarnings("unchecked")
	public List<FormElement> getAdjacentPairOfFormElements(Long elementId, ItemOrderingAction ordType) {
		String sign = (ordType == ItemOrderingAction.UP ? "<=" : ">=");
		String orderBy = (ordType == ItemOrderingAction.UP ? "DESC" : "ASC");
		String jpql = "select otherQst from FormElement ordQst, FormElement otherQst "
				+ "where ordQst.id = :questionId "
				+ "and otherQst.form.id = ordQst.form.id "
				+ "and otherQst.ord " + sign + " ordQst.ord "
				+ "order by otherQst.ord " +  orderBy;

		Query query = em.createQuery(jpql);
		query.setParameter("questionId", elementId);
		query.setMaxResults(2);

		List<FormElement> elements = (List<FormElement>) query.getResultList();

        for (FormElement q : elements) {
        	getElementsChildren(q);
        }
        return query.getResultList();
	}
	
	private void getElementsChildren(FormElement q)
	{
		if(q instanceof TableElement)
	
		{
			for (BaseQuestion baseQuestion: ((TableElement) q).getQuestions())
			{
				TableQuestion question = (TableQuestion)baseQuestion;
				Answer answer = question.getAnswer();
				for (@SuppressWarnings("unused") AnswerValue av: answer.getAnswerValues())
				{
					break; // just to load it
				}
			}
		}
		else if(q instanceof QuestionElement)
		{
			Question question = ((QuestionElement)q).getQuestion();
			Answer answer = question.getAnswer();
			for (@SuppressWarnings("unused") AnswerValue av: answer.getAnswerValues())
			{
				break; // just to load it
			}
		}
		else if (q instanceof ExternalQuestionElement)
		{
			Question question = ((QuestionElement)q).getQuestion();
			Answer answer = question.getAnswer();
			for (@SuppressWarnings("unused") AnswerValue av: answer.getAnswerValues())
			{
				break; // just to load it
			}
		}
	
		FormElementSkipRule rule = q.getSkipRule();
		if(rule != null) {
			for (@SuppressWarnings("unused") QuestionSkipRule sp: rule.getQuestionSkipRules())
			{
				break; // just to load it
			}
		}
	}

	/**
	 * @return Next Ord Number in ordered entities.
	 */
	@Transactional(propagation = Propagation.SUPPORTS)
	public Integer calculateNextOrdNumber(Long formId) {
		String sql = "select max(ord +1) from form_element where form_id = :formId";
		Query query = em.createNativeQuery(sql);
		query.setParameter("formId", formId);
		BigInteger o = (BigInteger)query.getSingleResult();
		if (o == null)
		{
			o = BigInteger.valueOf(1l);
		}
		
		return o == null ? null : Integer.valueOf(o.intValue());
	}

	/**
	 * @param questionId Long
	 * @return Question
	 */
	public FormElement getFormElementFetchesChildren(Long questionId) {
		FormElement q = getById(questionId);
		getElementsChildren(q);
        return q;
	}

	/**
	 * @param questionId Long
	 * @return Question
	 */
	@SuppressWarnings("unchecked")
	public FormElement getFormElementFetchesChildrenByUuid(String uuid) {
		Query query = em.createQuery("from FormElement where uuid = :uuid");
	    query.setParameter("uuid", uuid);
	    List<FormElement> qList = query.getResultList();
	    if ( qList.size() == 0 ) return null;
		// Question q = getById(questionId);
	    FormElement q = qList.get( 0 );
	    getElementsChildren(q);
        return q;
	}
	
	public List<FormElement> getFormElementsByUuid(Set<String> uuids) {
		Query query = em.createQuery("from FormElement where uuid in (:uuids)");
		query.setParameter("uuids", uuids);
		return query.getResultList();
	}

	/**
	 * @param q
	 *            String
	 * @return List<Question>
	 */
	@SuppressWarnings("unchecked")
    public List<FormElement> getFormElementsByText(String q) {
    List<FormElement> elements = new ArrayList<FormElement>();
//	  List<Object> result = Collections.emptyList();
	  List<BigInteger> result = Collections.emptyList();

    if (StringUtils.isNotEmpty(q)) {
      String query = q.replaceAll("'", "''");
      Query nativeQuery = em.createNativeQuery("select q.id"
              + "   from form_element q, form f,  plainto_tsquery('ts_config', '"
              + query
              + "') query"
              + "   where q.form_id = f.id AND f.form_type = 'questionLibraryForm' AND q.ts_data @@ query"
              + "   order by ts_rank_cd(q.ts_data, query) desc");
       
      result = nativeQuery.getResultList();
 
      				Query selectElement = em.createQuery("from FormElement fe where id = :id");
      				for(BigInteger id: result)
      				{
      				    selectElement.setParameter("id", id.longValue());
      					elements.add((FormElement)selectElement.getSingleResult());
      				}
                	 
                 }
 

    return elements;
  }


  protected void reindexFormElementTextSearch(FormElement element) {
    if (!(element instanceof LinkElement)) {
      em.createNativeQuery("select refresh_question_ts_data(" + element.getId() + ")").getSingleResult();
    }
  }

  public void reindexFormElementTextSearch() {
    em.createNativeQuery("select refresh_question_ts_data()").getSingleResult();
  }

  @Transactional(propagation = Propagation.REQUIRED)
  public void reorderFormElements(Long sourceFormElementId, Long targetFormElementId, boolean before) {

    Validate.notNull(sourceFormElementId);
    Validate.notNull(targetFormElementId);

    if (sourceFormElementId.equals(targetFormElementId)) {
      return;
    }

    Query query = em.createQuery("SELECT ord, form.id FROM FormElement WHERE id = :id");

    Object[] result = (Object[]) query.setParameter("id", sourceFormElementId).getSingleResult();
    int sOrd = (Integer) result[0];
    long sFormId = (Long) result[1];

    result = (Object[]) query.setParameter("id", targetFormElementId).getSingleResult();
    int tOrd = (Integer) result[0];
    long tFormId = (Long) result[1];

    Validate.isTrue(sFormId == tFormId); //reorder only inside one form

    if (sOrd == tOrd || (before && sOrd == tOrd - 1) || ( !before && sOrd == tOrd + 1)) {
      return;
    } else if (sOrd < tOrd) {
      em.createQuery("UPDATE FormElement SET ord = ord - 1 WHERE ord > :sOrd and ord " + (before ? "<" : "<=") + " :tOrd and form.id = :formId")
        .setParameter("sOrd", sOrd)
        .setParameter("tOrd", tOrd)
        .setParameter("formId", sFormId)
        .executeUpdate();
      em.createQuery("UPDATE FormElement SET ord = :tOrd WHERE id = :qId")
        .setParameter("qId", sourceFormElementId)
        .setParameter("tOrd", before ? tOrd - 1 : tOrd)
        .executeUpdate();
    } else if (sOrd > tOrd) {
      em.createQuery("UPDATE FormElement SET ord = ord + 1 WHERE ord < :sOrd and ord " + (before ? ">=" : ">") + " :tOrd and form.id = :formId")
        .setParameter("sOrd", sOrd)
        .setParameter("tOrd", tOrd)
        .setParameter("formId", sFormId)
        .executeUpdate();
      em.createQuery("UPDATE FormElement SET ord = :tOrd WHERE id = :qId")
        .setParameter("qId", sourceFormElementId)
        .setParameter("tOrd", before ? tOrd : tOrd + 1)
        .executeUpdate();
    }
  }


	public void create(FormElement entity) {
		em.persist(entity);
		em.flush();
		reindexFormElementTextSearch(entity);
		//	  return entity;
	}
	
	public void update(FormElement entity) {
	    em.merge(entity);
	    em.flush();
	    reindexFormElementTextSearch(entity);
	//    return entity;
	}
	  
	public void save(FormElement entity) {
		if (entity.isNew())
			create(entity);
		else
			update(entity);
	}
	
	public void delete(FormElement entity) {
		em.remove(entity);
		em.flush();
	}

	public void delete(Long id)
	{
		 em.createQuery("DELETE FormElement fe WHERE fe.id = :Id")
	        .setParameter("Id", id)
	        .executeUpdate();
	}
	
	public FormElement getById(Long id)
	{
		Query query = em.createQuery("select fe from FormElement fe where id = :Id");
		query.setParameter("Id", id);
	    return (FormElement) query.getSingleResult();
	}
	
	public FormElement getByUUID(String uuid)
	{
		Query query = em.createQuery("select fe from FormElement fe where uuid = :Id");
		query.setParameter("Id", uuid);
		try
		{
			return (FormElement) query.getSingleResult();
		}
		catch(javax.persistence.NoResultException e)
		{
			return null;
		}
	}
	
}
