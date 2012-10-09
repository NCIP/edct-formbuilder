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
package com.healthcit.cacure.web.controller.util;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.dao.BaseQuestionDao;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseQuestion;

/**
 * Controller run utilities in application context.
 * @author lkagan
 *
 */
@Controller
public class UtilController {

	@Autowired
	BaseQuestionDao questionDao;


	@RequestMapping(value="/util/multiplyAV.view")
	public ModelAndView multiplyAnswerValues(
			@RequestParam(value = "answerID", required = true) Long answerId,
			@RequestParam(value = "fromCnt", required = true) int fromCnt,
			@RequestParam(value = "toCnt", required = true) int toCnt)
	{

		BaseQuestion q = questionDao.getQuestionByAnswerID(answerId);
		
		Answer a = q.getAnswer();
		/* This doesn't make much sence now as  there is going to be one to one mapping between answer and question
		 * 
		 */
		/*
		Answer a = null;
		
		for (Answer curanswer: q.getAnswers())
		{
			if (curanswer.getUuid().equals(answerId))
			{
				a = curanswer;
				break;
			}
		}
		*/
		if (a != null)
		{
			// initialize template
			AnswerValue templateAv = a.getAnswerValues().get( a.getAnswerValues().size() -1);

			// start duplicating
			for (int i = fromCnt; i < toCnt; i++)
			{
				AnswerValue newAV = templateAv.clone();
				newAV.setOrd(newAV.getOrd() + 1);
				// see if description can be incremented
				try
				{
					long numericText = Long.parseLong(newAV.getDescription());
					newAV.setDescription(String.valueOf(numericText +1));
				}
				catch (NumberFormatException e) {}
				// see if value can be incremented
				try
				{
					long numericText = Long.parseLong(newAV.getValue());
					newAV.setValue(String.valueOf(numericText + 1));
				}
				catch (NumberFormatException e) {}
				a.addAnswerValues(newAV);
				templateAv = newAV;
			}

			// save the whole thing
			questionDao.save(q);
		}

		return null;
	}



}
