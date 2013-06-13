/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.tag;

import java.util.EnumSet;
import java.util.List;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.ArrayUtils;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableElement.TableType;

/**
 * Custom tag for Answer Presenter.
 *
 * @author vetali, Suleman
 *
 */
public class IfSelectTypeQuestionTag extends TagSupport {

	private static final long serialVersionUID = -2131617603353280289L;

    private FormElement element;
    
    private EnumSet<AnswerType> supportedTypes = EnumSet.of( 
    		AnswerType.DROPDOWN,
    		AnswerType.CHECKBOX,
    		AnswerType.RADIO);
	
    public void setQuestion(FormElement element)
    {
    	this.element = element;
    }
    
	@Override
	public int doStartTag() throws JspException {

		if(element != null)	{
			//TODO Optimize
			FormElement srcElement = element;
			if(element instanceof LinkElement) {
				srcElement = ((LinkElement) element).getSourceElement();
			}
			if(!(srcElement instanceof TableElement && TableType.DYNAMIC.equals(((TableElement)srcElement).getTableType()))) {
				List<? extends BaseQuestion> questions = srcElement.getQuestions();
				if(questions != null) {
					for (BaseQuestion question : questions) {
						if(supportedTypes.contains(question.getAnswer().getType())) {
							return EVAL_BODY_INCLUDE;
						}
					}
				}
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
