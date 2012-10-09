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
package com.healthcit.cacure.businessdelegates;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.dao.PreferencesDao;
import com.healthcit.cacure.model.PreferenceSettings;

public class PreferencesManager {

	private static final Logger logger = Logger.getLogger(PreferencesManager.class);

	@Autowired
	private PreferencesDao preferencesDao;

	@Transactional
	public void savePreferenceSettings(PreferenceSettings settings) {
		preferencesDao.savePreferenceSettings(settings);
	}
	
	@Transactional
	public PreferenceSettings getPreferenceSettings() {
	    return preferencesDao.getPreferenceSettings();
	}
	
}
