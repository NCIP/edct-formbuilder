package com.healthcit.cacure.dao;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.apache.log4j.Logger;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.Module;

public class ModuleDao {
	private static final Logger logger = Logger.getLogger(ModuleDao.class);

	@PersistenceContext
	protected EntityManager em;

	@Transactional
	public BaseModule create(BaseModule module) {
		em.persist(module);
		logger.debug("Created module: " + module);
		return module;
	}	
	
	public void update(BaseModule module) {
		logger.debug("Update module: " + module.toString());	
		em.merge(module);		
	}
	  
	public void save(BaseModule module) {
		if (module.isNew()) {
			create(module);			
		} else {
			update(module);			
		}
	}
	
	public void delete(BaseModule module) {
		em.remove(module);
	}

	public void delete(Long id)
	{
		 em.createQuery("DELETE BaseModule fe WHERE fe.id = :Id")
	        .setParameter("Id", id)
	        .executeUpdate();
	}
	
	public BaseModule getById(Long id)
	{
		Query query = em.createQuery("from BaseModule fe where id = :Id");
		query.setParameter("Id", id);
	    return (BaseModule) query.getSingleResult();
	}
	
	public BaseModule getByUUID(String uuid)
	{
		BaseModule module = null;
		Query query = em.createQuery("from BaseModule fe where uuid = :Id");
		query.setParameter("Id", uuid);
		try
		{
			module = (BaseModule) query.getSingleResult();
		}
		catch(javax.persistence.NoResultException e)
		{
			logger.debug("No object found with uuid " + uuid);
		}
	    return module;
	}
	
	/**
	 * @return Cosistently ordered list of Modules
	 */
	@SuppressWarnings("unchecked")
	public List<Module> getOrderedModuleList() {
		Query query = em.createQuery("select m from Module m order by m.description, m.id ");
		return query.getResultList();
	}

	@SuppressWarnings("unchecked")
	public List<BaseModule> getLibraryModules()
	{
		//By default it returns order by last update date.
		Query query = em.createQuery("select m from BaseModule m where m.isLibrary = true order by id");
		return query.getResultList();
	}
	/**
	 * Deletes only module with empty forms, otherwise throws NoResultException exception.
	 * @param moduleId Long
	 */
	public void deleteModuleWithEmptyForms(Long moduleId) {
		//prevent from deleting a Module item that has forms.
		//This scenario may appear by editing the URL.
		String jpql = "select m from BaseModule m left join m.forms f "
				+ "where m.id = :moduleId and f is null";
		Query query = em.createQuery(jpql);
		query.setParameter("moduleId", moduleId);
		try {
			BaseModule module = (BaseModule) query.getSingleResult();
			delete(module);
		} catch (NoResultException e) {
			logger.info("try to delete an not empty module");
		}
	}

}
