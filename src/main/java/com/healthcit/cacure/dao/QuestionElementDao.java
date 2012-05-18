package com.healthcit.cacure.dao;

import javax.persistence.Query;

import com.healthcit.cacure.model.QuestionElement;

import org.apache.log4j.Logger;

public class QuestionElementDao extends FormElementDao
{
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(QuestionElementDao.class);

/*
  @Override
  public QuestionElement create(QuestionElement entity) {
	  QuestionElement result = super.create(entity);
//	  reindexFormElementTextSearch(result);
	  return result;
  }

  @Override
  public QuestionElement update(QuestionElement entity) {
	  QuestionElement result = super.update(entity);
//    reindexFormElementTextSearch(result);
    return result;
  }
  */
  @Override
  public QuestionElement getById(Long id)
  {
	  Query query = em.createQuery("from FormElement fe where id = :Id and element_type='question'");
	  query.setParameter("Id", id);
	  return (QuestionElement) query.getSingleResult();
  }  
  
}