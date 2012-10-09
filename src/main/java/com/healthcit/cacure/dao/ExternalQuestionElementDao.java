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

import javax.persistence.Query;

import com.healthcit.cacure.model.ExternalQuestionElement;


import org.apache.log4j.Logger;

public class ExternalQuestionElementDao extends FormElementDao
{
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(ExternalQuestionElementDao.class);
	
/*
  @Override
  public ExternalQuestionElement create(ExternalQuestionElement entity) {
	  ExternalQuestionElement result = super.create(entity);
	  reindexFormElementTextSearch(result);
	  return result;
  }

  @Override
  public ExternalQuestionElement update(ExternalQuestionElement entity) {
	  ExternalQuestionElement result = super.update(entity);
    reindexFormElementTextSearch(result);
    return result;
  }
*/
	@Override
	public ExternalQuestionElement getById(Long id)
	{
		Query query = em.createQuery("from FormElement fe where id = :Id and element_type='externalQuestion'");
		query.setParameter("Id", id);
		return (ExternalQuestionElement) query.getSingleResult();
	}  

}
