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
