package com.healthcit.cacure.dao;

import java.util.Collection;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;

import org.apache.commons.lang.Validate;
import org.apache.log4j.Logger;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.healthcit.cacure.enums.ItemOrderingAction;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseForm.FormStatus;
import com.healthcit.cacure.model.FormLibraryForm;
import com.healthcit.cacure.model.QuestionnaireForm;

public class FormDao
{

	private static final Logger logger = Logger.getLogger(FormDao.class);

	@PersistenceContext
	protected EntityManager em;

	public void create(BaseForm form) {
		em.persist(form);
	}
	
	public void update(BaseForm form) {
		em.merge(form);
	}
	  
	public void save(BaseForm form) {
		if (form.isNew())
			create(form);
		else
			update(form);
	}
	
	public void delete(BaseForm form) {
		em.remove(form);
		em.flush();
	}

	public void delete(Long id)
	{
		 em.createQuery("DELETE BaseForm fe WHERE fe.id = :Id")
	        .setParameter("Id", id)
	        .executeUpdate();
	}
	
	public BaseForm getById(Long id)
	{
		Query query = em.createQuery("from BaseForm fe where id = :Id");
		query.setParameter("Id", id);
	    return (BaseForm) query.getSingleResult();
	}
	
	public BaseForm getByUuid(String uuid)
	{
		Query query = em.createQuery("from BaseForm fe where uuid = :uuid");
		query.setParameter("uuid", uuid);
	    return (BaseForm) query.getSingleResult();
	}	

	/**
	 * @param moduleId Long
	 * @return List of QuestionnaireForm items
	 */
	@SuppressWarnings("unchecked")
	public List<BaseForm> getModuleForms(Long moduleId) {
//		String jpql = "select distinct frm from QuestionnaireForm frm " +
//			"left join fetch frm.elements where frm.module.id = :moduleId order by frm.ord";
			String jpql = "select frm from BaseForm frm where frm.module.id= :moduleId order by frm.ord";
		Query query = em.createQuery(jpql);
		query.setParameter("moduleId", moduleId);
		return query.getResultList();
	}
	
	/**
	 * 
	 * @param moduleId
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Long> getNonEmptyFormIDs(Long moduleId) {		
		String nativeSql = "select f.id from form f where f.id in (select form_id from form_element) and module_id="+moduleId;
		Query query = em.createNativeQuery(nativeSql);
		return com.healthcit.cacure.utils.CollectionUtils.convertAllElementsToLong(query.getResultList());
	}
	
	public boolean areAllModuleFormsApproved(Long moduleId) {
		long approvedCount = 0;
		long totalCount = Long.MAX_VALUE;
		
		// Get the all forms count
		String totalJpql = "select count(distinct frm) from QuestionnaireForm frm " +
		"where frm.module.id = :moduleId";
		Query totalQuery = em.createQuery(totalJpql);
		totalQuery.setParameter("moduleId", moduleId);
		totalCount = (Long)totalQuery.getSingleResult();
		
		// Get the returned forms count
		String approvedJpql = "select count(distinct frm) from QuestionnaireForm frm " +
		"where frm.module.id = :moduleId and frm.status = :status";
		Query approvedQuery = em.createQuery(approvedJpql);
		approvedQuery.setParameter("moduleId", moduleId);
		approvedQuery.setParameter("status", FormStatus.APPROVED);
		approvedCount = (Long)approvedQuery.getSingleResult();
		
		// If there are no forms there, they cannot be all approved
		if (totalCount == 0) {
			return false;
		}
		
		boolean allFormsApproved = totalCount == approvedCount;
		return allFormsApproved;
	}
	
	public Long getNumberOfFormsForModuleId(Long moduleId) {
		String q = "select count(distinct frm) from QuestionnaireForm frm " +
		"where frm.module.id = :moduleId";
		Query query = em.createQuery(q);
		query.setParameter("moduleId", moduleId);
		return (Long)query.getSingleResult();
	}
	
	/**
	 * @param moduleId Long
	 * @return List of QuestionnaireForm items
	 */
	@SuppressWarnings("unchecked")
	public List<BaseForm> getModuleForms(Long moduleId, Long formId) {
		String jpql = "select distinct frm from BaseForm frm " +
			"left join fetch frm.elements where frm.module.id = :moduleId and frm.id != :formId order by frm.ord";
		Query query = em.createQuery(jpql);
		query.setParameter("moduleId", moduleId);
		query.setParameter("formId", formId);
		return query.getResultList();
	}

	/**
	 * <b>formId</b> is id of target item.
	 * @param formId Long
	 * @param ordType ItemOrderingAction
	 * @return pair of two consecutive QuestionnaireForm items
	 */
	@SuppressWarnings("unchecked")
	public List<QuestionnaireForm> getAdjacentPairOfForms(Long formId, ItemOrderingAction ordType) {
		String sign = (ordType == ItemOrderingAction.UP ? "<=" : ">=");
		String orderBy = (ordType == ItemOrderingAction.UP ? "DESC" : "ASC");
		String jpql = "select otherFrm from QuestionnaireForm ordFrm, QuestionnaireForm otherFrm "
				+ "where ordFrm.id = :formId "
				+ "and otherFrm.module.id = ordFrm.module.id "
				+ "and otherFrm.ord " + sign + " ordFrm.ord "
				+ "order by otherFrm.ord " +  orderBy;

		Query query = em.createQuery(jpql);
		query.setParameter("formId", formId);
		query.setMaxResults(2);
		return query.getResultList();
	}

	/**
	 * Deletes only form with empty questions, otherwise throws NoResultException exception.
	 * @param formId Long
	 */
	public void deleteFormWithEmptyQuestions(Long formId) {
		//prevent from deleting a QuestionnaireForm item that has questions.
		//This scenario may appear by editing the URL.
		String jpql = "select f from BaseForm f left join f.elements q "
				+ "where f.id = :formId and q is null";
		Query query = em.createQuery(jpql);
		query.setParameter("formId", formId);
		try {
			BaseForm form = (BaseForm) query.getSingleResult();
			delete(form);
		} catch (NoResultException e) {
			logger.info("try to delete an not empty form");
		}
	}

	/**
	 * @return Next Ord Number in ordered entities.
	 */
	@Transactional(propagation = Propagation.SUPPORTS)
	public Integer calculateNextOrdNumber(Long moduleId) {
		String jpql = "select MAX(ord + 1) from BaseForm f where f.module.id = :moduleId";
		Query query = em.createQuery(jpql);
		query.setParameter("moduleId", moduleId);
		return (Integer) query.getSingleResult();
	}

	@Transactional(propagation = Propagation.REQUIRED)
	public void reorderForms(Long sourceFormId, Long targetFormId,
			boolean before) {
		
		Validate.notNull(sourceFormId);
		Validate.notNull(targetFormId);
		if(sourceFormId.equals(targetFormId)) {
			return;
		}
		
		Query query = em.createQuery("SELECT ord, module.id FROM BaseForm WHERE id = :id");
		Object[] result = (Object[]) query.setParameter("id", sourceFormId).getSingleResult();
		int sOrd = (Integer) result[0];
		long sModuleId = (Long) result[1];
		
		result = (Object[]) query.setParameter("id", targetFormId).getSingleResult();
		int tOrd = (Integer) result[0];
		long tModuleId = (Long) result[1];

		Validate.isTrue(sModuleId == tModuleId);

		if(sOrd == tOrd || (before && sOrd == tOrd - 1) || ( !before && sOrd == tOrd + 1)) {
			return;
		} else if(sOrd < tOrd) {
			em.createQuery("UPDATE BaseForm SET ord = ord - 1 WHERE ord > :sOrd and ord " + (before ? "<" : "<=") + " :tOrd and module.id = :moduleId")
					.setParameter("sOrd", sOrd)
					.setParameter("tOrd", tOrd)
					.setParameter("moduleId", sModuleId)
					.executeUpdate();
			em.createQuery("UPDATE BaseForm SET ord = :tOrd WHERE id = :fId")
					.setParameter("fId", sourceFormId)
					.setParameter("tOrd", before ? tOrd - 1 : tOrd)
					.executeUpdate();
		} else if (sOrd > tOrd) {
			em.createQuery("UPDATE BaseForm SET ord = ord + 1 WHERE ord < :sOrd and ord " + (before ? ">=" : ">") + " :tOrd and module.id = :moduleId")
					.setParameter("sOrd", sOrd)
					.setParameter("tOrd", tOrd)
					.setParameter("moduleId", sModuleId)
					.executeUpdate();
			em.createQuery("UPDATE BaseForm SET ord = :tOrd WHERE id = :fId")
					.setParameter("fId", sourceFormId)
					.setParameter("tOrd", before ? tOrd : tOrd +1)
					.executeUpdate();
		}
	}
	
	public Collection<FormLibraryForm> findLibraryForms(String query)
	{
		TypedQuery<FormLibraryForm> q = this.em.createQuery("FROM FormLibraryForm form WHERE form.name LIKE :qString ORDER BY form.ord ASC", FormLibraryForm.class);
		q.setParameter("qString", "%"+query+"%");
		return q.getResultList();
	}
	
	public Collection<FormLibraryForm> getAllLibraryForms()
	{
		TypedQuery<FormLibraryForm> q = this.em.createQuery("FROM FormLibraryForm form ORDER BY form.ord ASC", FormLibraryForm.class);
		return q.getResultList();
	}

	public boolean isFormWithTheSameNameExistInLibrary(final String formName) {
		Query q = this.em.createQuery("SELECT count(form.id) FROM FormLibraryForm form WHERE form.name = :name");
		q.setParameter("name", formName);
		long count = (Long) q.getSingleResult();
		return count > 0;
	}
	
	public FormLibraryForm getFormLibraryFormByName(final String formName) {
		TypedQuery<FormLibraryForm> q = this.em.createQuery("SELECT form FROM FormLibraryForm form WHERE form.name = :name ORDER BY form.updateDate DESC", FormLibraryForm.class);
		q.setMaxResults(1);
		q.setParameter("name", formName);
		List<FormLibraryForm> resultList = q.getResultList();
		return resultList.size() > 0 ? resultList.get(0) : null;
	}

	public long getSkipTriggerQuestionsCount(Long formId) {
		Query q = this.em.createQuery("SELECT count(asr.id) FROM AnswerSkipRule asr WHERE asr.formId = :formId");
		q.setParameter("formId", formId);
		long count = (Long) q.getSingleResult();
		return count;
	}

	public int updateFormLibraryForm(QuestionnaireForm qForm, FormLibraryForm flForm) {
		//Flush first to get callbacks set formLibraryForm to null
		save(flForm);
		save(qForm);
		em.flush();
		//Silent (without callbacks (@Pre...)) set of formLibraryForm
		return this.em.createQuery("UPDATE QuestionnaireForm SET formLibraryForm = :lForm WHERE id = :qFormId")
				.setParameter("lForm", flForm)
				.setParameter("qFormId", qForm.getId())
				.executeUpdate();
	}

}