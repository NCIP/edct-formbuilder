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

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.apache.log4j.Logger;

import com.healthcit.cacure.model.PreferenceSettings;

public class PreferencesDao {
	private static final Logger logger = Logger.getLogger(PreferencesDao.class);

	@PersistenceContext
	protected EntityManager em;

	public void savePreferenceSettings(PreferenceSettings settings) {
		em.merge(settings);
	}
	
	public PreferenceSettings getPreferenceSettings()
	{
		Query query = em.createQuery("from PreferenceSettings fe where id = 1");
	    return (PreferenceSettings) query.getSingleResult();
	}

}
