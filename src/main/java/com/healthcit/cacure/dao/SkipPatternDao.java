package com.healthcit.cacure.dao;

import java.util.EnumSet;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.apache.commons.lang.StringUtils;

import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.BaseSkipRule;
import com.healthcit.cacure.utils.Constants;

public class SkipPatternDao {

	
	@PersistenceContext
	protected EntityManager em;

	public boolean isSkip(Long questionId) {

		String queryStr = null;
		    queryStr = "	select 1 " +
	    	"from answer ans, answer_value ansva, answer_skip_rule skp, question qst, form_element fe " +
		    	"where skp.answer_value_id = ansva.permanent_id and ansva.answer_id = ans.id and ans.question_id = qst.id " +
	    	"and qst.parent_id = fe.id and fe.id = ?1 union " + 
		    "select 1 " +
	    	"from answer ans, answer_value ansva, answer_skip_rule skp, question qst, form_element fe1, form_element fe2 " +
	    	"where skp.form_id = fe2.form_id and skp.answer_value_id = ansva.permanent_id and ansva.answer_id = ans.id and ans.question_id = qst.id " +
	    	"and qst.parent_id = fe1.id and fe1.uuid = fe2.link_id and fe2.id = ?2 limit 1";
		
		Query query = em.createNativeQuery(queryStr);
	    query.setParameter(1, questionId);
	    query.setParameter(2, questionId);
	    
	    @SuppressWarnings("rawtypes")
		List results = query.getResultList();

	    if(results.size() > 0){
	    	return true;
	    }
	    return false;
	}
	
	public Set<String> getSkipsUuidsFrom(Set<String> feUuids) {
		if(feUuids == null || feUuids.isEmpty()) {
			return new HashSet<String>(0);
		}
		String ids = "'" + StringUtils.join(feUuids, "','") + "'";
		String queryStr = "select fe.uuid || '' " +
				"from answer ans, answer_value ansva, answer_skip_rule skp, question qst, form_element fe " +
				"where skp.answer_value_id = ansva.permanent_id and ansva.answer_id = ans.id and ans.question_id = qst.id " +
				"and qst.parent_id = fe.id and fe.uuid in ("+ ids +") union " + 
				"select fe2.uuid  || '' " +
				"from answer ans, answer_value ansva, answer_skip_rule skp, question qst, form_element fe1, form_element fe2 " +
				"where skp.form_id = fe2.form_id and skp.answer_value_id = ansva.permanent_id and ansva.answer_id = ans.id and ans.question_id = qst.id " +
				"and qst.parent_id = fe1.id and fe1.uuid = fe2.link_id and fe2.uuid in ("+ ids +")";
		
		Query query = em.createNativeQuery(queryStr);
		
		return new HashSet<String>((List<String>) query.getResultList());
		
	}

	@Deprecated
	public void deleteSkip(Long questionId) {

		String queryStr = "delete from answer_skip_rule where answer_value_id in ( select ansva.permanent_id " +
				"from answer ans, answer_value ansva, answer_skip_rule skp, question qst " +
				"where skp.answer_value_id = ansva.permanent_id and ansva.answer_id = ans.id and ans.question_id = qst.id " +
				"and qst.parent_id = ?1 )";

	    Query query = em.createNativeQuery(queryStr);

	    query.setParameter(1, questionId);
	    query.executeUpdate();
	  //Delete skips that do not have parts
	    String deleteSkips = "delete from question_skip_rule where id not in (select parent_id from answer_skip_rule)";
	    query = em.createNativeQuery(deleteSkips);
	    query.executeUpdate();
	}

	public boolean isAnswerValueSkip(String permAnswerValueId, Long formId) {


	    String queryStr = "	select 1 from answer_skip_rule where answer_value_id = ?1 and form_id = ?2 limit 1";

		Query query = em.createNativeQuery(queryStr);
	    query.setParameter(1, permAnswerValueId);
	    query.setParameter(2, formId);
	    
	    @SuppressWarnings("rawtypes")
		List results = query.getResultList();

	    if(results.size() > 0){
	    	return true;
	    }
	    return false;
	}

	public Map<String, String> getQuestionIdbyAnswerValueId(String answerValueId) {

	    Map<String, String> skipMap = new HashMap<String, String>();

		String queryStr = "select distinct qa.uuid, ansv.value " +
							"from question qa, answer ans, answer_value ansv, answer_skip_rule sp " +
							"where qa.id = ans.question_id and " +
							"ans.id = ansv.answer_id and " +
							"ansv.permanent_id = sp.answer_value_id and " +
							"sp.answer_value_id = ? limit 1";

		Query query = em.createNativeQuery(queryStr);
	    query.setParameter(1, answerValueId);
	    Object result = query.getSingleResult();

	    Object[] objectArray = (Object[]) result;
	    String questionId = (String)objectArray[0];
	    String value = (String)objectArray[1];

	    //TODO remove following System stmts.
    	System.out.println("************************************* getQuestionIdbyAnswerValueId");
	    System.out.println("questionId: " + questionId);
	    System.out.println("value: " + value);

	    skipMap.put(Constants.QUESTION_ID, questionId);
	    skipMap.put(Constants.ANS_VALUE, value);
	    return skipMap;
	}




	public boolean isAnswerValueSkipTableRow(Long answerId) {


	    String queryStr = "	select 1 from answer_skip_rule sp, answer ans, answer_Value anv where sp.answer_value_id = anv.permanent_id and anv.answer_id = ans.id and ans.id = ?1 limit 1";

		Query query = em.createNativeQuery(queryStr);
	    query.setParameter(1, answerId);
	    
	    @SuppressWarnings("rawtypes")
		List results = query.getResultList();

	    //System.out.println("SkipPattenDao.isAnswerValueSkipTableRow(): answerId: " + answerId);

	    if(results.size() > 0){
	    	return true;
	    }
	    return false;
	}

	@Deprecated
	public void deleteAnswerValueSkip(String permAnswerValueId) {

		String queryStr = " delete from question_skip_rule where answer_value_id = ?1";

	    Query query = em.createNativeQuery(queryStr);

	    query.setParameter(1, permAnswerValueId);
	    query.executeUpdate();
	}

	public void skipPointsToReadOnlyCleanup() {
		skipPointsToReadOnlyCleanup(null);
	}
	
	public void skipPointsToReadOnlyCleanup(Long formElementId) {
		String queryStr1 = "delete from answer_skip_rule asr where asr.answer_value_id in " +
			"(select fav.av_uuid from answer_value_form_id_vw fav " +
			"inner join form_element fe on fe.id = fav.feid " + (formElementId == null ? "" : " and fe.id = " + formElementId + " ") +
			"where fe.is_readonly)";
		Query query1 = em.createNativeQuery(queryStr1);
		query1.executeUpdate();
	}
	
	public void skipPatternCleanup() {
		Query query = em.createQuery("DELETE FROM AnswerSkipRule sp" +
				" WHERE sp.id IN (SELECT sp2.id FROM AnswerSkipRule sp2 WHERE sp2.answerValue.answer.type not in (:ats))");
		query.setParameter("ats", EnumSet.of(AnswerType.DROPDOWN, AnswerType.CHECKBOX, AnswerType.RADIO));
		query.executeUpdate();
		
		//if it would take much time it could be placed to other place and be called hust for specific form element 
		skipPointsToReadOnlyCleanup();
		
		String queryStr1 = "delete from answer_skip_rule spp where answer_value_id not in (select av_uuid from answer_value_form_id_vw where link_form_id =  spp.form_id)";
	    Query query1 = em.createNativeQuery(queryStr1);
	    query1.executeUpdate();
	    
	    //String queryStr2 = "delete from question_skip_rule spp where parent_id not in (select id from form_element)";
	    String queryStr2 = "delete from skip_rule spp where parent_id not in (select id from form_element union select id from form)";
	    Query query2 = em.createNativeQuery(queryStr2);
	    query2.executeUpdate();
	    
	    //Delete skips that do not have parts
	    String deleteSkips = "delete from question_skip_rule where id not in (select parent_id from answer_skip_rule)";
	    query = em.createNativeQuery(deleteSkips);
	    query.executeUpdate();
	   
	    
	}
	

	public void create(BaseSkipRule entity) {
		em.persist(entity);
		//	  return entity;
	}
	
	public void update(BaseSkipRule entity) {
	    em.merge(entity);
	//    return entity;
	}
	  
	public void save(BaseSkipRule entity) {
		if (entity.isNew())
			create(entity);
		else
			update(entity);
	}
	
	public void delete(BaseSkipRule entity) {
		em.remove(entity);
	}

//	public void delete(Long id)
//	{
//		 em.createQuery("DELETE FormElement fe WHERE fe.id = :Id")
//	        .setParameter("Id", id)
//	        .executeUpdate();
//	}
//	
	public BaseSkipRule getById(Long id)
	{
		Query query = em.createQuery("select fe from BaseSkipRule fe where id = :Id");
		query.setParameter("Id", id);
	    return (BaseSkipRule) query.getSingleResult();
	}
	

}
