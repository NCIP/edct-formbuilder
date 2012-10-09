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

import com.healthcit.cacure.model.Role;
import com.healthcit.cacure.model.Role.RoleCode;


public class RoleDao extends BaseJpaDao<Role, Long>  
{

	public RoleDao() 
	{
		super(Role.class);
	}

	public Role getByRoleCode(RoleCode roleCode) {
		String jpql = "from Role r where r.roleCode = :roleCode";
		Query query = em.createQuery(jpql);
		query.setParameter("roleCode", roleCode);
		return (Role)query.getSingleResult();
	}

}
