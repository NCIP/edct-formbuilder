package com.healthcit.cacure.dao;


import javax.persistence.Query;

import org.apache.commons.lang.Validate;
import org.apache.log4j.Logger;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;


import com.healthcit.cacure.model.TableQuestion;


public class QuestionTableDao extends BaseQuestionDao
{
	@SuppressWarnings("unused")
	private static final Logger log = Logger.getLogger(QuestionTableDao.class);

	/**
	 * @return Next Ord Number in ordered entities.
	 */
	@Transactional(propagation = Propagation.SUPPORTS)
	public Integer calculateNextOrdNumber(Long formId) {
		String jpql = "select MAX(ord + 1) from TableQuestion q, FormElement e where q.parent_id=e.id and e.form.id = :formId";
		Query query = em.createQuery(jpql);
		query.setParameter("formId", formId);
		return (Integer) query.getSingleResult();

	}
 
  @Transactional(propagation = Propagation.REQUIRED)
  public void reorderQuestions(Long sourceQuestionId, Long targetQuestionId, boolean before) {

    Validate.notNull(sourceQuestionId);
    Validate.notNull(targetQuestionId);

    if (sourceQuestionId.equals(targetQuestionId)) {
      return;
    }

    Query query = em.createQuery("SELECT ord, form.id FROM TableQuestion WHERE id = :id");

    Object[] result = (Object[]) query.setParameter("id", sourceQuestionId).getSingleResult();
    int sOrd = (Integer) result[0];
    long sFormId = (Long) result[1];

    result = (Object[]) query.setParameter("id", targetQuestionId).getSingleResult();
    int tOrd = (Integer) result[0];
    long tFormId = (Long) result[1];

    Validate.isTrue(sFormId == tFormId); //reorder only inside one form

    if (sOrd == tOrd || (before && sOrd == tOrd - 1) || ( !before && sOrd == tOrd + 1)) {
      return;
    } else if (sOrd < tOrd) {
      em.createQuery("UPDATE TableQuestion SET ord = ord - 1 WHERE ord > :sOrd and ord " + (before ? "<" : "<=") + " :tOrd and form.id = :formId")
        .setParameter("sOrd", sOrd)
        .setParameter("tOrd", tOrd)
        .setParameter("formId", sFormId)
        .executeUpdate();
      em.createQuery("UPDATE TableQuestion SET ord = :tOrd WHERE id = :qId")
        .setParameter("qId", sourceQuestionId)
        .setParameter("tOrd", before ? tOrd - 1 : tOrd)
        .executeUpdate();
    } else if (sOrd > tOrd) {
      em.createQuery("UPDATE TableQuestion SET ord = ord + 1 WHERE ord < :sOrd and ord " + (before ? ">=" : ">") + " :tOrd and form.id = :formId")
        .setParameter("sOrd", sOrd)
        .setParameter("tOrd", tOrd)
        .setParameter("formId", sFormId)
        .executeUpdate();
      em.createQuery("UPDATE TableQuestion SET ord = :tOrd WHERE id = :qId")
        .setParameter("qId", sourceQuestionId)
        .setParameter("tOrd", before ? tOrd : tOrd + 1)
        .executeUpdate();
    }
  }
  
  @Override
  public TableQuestion getById(Long id)
  {
  	Query query = em.createQuery("from TableQuestion q where id = :Id");
  	query.setParameter("Id", id);
  	return (TableQuestion) query.getSingleResult();
  }

}