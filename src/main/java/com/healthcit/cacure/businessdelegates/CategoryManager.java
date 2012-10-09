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

import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;

import com.healthcit.cacure.dao.CategoryDao;
import com.healthcit.cacure.model.Category;

public class CategoryManager {
	
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(CategoryManager.class);
	
	@Autowired
	private CategoryDao categoryDao;
	
	public Category getCategoryById(Long id) {
		return categoryDao.getById(id);
	}
	
	public List<Category> getAllCategories() {
		return categoryDao.list();
	}
	
	public List<Category> getLibraryQuestionsCategories() {
		return categoryDao.getLibraryQuestionsCategories();
	}

	public Category saveCategory(Category entity) {
		return categoryDao.save(entity);
	}

	public List<Category> getCategoriesByName(String name)
	{
		return categoryDao.getCategoriesByName(name);
	}
}
