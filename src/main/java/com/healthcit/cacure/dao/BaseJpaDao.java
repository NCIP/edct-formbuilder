package com.healthcit.cacure.dao;

import java.io.Serializable;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.model.StateTracker;
/**
 *
 * @author Gangs
 *
 * @param <T>
 * @param <ID>
 */
@Transactional
public abstract class BaseJpaDao <T extends StateTracker, ID extends Serializable>
{

	private Class<T> persistentClass;

	@PersistenceContext
	protected EntityManager em;

    public BaseJpaDao(final Class<T> persistentClass) {
        this.persistentClass = persistentClass;
    }

    //@Transactional(readOnly = false, propagation=Propagation.REQUIRES_NEW)
	public T create(T entity) {
		em.persist(entity);
		return entity;
	}

    //@Transactional(readOnly = false, propagation=Propagation.REQUIRES_NEW)
	public T save(T entity) {
		if (entity.isNew())
			return create(entity);
		else
			return update(entity);
	}

	/**
	 * Always merges. If an entity is in context it is cheaper to do {@link}persist
	 * but in web app context it is rare.
	 * @param entity
	 * @return
	 */
    //@Transactional(readOnly = false, propagation=Propagation.REQUIRES_NEW)
	public T update(T entity) {
		em.merge(entity);    		
		return entity;
	}

    @Transactional(readOnly = false, propagation=Propagation.REQUIRES_NEW)
	public void delete(T entity) {
		em.remove(entity);
	}

	public void delete(ID id) {
		delete(getById(id));
	}

    public boolean exists(ID id) {
        T entity = getById(id);
        return entity != null;
    }

	public T getById(ID id) {
		return em.find(persistentClass, id);
	}

	@SuppressWarnings("unchecked")
	public List<T> list() {
		Query query = em.createQuery("FROM " + persistentClass.getSimpleName() + " c");
		List<T> results = query.getResultList();
		return results;
	}



}