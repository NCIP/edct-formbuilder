/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.dao;

import javax.persistence.Query;

import com.healthcit.cacure.model.ContentElement;

import org.apache.log4j.Logger;

public class ContentElementDao extends FormElementDao
{
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(ContentElementDao.class);

	/*
  @Override
  public ContentElement create(ContentElement entity) {
	  ContentElement result = super.create(entity);
	  reindexFormElementTextSearch(result);
	  return result;
  }

  @Override
  public ContentElement update(ContentElement entity) {
	  ContentElement result = super.update(entity);
    reindexFormElementTextSearch(result);
    return result;
  }
*/
	@Override
	public ContentElement getById(Long id)
	{
		Query query = em.createQuery("from FormElement fe where id = :Id and element_type='content'");
		query.setParameter("Id", id);
		return (ContentElement) query.getSingleResult();
	}  

}
