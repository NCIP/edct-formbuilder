/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.xforms.uicontrolfactory;

import java.util.LinkedList;
import java.util.List;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.ContentElement;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.QuestionElement;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.BaseQuestion.QuestionType;
import com.healthcit.cacure.model.TableElement.TableType;
import com.healthcit.cacure.xforms.XFormsConstructionException;
import com.healthcit.cacure.xforms.XFormsConstants.SubmissionControls;
import com.healthcit.cacure.xforms.uicontrols.XFormUIControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLFormTitleControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLMultiAnswerEntryControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLMultiAnswerMultiChoiceControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLMultiAnswerSingleChoiceControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLSingleAnswerEntryControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLSingleAnswerMultiChoiceControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLSingleAnswerSingleChoiceControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLSubmissionControl;
import com.healthcit.cacure.xforms.uicontrols.htmlcontrols.HTMLXFormContent;

public class XFormHTMLFactory extends BaseXFormUIControlFactory{

	public XFormHTMLFactory(){}

	@Override
	public XFormUIControl createXFormUIControl(FormElement fe, QuestionAnswerManager qaManager)
	{
		XFormUIControl xformControl = null;
		if(fe instanceof LinkElement)
		{
			//Handle the source asset instead of the link.
			fe = ((LinkElement)fe).getSourceElement();
		}
		if(fe.isPureContent())
		{
			xformControl =  new HTMLXFormContent( (ContentElement)fe,  qaManager);
		}
		else if(fe.isTable())
		{
			TableType tableType = ((TableElement)fe).getTableType();
			if(tableType.equals(TableType.SIMPLE))
			{
				AnswerType type = ((TableElement)fe).getAnswerType();
				if (type.equals(AnswerType.RADIO )) {
					xformControl =  new HTMLMultiAnswerSingleChoiceControl( (TableElement)fe, qaManager);
				}
				else if ( type.equals(AnswerType.CHECKBOX )) {
					// TODO: Implement MultiAnswerMultiChoice constructor for checkboxes
					xformControl =  new HTMLMultiAnswerMultiChoiceControl( (TableElement)fe, qaManager);
				}
				
			}
			else if(tableType.equals(TableType.DYNAMIC) || tableType.equals(TableType.STATIC))
			{
				xformControl =  new HTMLMultiAnswerEntryControl( (TableElement)fe, qaManager);
			}
			//			else if (type.equals(AnswerType.TEXT )) {
//				xformControl =  new HTMLMultiAnswerEntryControl( (TableElement)fe, qaManager);
//			}
//			else if (type.equals(AnswerType.DATE )) {
//				xformControl =  new HTMLMultiAnswerEntryControl( (TableElement)fe, qaManager);
//			}
//			else if (type.equals(AnswerType.NUMBER )) {
//				xformControl =  new HTMLMultiAnswerEntryControl( (TableElement)fe, qaManager);
//			}
//			else if (type.equals(AnswerType.YEAR )) {
//				xformControl =  new HTMLMultiAnswerEntryControl( (TableElement)fe, qaManager);
//			}
			else {
				throw new XFormsConstructionException("Invalid table type for the table '" + fe.toString() + "'");
			}
		}
		else 
		{
			BaseQuestion q = null;
			if (fe instanceof QuestionElement)
			{
				q = ((QuestionElement)fe).getQuestion();
			}
			else if (fe instanceof ExternalQuestionElement)
			{
				q = ((ExternalQuestionElement)fe).getQuestion();
			}
			else
			{
				throw new XFormsConstructionException("Invalid form element type '" + fe.toString() + "'");
			}
			Answer a = q.getAnswer();
		if (a == null)
			throw new XFormsConstructionException("No answers exist for question '" + q.getShortName() + "' id:" + q.getId());
			
		if (q.getType() == QuestionType.SINGLE_ANSWER)
		{
			if (a.getType() == AnswerType.RADIO || a.getType() == AnswerType.DROPDOWN )
					xformControl = new HTMLSingleAnswerSingleChoiceControl( fe, qaManager);
			else
					xformControl = new HTMLSingleAnswerEntryControl( fe, qaManager);
		}
		else if (q.getType() == QuestionType.MULTI_ANSWER)
		{
			if (a.getType() == AnswerType.CHECKBOX)
					xformControl = new HTMLSingleAnswerMultiChoiceControl( fe, qaManager);
			else
				throw new XFormsConstructionException("Invalid answer type '" + a.getType().toString() + "'");
		}
			}
		return xformControl;
			}

	@Override
	public XFormUIControl createSubmissionControl(SubmissionControls submissionControls)
	{

		return new HTMLSubmissionControl(submissionControls);
	}



	@Override
	public XFormUIControl createFormTitleControl()
	{
		return new HTMLFormTitleControl();
	}


	@SuppressWarnings("rawtypes")
	@Override
	public List createCustomJSScripts()
	{
//		List content = XFormsUtils.parseStringAsXML(XFormsConstants.XFORMS_HTML_SCRIPT_PATH );
//		return content;
		return new LinkedList();
	}
}
