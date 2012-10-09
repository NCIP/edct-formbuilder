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

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.apache.log4j.Logger;

public class AnswerValueDao {

	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(FormElementDao.class);
	@PersistenceContext
	protected EntityManager em;

	public boolean isValidAnswerValue(String permAnswerValueId)
	{
	    String queryStr = "	select 1 from answer_value where permanent_id = ?1";

		Query query = em.createNativeQuery(queryStr);
	    query.setParameter(1, permAnswerValueId);
	    
	    @SuppressWarnings("rawtypes")
		List results = query.getResultList();

	    if(results.size() > 0){
	    	return true;
	    }
	    return false;
	}
}
