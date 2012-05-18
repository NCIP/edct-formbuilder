package com.healthcit.cacure.dao;
import java.util.List;

import javax.persistence.Query;

import com.healthcit.cacure.enums.ItemOrderingAction;
import com.healthcit.cacure.model.Answer;

public class AnswerDao extends BaseJpaDao<Answer, Long> 
{
	public AnswerDao()
    {
        super(Answer.class);
    }
	
	/**
	 * <b>answerId</b> is id of target item.
	 * @param answerId Long
	 * @param ordType ItemOrderingAction
	 * @return pair of two consecutive Answer items
	 */
	@SuppressWarnings("unchecked")
	public List<Answer> getAdjacentPairOfAnswers(Long answerId, ItemOrderingAction ordType) {
		String sign = (ordType == ItemOrderingAction.UP ? "<=" : ">=");
		String orderBy = (ordType == ItemOrderingAction.UP ? "DESC" : "ASC");
		String jpql = "select otherAnsw from Answer ordAnsw, Answer otherAnsw "
				+ "where ordAnsw.id = :answerId "
				+ "and otherAnsw.question.id = ordAnsw.question.id "
				+ "and otherAnsw.ord " + sign + " ordAnsw.ord "
				+ "order by otherAnsw.ord " +  orderBy;

		Query query = em.createQuery(jpql);
		query.setParameter("answerId", answerId);
		query.setMaxResults(2);
		return query.getResultList();
	}

	public void removeNotActualQuestionAnswers(Long questionId, Long validId)
    {
		Query query = em.createQuery("DELETE FROM Answer a WHERE a.question.id = :qid AND a.id != :aid");
		query.setParameter("qid", questionId);
		query.setParameter("aid", validId);
		query.executeUpdate();
    }

}
