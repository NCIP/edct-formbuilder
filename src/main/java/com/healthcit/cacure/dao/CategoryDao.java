package com.healthcit.cacure.dao;

import java.util.List;

import javax.persistence.Query;

import com.healthcit.cacure.model.Category;

public class CategoryDao extends BaseJpaDao<Category, Long> {
	
	public CategoryDao() {
		super(Category.class);
	}
	
	/**
	 * @param ids List<Long>
	 * @return List<Category> with specified ids
	 */
	@SuppressWarnings("unchecked")
	public List<Category> getCategoriesInIds(List<Long> ids) {
		String jpql = "select c from Category c where c.id IN(:ids)"; 
		Query query = em.createQuery(jpql);
		query.setParameter("ids", ids);		
		return query.getResultList();
	}

	@SuppressWarnings("unchecked")
	public List<Category> getLibraryQuestionsCategories() {
		String jpql = "select c from Category c "
			+ "where exists(select q.id from FormElement q "
					+ "inner join q.categories as c2 "
					+ "inner join q.form as f "
					+ "where c = c2 and (type(f) = QuestionLibraryForm) and (type(q) != LinkElement)) "
			+ "order by c.name";
		Query query = em.createQuery(jpql);
		List<Category> elements = (List<Category>) query.getResultList();
		return elements;
	}

	public List<Category> getCategoriesByName( String name)
	{
		String jpql = "select c from Category c where c.name = :name";
		Query query = em.createQuery(jpql);
		query.setParameter("name", name);
		List<Category> categories = (List<Category>)query.getResultList();
		return categories;
	}
}
