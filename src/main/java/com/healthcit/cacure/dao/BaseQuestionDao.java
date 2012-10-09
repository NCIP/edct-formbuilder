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
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.apache.commons.collections.CollectionUtils;
import org.apache.log4j.Logger;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.Question;


public abstract class BaseQuestionDao
{
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(BaseQuestionDao.class);
	
	@PersistenceContext
	protected EntityManager em;



	@SuppressWarnings("unchecked")
	public List<BaseQuestion> getAllFormQuestions(Long formId) {
	    Query query = em.createQuery("from Question q where form.id = :formId");
	    query.setParameter("formId", formId);
	    return (List<BaseQuestion>) query.getResultList();
	}

	public Set<String> getQuestionsShortNamesLike(Set<String> shortNames, boolean exact)
	{
		if(CollectionUtils.isEmpty(shortNames)) {
			return new HashSet<String>(0);
		}
		StringBuffer sb = new StringBuffer("select bq.shortName from BaseQuestion bq where  ");
		int num = 1;
		for (String shortName : shortNames) {
			sb.append("bq.shortName like ?");
			sb.append(num++);
			if(num <= shortNames.size()) {
				sb.append(" OR ");
			}
		}
		Query query = em.createQuery(sb.toString());
		num = 1;
		for (String shortName : shortNames) {
			query.setParameter(num++, shortName + (exact ? "" : "%"));
		}
		List<String> list = (List<String>) query.getResultList();
		return new TreeSet<String>(list);
	}
	
	/**
	 * @param formId Long
	 * @return List<Question> ordered by ord that fetches list of answers and skipPatterns
	 */
	@SuppressWarnings("unchecked")
	public List<BaseQuestion> getAllFormQuestionsWithChildren(Long formId) {
//		String jpql = "select distinct q from Question q "
//					//+ "fetch all properties " // THIS IS HIBERNATE SPECIFIC! That doesn't work in JPA!
//					+ "left join fetch q.answers a "
//					+ "left join fetch q.skipPatterns "
//					+ "where q.form.id = :formId "
//					+ "order by q.ord, a.ord";
//
//		Query query = em.createQuery(jpql);

		// the following code works with @Fetch(FetchMode.SUBSELECT) annotation to produce only
		// one subquery per collection, without producing Cartesian product as the multi-join above does
		//Query query = em.createQuery("select distinct q from Question q where q.form.id = :formId order by q.ord" );
		Query query = em.createQuery("select distinct q from BaseQuestion q where q.form.id = :formId order by q.ord" );
		query.setParameter("formId", formId);
        List<BaseQuestion> questions = (List<BaseQuestion>) query.getResultList();

        // Notice empty statement in order to start each subselect
        for (BaseQuestion q : questions) {
        	q.getAnswer();
        }

		return questions;
	}

	/**
	 * @param categoryId Long
	 * @return List<Question>
	 */
/*	@SuppressWarnings("unchecked")
	public List<BaseQuestion> getQuestionsByCategory(Long categoryId) {
		String jpql = "select distinct q from BaseQuestion q "
				+ "inner join q.categories as c "
				+ "where c.id = :categoryId and (q.linkId is null and q.linkSource is null)"
				+ "order by q.shortName";
		Query query = em.createQuery(jpql);
		query.setParameter("categoryId", categoryId);
		List<Question> questions = (List<Question>) query.getResultList();
		return questions;
	}
*/
	/**
	 * @param q String
	 * @return List<Question>
	 */
/*	@SuppressWarnings("unchecked")
	public List<Question> getQuestionsByCategoryText(String q) {
		Query query = em.createQuery("select distinct q from Question q "
				+ "inner join q.categories as c "
				+ "where (c.name like :q OR c.description like :q) and (q.linkId is null and q.linkSource is null) "
				+ "order by q.shortName");
		query.setParameter("q", "%" + q + "%");
		List<Question> questions = (List<Question>) query.getResultList();
		return questions;
	}
*/
	/**
	 * <b>questionId</b> is id of target item.
	 * @param questionId Long
	 * @param ordType ItemOrderingAction
	 * @return pair of two consecutive Question items
	 */
/*	@SuppressWarnings("unchecked")
	public List<Question> getAdjacentPairOfQuestions(Long questionId, ItemOrderingAction ordType) {
		String sign = (ordType == ItemOrderingAction.UP ? "<=" : ">=");
		String orderBy = (ordType == ItemOrderingAction.UP ? "DESC" : "ASC");
		String jpql = "select otherQst from Question ordQst, Question otherQst "
				+ "where ordQst.id = :questionId "
				+ "and otherQst.form.id = ordQst.form.id "
				+ "and otherQst.ord " + sign + " ordQst.ord "
				+ "order by otherQst.ord " +  orderBy;

		Query query = em.createQuery(jpql);
		query.setParameter("questionId", questionId);
		query.setMaxResults(2);

		List<Question> questions = (List<Question>) query.getResultList();

        for (Question q : questions) {
            for (Answer answer: q.getAnswers())
        	{
                for (@SuppressWarnings("unused") AnswerValue av: answer.getAnswerValues()) break; // just to load it
        	}
            for (@SuppressWarnings("unused") FormElementSkip sp: q.getQuestionSkip()) break; // just to load it
            break;
        }
        return query.getResultList();
	}
*/


	/**
	 * @param questionId Long
	 * @return Question
	 */
	public BaseQuestion getQuestionFetchesChildren(Long questionId) {
		BaseQuestion q = getById(questionId);
		q.getAnswer();
        return q;
	}

	/**
	 * @param questionId Long
	 * @return Question
	 */
	@SuppressWarnings("unchecked")
	public BaseQuestion getQuestionFetchesChildrenByUuid(String uuid) {
		Query query = em.createQuery("from BaseQuestion where uuid = :uuid");
	    query.setParameter("uuid", uuid);
	    List<Question> qList = query.getResultList();
	    if ( qList.size() == 0 ) return null;
		// Question q = getById(questionId);
	    Question q = qList.get( 0 );
        q.getAnswer();
        return q;
	}

	/**
	 * @param answerId Long
	 * @return Question
	 */
	@SuppressWarnings("unchecked")
	public BaseQuestion getQuestionByAnswerID(Long answerId) {
	    Query query = em.createQuery("select answer.question from Answer answer where answer.id = :answerId");
	    query.setParameter("answerId", answerId);
	    List<BaseQuestion> qList = query.getResultList();
	    if (qList.size() == 0 ) return null;
	    else if (qList.size() > 1) throw new javax.persistence.NonUniqueResultException("Answer (id:" + answerId + ") has more then 1 parent");
	    else return qList.get(0);

	}

	/**
	 * @param formId Long
	 * @param uuid Long
	 * @return true if question exists in form
	 */
	public boolean isQuestionAlreadyExistsInForm(Long formId, String uuid) {
//		String jpql = "select count(*) from BaseQuestion q , FormElement e where q.parent.id = e.id and e.form.id = :formId and (q.uuid = :uuid or q.linkId = :uuid) and linkId is not null";
		/* Only questions that are imported wil be links */
		String sql = "select count(*) from form_element e where e.form_id = :formId and e.link_id = :uuid";
		//Query query = em.createQuery(jpql);
		Query query = em.createNativeQuery(sql);
		query.setParameter("formId", formId);
		query.setParameter("uuid", uuid);
		int count = Integer.valueOf(query.getSingleResult().toString());
		return count > 0;
	}

	public boolean isQuestionAlreadyExistsInForm(Long formId, Long id) {
//		String jpql = "select count(*) from BaseQuestion q , FormElement e where q.parent.id = e.id and e.form.id = :formId and (q.uuid = :uuid or q.linkId = :uuid) and linkId is not null";
		/* Only questions that are imported wil be links */
		String sql = "select count(*) from form_element e where e.form_id = :formId and e.link_id = :uuid";
		//Query query = em.createQuery(jpql);
		Query query = em.createNativeQuery(sql);
		query.setParameter("formId", formId);
		query.setParameter("uuid", id);
		int count = Integer.valueOf(query.getSingleResult().toString());
		return count > 0;
	}
	/**
	 * @param q
	 *            String
	 * @return List<Question>
	 */
/*	@SuppressWarnings("unchecked")
  public List<Question> getQuestionsByText(String q) {
    List<Question> result = Collections.emptyList();

    if (StringUtils.isNotEmpty(q)) {
      String query = q.replaceAll("'", "''");

      result = em.createNativeQuery("select *, ts_rank_cd(q.ts_data, query) as rank "
                                        + "   from question q, plainto_tsquery('"
                                        + query
                                        + "') query"
                                        + "   where q.link_id is null AND q.link_source is null AND q.ts_data @@ query"
                                        + "   order by rank desc",
                                    Question.class)
                 .getResultList();
    }

    return result;
  }
*/
	   //@Transactional(readOnly = false, propagation=Propagation.REQUIRES_NEW)
	public void create(BaseQuestion entity) {
		em.persist(entity);
	}

    //@Transactional(readOnly = false, propagation=Propagation.REQUIRES_NEW)
	public void save(BaseQuestion entity) {
		if (entity.isNew())
			create(entity);
		else
			update(entity);
	}

	/**
	 * Always merges. If an entity is in context it is cheaper to do {@link}persist
	 * but in web app context it is rare.
	 * @param entity
	 * @return
	 */
    //@Transactional(readOnly = false, propagation=Propagation.REQUIRES_NEW)
	public void update(BaseQuestion entity) {
		em.merge(entity);    		
	}

    @Transactional(readOnly = false, propagation=Propagation.REQUIRES_NEW)
	public void delete(BaseQuestion entity) {
		em.remove(entity);
	}
    public BaseQuestion getById(Long id)
    {
    	Query query = em.createQuery("from BaseQuestion q where id = :Id");
    	query.setParameter("Id", id);
    	return (BaseQuestion) query.getSingleResult();
    }


}
