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

import javax.persistence.Query;

import org.apache.commons.collections.CollectionUtils;
import org.apache.log4j.Logger;

import com.healthcit.cacure.model.TableElement;

public class TableElementDao extends FormElementDao
{
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(TableElementDao.class);

	@Override
	public TableElement getById(Long id)
	{
		Query query = em.createQuery("from FormElement fe where id = :Id and element_type='table'");
		query.setParameter("Id", id);
		return (TableElement) query.getSingleResult();
	}
	
	public Set<String> getTableShortNamesLike(Set<String> shortNames, boolean exact)
	{
		if(CollectionUtils.isEmpty(shortNames)) {
			return new HashSet<String>(0);
		}
		StringBuffer sb = new StringBuffer("select fe.tableShortName from FormElement fe where ");
		int num = 1;
		for (String shortName : shortNames) {
			sb.append("fe.tableShortName like ?");
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

}
