package com.healthcit.cacure.web.tag;


import java.util.List;

import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.ArrayUtils;

import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.BaseQuestion.QuestionType;


/**
 * Custom tag for Answer Presenter.
 *
 * @author vetali, Suleman
 *
 */
public class IfMultiAnswerQuestionTag extends TagSupport {

	private static final long serialVersionUID = -2131617603353280289L;

    private FormElement element;
    private String[] supportedTypes = new String[]{ QuestionType.MULTI_ANSWER.name()};
	
    public void setElement(FormElement element)
    {
    	this.element = element;
    }
    
	@Override
	public int doStartTag(){

		if(element == null)
		{
			return SKIP_BODY;
		}
		List<? extends BaseQuestion> questions = element.getQuestions();
		if(questions != null && questions.size() >0)
		{
			String questionType = questions.get(0).getType().name();
		if ( ArrayUtils.contains( supportedTypes, questionType ) )
		{
    		return EVAL_BODY_INCLUDE;
		 }
		}
	     return SKIP_BODY;
	}
	@Override
	public int doEndTag()
	{
	    return EVAL_PAGE;	
	}
}
