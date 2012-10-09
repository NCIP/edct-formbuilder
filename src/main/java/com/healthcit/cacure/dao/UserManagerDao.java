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

/**
 * @author Suleman Choudhry
 * @version
 */

import java.util.List;

import javax.persistence.Query;

import org.apache.log4j.Logger;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.model.Role;
import com.healthcit.cacure.model.UserCredentials;

public class UserManagerDao extends BaseJpaDao<UserCredentials, Long> 
{

	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(UserManagerDao.class);

	public UserManagerDao()
	{
		super(UserCredentials.class);
	}

	@Transactional(readOnly=true)
	public UserCredentials findByName(String uName) {		
	    Query query = this.em.createQuery("from UserCredentials where username = :uName");
	    query.setParameter("uName", uName);	    
	    return (UserCredentials) query.getSingleResult();
	}	
	
	@Transactional(readOnly=true)
	@SuppressWarnings("unchecked")
	public List<Role> getUserRoles(UserCredentials user) {
		String jpql = "select u.roles from UserCredentials u where u = :user";
		Query query = em.createQuery(jpql);
	    query.setParameter("user", user);
		return query.getResultList();
	}
	
}
