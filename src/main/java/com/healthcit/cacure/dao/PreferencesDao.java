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
