package com.healthcit.cacure.dao;

import javax.persistence.Query;

import org.apache.log4j.Logger;

import com.healthcit.cacure.model.Question;

public class QuestionDao extends BaseQuestionDao
{
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(QuestionDao.class);

    @Override
	public Question getById(Long id)
        	{
    	Query query = em.createQuery("from Question q where id = :Id");
    	query.setParameter("Id", id);
    	return (Question) query.getSingleResult();
        	}
/*
  @Override
  public Question create(Question entity) {
	  Question result = super.create(entity);
	  return result;
  }

  @Override
  public Question update(Question entity) {
    Question result = super.update(entity);
    return result;
  }

*/

}