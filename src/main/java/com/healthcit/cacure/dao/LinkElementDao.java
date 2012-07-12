package com.healthcit.cacure.dao;

import java.math.BigInteger;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.Query;

import org.apache.log4j.Logger;

import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.utils.CollectionUtils;

public class LinkElementDao extends FormElementDao
{
	private static final Logger log = Logger.getLogger(LinkElementDao.class);

/*
  @Override
  public LinkElement create(LinkElement entity) {
	  LinkElement result = super.create(entity);
//	  reindexFormElementTextSearch(result);
	  return result;
  }

  @Override
  public LinkElement update(LinkElement entity) {
	  LinkElement result = super.update(entity);
//    reindexFormElementTextSearch(result);
    return result;
  }
*/
  @SuppressWarnings("unchecked")
  public List<LinkElement> getLinkedFormElements(FormElement parent) {
    Query query = em.createQuery("FROM LinkElement le WHERE le.sourceUuid = :lid")
             .setParameter("lid", parent.getUuid());
//     log.debug("Linked FormElements Query: " + query.toString());
     List<LinkElement> elements = query.getResultList();
     log.debug("Retrieved " + elements.size() + " form elements");
     return elements;
    
  }
  
/**
 * Checks is form elements has linked elements. 
 * @param parent form element to be checked
 * @return <code>true</code> if form element has linked elements and <code>false</code> otherwise
 */
//public boolean hasLinkedFormElements(FormElement parent)
//  {
//	  return getPointedLinksNumber(parent) > 0;
//  }
  
  @SuppressWarnings("unchecked")
  public List<Long> getLinkedFormElementIds(String linkId) {
    return (List<Long>) em.createQuery("select q.id from FormElement q where q.sourceUuid = :lid")
                          .setParameter("lid", linkId)
                          .getResultList();
  }
  
  @SuppressWarnings("unchecked")
  public List<String> getLinkedFormElementDescriptions(String linkId) {
	  return (List<String>) em.createQuery("select q.description from FormElement q where q.sourceUuid = :lid")
              .setParameter("lid", linkId)
              .getResultList();
  }
  
  @SuppressWarnings("unchecked")
  public Set<String> getLinkedFormElementUuids(Set<String> linkUuids) {
	  List<String> resultList = em.createQuery("select distinct q.sourceUuid from FormElement q where q.sourceUuid in (:luuids)")
			  .setParameter("luuids", linkUuids)
			  .getResultList();
	return new HashSet<String>(resultList);
  }

//  public boolean isLinkedFromApprovedForm(FormElement parent)
//  {
//	  Query query = this.em.createQuery("SELECT count(*) FROM LinkElement le WHERE le.sourceUuid = :lid and le.form.status = :status")
//	  	.setParameter("lid", parent.getUuid())
//	  	.setParameter("status", BaseForm.FormStatus.APPROVED);
//	  Number count = (Number)query.getSingleResult();
//	  return count.intValue() > 0;
//  }
//  
//  public int getPointedLinksNumber(FormElement parent)
//  {
//	  Query query = this.em.createQuery("SELECT count(*) FROM LinkElement le WHERE le.sourceUuid = :lid")
//	  	.setParameter("lid", parent.getUuid());
//	  Number count = (Number)query.getSingleResult();
//	  return count.intValue();
//  }
  
  @SuppressWarnings("unchecked")
  public List<Long> getLinkedSkippedFormElementIds(String linkId) {
    Query query = em.createNativeQuery("select q.id from form_element q, answer a, answer_value aw, question_skip_rule sp where q.link_id = :lid AND a.question_id = q.id AND aw.answer_id = a.id AND aw.permanent_id IN (SELECT spp.answer_value_id from answer_skip_rule spp where spp.parent_id = sp.id)")
                          .setParameter("lid", linkId);
	return CollectionUtils.convertAllElementsToLong(query.getResultList());
  }

  public FormElement getLinkSource(String sourceUuid) {
    Query query = em.createQuery("SELECT fe FROM FormElement fe WHERE fe.uuid = :lid").setParameter("lid", sourceUuid);
     FormElement element = (FormElement)query.getSingleResult();
     return element;
    
  }
  
  @SuppressWarnings("unchecked")
  public List<Long> getLinkedReadOnlyFormElementIds(String linkId) {
    //NOTE: module is read only if release_date is not null
	if ( linkId == null ) {
		Query query = em.createNativeQuery("select q.id from form_element q, form f, module m where q.link_id is null AND q.form_id = f.id AND f.module_id = m.id AND m.release_date is not null");
		List<BigInteger> resultList = query.getResultList();
		return com.healthcit.cacure.utils.CollectionUtils.convertAllElementsToLong(resultList);
	}
	else {
		Query query = em.createNativeQuery("select q.id from form_element q, form f, module m where q.link_id = :lid AND q.form_id = f.id AND f.module_id = m.id AND m.release_date is not null")
			.setParameter("lid", linkId);
		List<BigInteger> resultList = query.getResultList();
		return com.healthcit.cacure.utils.CollectionUtils.convertAllElementsToLong(resultList);
	}
  }

  @Override
  public void delete(Long id)
	{
		 em.createNativeQuery("delete from form_element where id  = :Id")
	        .setParameter("Id", id)
	        .executeUpdate();
	}


}