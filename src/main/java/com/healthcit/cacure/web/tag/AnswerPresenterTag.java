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
package com.healthcit.cacure.web.tag;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.xwork.StringUtils;
import org.springframework.context.ApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.util.HtmlUtils;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.ExternalQuestion;
import com.healthcit.cacure.model.ExternalQuestionElement;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.TableColumn;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableElement.TableType;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.utils.Constants;

/**
 * Custom tag for Answer Presenter.
 *
 * @author vetali, Suleman
 *
 */
public class AnswerPresenterTag extends TagSupport {

	private static final int MAX_LETTERS_IN_OPTION_TEXT = 50;
	private static final String COMPLEX_TABLE_CLASS = "complexTableQuestionTable";
	private static final String SIMPLE_TABLE_CLASS = "simpleTableQuestionTable";
	private static final long serialVersionUID = -2131617603353280289L;
	private static final String QUOTE = "\"";
	private static final String BASE_START_ROW = "<tr><td align=\"left\" colspan=\"XYZ\"><span class=\"startRow\">";
	private static final String BASE_START_ROW_COLSPAN = "colspan=\"XYZ\"";
	private static final String START_ROW = BASE_START_ROW.replace( BASE_START_ROW_COLSPAN, "colspan=\"2\"" );
	private static final String END_ROW = "</span></td></tr>";
	public static final String PLEASE_SELECT_OPTION_TEXT = "Please Select...";

//	private List<Answer> answers;
//	private List<? extends BaseQuestion> questions;
	private FormElement formElement;
	private boolean htmlEscape;

	//	private Answer singleAnswer;
//	private List<AnswerValue> singleAnswerValues;
	private String styleClass;
	private String style;
	private Boolean canEdit = false;

	/**
	 * Returns whether or not this refers to a Table Question
	 * @author Oawofolu
	 * @return
	 */
	/*
	public boolean isTableQuestion()
	{
		Answer firstAnswer = getFirstAnswer();
		return ( firstAnswer == null ?
				false :
				( org.apache.commons.lang.StringUtils.containsIgnoreCase
						( firstAnswer.getQuestion().getType().name(), "TABLE" ) ));
	}
	*/

	/**
	 * Returns the first answer
	 * @author Oawofolu
	 * @return
	 */
	/*
	public Answer getFirstAnswer() {
		return ( org.apache.commons.collections.CollectionUtils.isEmpty( answers ) ? null : answers.get( 0 ));
	}
	*/
	public void setFormElement(FormElement formElement)
	{
		this.formElement = formElement;
	}
	
	public void setHtmlEscape(boolean htmlEscape) {
		this.htmlEscape = htmlEscape;
	}
/*
	public void setAnswers(List<Answer> answers) {
		this.answers = answers;
		// If this is NOT a Table Question, then set up the Single Answer and Single ANswer Values properties
		if ( !isTableQuestion() ) {
			Answer firstAnswer = getFirstAnswer();
			setSingleAnswer( firstAnswer );
			setSingleAnswerValues( firstAnswer == null ? new ArrayList<AnswerValue>() :firstAnswer.getAnswerValues() );
		}
	}
*/
	/*
	public void setSingleAnswer( Answer answer ) {
		this.singleAnswer = answer;
	}

	public void setSingleAnswerValues(List<AnswerValue> answerValues) {
		this.singleAnswerValues = answerValues;
	}
*/
	/*
	public void setStyleClass(String styleClass) {
		this.styleClass = styleClass;
	}

	public void setStyle(String style) {
		this.style = style;
	}
*/

	@Override
	public int doStartTag() throws JspException {
		try {

			FormElement fe = formElement;
			if(formElement instanceof LinkElement) {
				ApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(pageContext.getServletContext());
				fe = ctx.getBean(QuestionAnswerManager.class).getFantom(fe.getId());
			}
			
			String controlHtml = "";
			
			// TABLE Questions
			if ( fe.isTable() ) {
					controlHtml = processComplexControls(fe);
				}

			//Non-TABLE Questions
			else{
				Answer.AnswerType[] array =
					new Answer.AnswerType[]{ AnswerType.TEXT,
											 AnswerType.NUMBER,
											 AnswerType.INTEGER,
											 AnswerType.POSITIVE_INTEGER,
											 AnswerType.DATE,
											 AnswerType.YEAR,
											 AnswerType.MONTHYEAR,
											 AnswerType.CHECKBOX,
											 AnswerType.RADIO,
											 AnswerType.DROPDOWN,
											 AnswerType.TEXTAREA};
				
				if (ArrayUtils.contains(array, fe.getAnswerType())) {
					/*
					 * At this point we will be in this method only if
					 * FormElement is either QuestionElement,
					 * ExternalQuestionElement or LinkElement that is linked to
					 * one of the above
					 */
					List<? extends BaseQuestion> questions = fe.getQuestions();
					if (questions != null && questions.size() > 0) {
						BaseQuestion question = questions.get(0);
						controlHtml = processSimpleControls(fe,
								question.getAnswer());
					}
				} else {
					throw new JspException("Ansert type '" + fe.getAnswerType()
							+ "' is not handled. Please see '"
							+ this.getClass().getSimpleName() + "' to verify");
				}
			}

			pageContext.getOut().print(controlHtml);
		} catch (IOException ioe) {
			throw new JspTagException("Error: IOException while writing to the user");
		}
		return SKIP_BODY;
	}

	private String processSimpleControls(FormElement fe, Answer answer){

		StringBuilder input = new StringBuilder("<table>");
		
		if (fe.getAnswerType() == AnswerType.TEXT || fe.getAnswerType() == AnswerType.YEAR || fe.getAnswerType() == AnswerType.MONTHYEAR)
		{
			input.append(buildTextControlRow( answer.getFirstAnswerValue()));
		} else if ( fe.getAnswerType() == AnswerType.NUMBER 
				|| fe.getAnswerType() == AnswerType.INTEGER
				|| fe.getAnswerType() == AnswerType.POSITIVE_INTEGER ) {
			String inputControlId = "number." + answer.getFirstAnswerValue().hashCode();
			input.append(buildInputControl(inputControlId, "text", "number"));
		} else if ( fe.getAnswerType() == AnswerType.TEXTAREA ) {
			input.append(buildTextAreaControlRow(answer.getFirstAnswerValue()));
		} else if (fe.getAnswerType() == AnswerType.DATE )	{
			input.append( buildDateControlRow( answer.getFirstAnswerValue()) );
		} else if (fe.getAnswerType() == AnswerType.DROPDOWN) {
			input.append( buildDropdownControlRow( answer ) );
		} else {
			if ( fe.getAnswerType() == AnswerType.CHECKBOX )
			{
				input.append( buildCheckboxControlRow(answer) );
			}
			else if ( fe.getAnswerType() == AnswerType.RADIO )
			{
				input.append(buildRadioControlRow(answer));
			}
			/*
			for ( AnswerValue answerValue : answer.getAnswerValues() )
			{
				if ( fe.getAnswerType() == AnswerType.CHECKBOX )
				{
					input.append( buildCheckboxControlRow( answerValue ) );
				}
				else if ( fe.getAnswerType() == AnswerType.RADIO )
				{
					input.append(buildRadioControlRow( answerValue ));
			}
		}
			*/
		}

		input.append("</table>");

		return input.toString();
	}
	private String processComplexControls(FormElement formElement) {
		/* We only need to check if it's a link
		 *  as we already know that this is table 
		 */
		TableElement table = (TableElement) ((formElement instanceof LinkElement) ? ((LinkElement)formElement).getSourceElement() : formElement);
		if(TableType.SIMPLE.equals(table.getTableType())) {
			return processSimpleTable(table);
		} else if(TableType.STATIC.equals(table.getTableType()) || TableType.DYNAMIC.equals(table.getTableType())) {
			return processComplexTable(table);
		} else {
			throw new RuntimeException("Unknown table type \"" + table.getTableType() + "\"");
		}
	}

	private String processComplexTable(final TableElement table) {
		TableQuestion identifyingQuestion = null; 
		ArrayList<TableQuestion> tableQuestions = new ArrayList<TableQuestion>(); 
		for (BaseQuestion baseQuestion : table.getQuestions()) {
			TableQuestion tableQuestion = (TableQuestion)baseQuestion;
			if(tableQuestion.isIdentifying()) {
				identifyingQuestion = tableQuestion;
			} else {
				tableQuestions.add(tableQuestion);
			}
		}
		StringBuilder output = new StringBuilder("<table class='" + COMPLEX_TABLE_CLASS + "'>");
		if(TableType.STATIC.equals(table.getTableType())) {
			output.append("<tr><td></td>");
			for (TableQuestion tq : tableQuestions) {
				output.append(getColumnHeading(tq));
			}
			output.append("</tr>");
			if(identifyingQuestion != null) {
				output.append(getStaticTableRows(identifyingQuestion, tableQuestions));
			}
		} else if(TableType.DYNAMIC.equals(table.getTableType())) {
			output.append("<tr>");
			if(identifyingQuestion != null) {
				String description = htmlEscape ? HtmlUtils.htmlEscape(identifyingQuestion.getDescription()) : identifyingQuestion.getDescription();
				output.append("<td><b>").append(description).append("</b></td>");
			}
			for (TableQuestion tq : tableQuestions) {
				output.append(getColumnHeading(tq));
			}
			output.append("</tr>");
			output.append(getDynamicTableRow(identifyingQuestion, tableQuestions));
		}
		output.append("</table>");
		return output.toString();
	}

	private StringBuilder getColumnHeading(final TableQuestion table){
		StringBuilder input = new StringBuilder(100);
		String description = htmlEscape ? HtmlUtils.htmlEscape(table.getDescription()) : table.getDescription();
		input.append("<td>").append(description).append("</td>");
		return input;
	}
	
	private String getStaticTableRows(TableQuestion identifyingQuestion, final ArrayList<TableQuestion> tableQuestions) {
		StringBuilder output = new StringBuilder();
		List<AnswerValue> answerValues = identifyingQuestion.getAnswer().getAnswerValues();
		for (AnswerValue answerValue : answerValues) {
			String description = htmlEscape ? HtmlUtils.htmlEscape(answerValue.getDescription()) : answerValue.getDescription();
			output.append("<tr>");
			output.append("<td class=\"firsColumn\">").append(description).append("</td>");
			for (TableQuestion tq : tableQuestions) {
				output.append("<td nowrap>").append(buildControl(tq.getAnswer(), tq.getAnswer().hashCode() + "_" + answerValue.hashCode())).append("</td>");
			}
			output.append("</tr>");
		}
		return output.toString();
	}
	
	private String getDynamicTableRow(TableQuestion identifyingQuestion, final ArrayList<TableQuestion> tableQuestions) {
		StringBuilder output = new StringBuilder("<tr>");
		if(identifyingQuestion != null) {
			String identifyingControl = buildControl(identifyingQuestion.getAnswer(), String.valueOf(identifyingQuestion.getAnswer().hashCode()));
			output.append("<td class=\"firsColumn\">").append(identifyingControl).append("</td>");
		}
		for (TableQuestion tq : tableQuestions) {
			output.append("<td nowrap>").append(buildControl(tq.getAnswer(), String.valueOf(tq.getAnswer().hashCode()))).append("</td>");
		}
		output.append("</tr>");
		return output.toString();
	}
	
	private String processSimpleTable(final TableElement table) {
		List<TableColumn> tableColumns = table.getTableColumns();
		StringBuilder output = new StringBuilder("<table class='" + SIMPLE_TABLE_CLASS + "'>");
		output.append("<tr><td></td>");
		for(TableColumn tableColumn: tableColumns) {
			output.append(getColumnHeading(tableColumn));
		}
		output.append("</tr>");
		for(BaseQuestion question: table.getQuestions()) {
			output.append(getRow((TableQuestion)question, tableColumns.size()));
		}
		output.append("</table>");
		return output.toString();
	}

	private StringBuilder getColumnHeading(TableColumn column){
		StringBuilder input = new StringBuilder(100);
		input.append("<td>").append(column.getHeading()).append("</td>");
		return input;
	}

	private String getRow(TableQuestion question, int numberOfTableColumns){
		String description = htmlEscape ? HtmlUtils.htmlEscape(question.getDescription()) : question.getDescription();
		StringBuilder input = new StringBuilder("<tr><td class=\"firsColumn\">" + description + "</td>");
		Answer answer = question.getAnswer();
		for(int i = 0; i < numberOfTableColumns; i++){
			input.append("<td>").append( buildControl(question.getAnswer(), answer.hashCode() + "_" + i) ).append("</td>");
		}
		input.append("</tr>");
		return input.toString();
	}
	
	private String buildControl(final Answer answer, final String idSuffix) {
		String rowContent = "";
		String typeStr = answer.getType().name();
		if (StringUtils.equalsIgnoreCase(typeStr, "CHECKBOX") || StringUtils.equalsIgnoreCase(typeStr, "CHECKMARK")) {
			String inputControlId = "checkbox." + idSuffix;
			rowContent = buildInputControl(inputControlId, "checkbox");
		} else if (StringUtils.equalsIgnoreCase(typeStr, "RADIO")) {
			String inputControlId = "radio." + idSuffix;
			rowContent = buildInputControl(inputControlId, "radio");
		} else if (StringUtils.equalsIgnoreCase(typeStr, "TEXT")
				|| StringUtils.equalsIgnoreCase(typeStr, "MONTHYEAR")
				|| StringUtils.equalsIgnoreCase(typeStr, "YEAR")) {
			String inputControlId = "text." + idSuffix;
			rowContent = buildInputControl(inputControlId, "text");
		} else if(StringUtils.equalsIgnoreCase(typeStr, "NUMBER") || StringUtils.equalsIgnoreCase(typeStr, "INTEGER") || StringUtils.equalsIgnoreCase(typeStr, "POSITIVE_INTEGER")) {
			String inputControlId = "number." + idSuffix;
			rowContent = buildInputControl(inputControlId, "text", "number");
		} else if (StringUtils.equalsIgnoreCase(typeStr, "DATE")) {
			rowContent = buildDateControl("", idSuffix);
		} else if(StringUtils.equalsIgnoreCase(typeStr, "DROPDOWN")) {
			rowContent = buildDropdownControl(answer, idSuffix);
		}
		return rowContent;
	}
/*
	private String buildRadioControlMatrix(Answer answer) {
		String inputControlId =  "radio." + String.valueOf(answer.getGroupName());

		return buildInputControl(inputControlId, "radio");
	}

	private String buildCheckboxControlMatrix(Answer answer) {
		String inputControlId =  "radio." + String.valueOf(answer.getGroupName());

		return buildInputControl(inputControlId, "checkbox");
	}
*/

	private String buildRadioControlRow(Answer answer) {
		return buildControlRows(answer, "radio");
	}

	private String buildCheckboxControlRow(Answer answer) {
		return buildControlRows(answer, "checkbox");
	}
	
	private String buildControlRows(Answer answer, final String htmlInputType)
	{
		StringBuilder input = new StringBuilder(500);
		List<AnswerValue> answerValues = answer.getAnswerValues();
		if(StringUtils.equalsIgnoreCase( answer.getDisplayStyle(), Constants.HORIZONTAL )) {
			input.append("<tr valign=\"top\">");
			for(AnswerValue answerValue: answerValues)
			{
				input.append("<td align=\"left\">");
				input.append(buildInputControl(htmlInputType + "." + String.valueOf(answerValue.hashCode()), htmlInputType, null, answerValue.isDefaultValue()));
				input.append("</td><td>");
				input.append((htmlEscape ? HtmlUtils.htmlEscape(answerValue.getDescription()) : answerValue.getDescription()));
				if(canEdit && answerValues.size() > 1 && answer.getQuestion() instanceof ExternalQuestion) {
					input.append("</td><td>");
					input.append(buildAddRemoveSection(answerValue));
				}
				input.append("</td>");
			}
			input.append("</tr>");
		} else {
			for(AnswerValue answerValue: answerValues)
			{
				input.append("<tr valign=\"top\"><td align=\"left\">");
				input.append(buildInputControl(htmlInputType + "." + String.valueOf(answerValue.hashCode()), htmlInputType, null, answerValue.isDefaultValue()));
				input.append("</td><td>");
				input.append((htmlEscape ? HtmlUtils.htmlEscape(answerValue.getDescription()) : answerValue.getDescription()));
				if(canEdit && answerValues.size() > 1 && answer.getQuestion() instanceof ExternalQuestion) {
					input.append("</td><td>");
					input.append(buildAddRemoveSection(answerValue));
				}
				input.append("</td></tr>");
			}
		}
		return input.toString();
	}

	private String buildDateControlRow(AnswerValue answerValue)
	{
		StringBuilder input = new StringBuilder(START_ROW);
        input.append(buildDateControl(answerValue.getDescription(), String.valueOf(answerValue.hashCode())));
        input.append(END_ROW);
		return input.toString();
	}
	
	private String buildDateControl(String answerValueDescription, String valueId)
	{
		String inputControlId =  "date.input." + valueId;
		
		StringBuilder input = new StringBuilder();

		// add text field
		input.append(htmlEscape ? HtmlUtils.htmlEscape(answerValueDescription) : answerValueDescription).append(" ").append(buildInputControl(inputControlId, "text", "dateInput"));
		input.append("\n<button class='calendarImage'/>");
		//.append(END_ROW);

		return input.toString();
	}

	private String buildTextControlRow(AnswerValue answerValue)
	{
		String inputControlId =  "input." + String.valueOf(answerValue.hashCode());
		StringBuilder input = new StringBuilder(START_ROW);
		input.append((htmlEscape ? HtmlUtils.htmlEscape(answerValue.getDescription()) : answerValue.getDescription()) + " " + buildInputControl(inputControlId, "text")).append(END_ROW);
		return input.toString();
	}
	
	private String buildTextAreaControlRow(AnswerValue answerValue)
	{
		String inputControlId =  "textarea." + String.valueOf(answerValue.hashCode());
		StringBuilder input = new StringBuilder(START_ROW);
		input.append((htmlEscape ? HtmlUtils.htmlEscape(answerValue.getDescription()) : answerValue.getDescription()) + " " + buildTextAreaControl(inputControlId, "text")).append(END_ROW);
		return input.toString();
	}

	private String buildInputControl(final String controlId, final String inputType) {
		return buildInputControl(controlId, inputType, null);
	}
	
	private String buildInputControl(final String controlId, final String inputType, String className) {
		return buildInputControl(controlId, inputType, className, false);
	}
	
	private String buildInputControl(final String controlId, final String inputType, String className, boolean checked)
	{
		StringBuilder input = new StringBuilder(120);

		String classAndStyle = getClassAndStyle();
		input.append(" <input type=").append(QUOTE).append(inputType).append(QUOTE)
			.append(" readonly=").append(QUOTE).append("readonly").append(QUOTE)
			.append(" id=").append(QUOTE).append(controlId).append(QUOTE)
			.append(" name=").append(QUOTE).append(controlId).append(QUOTE)
			.append(" class=").append(QUOTE).append(className != null ? (classAndStyle.trim().length() == 0 ? "" : " ") + className : classAndStyle).append(QUOTE);
		
		if(checked) {
			input.append(" checked=").append(QUOTE).append("checked").append(QUOTE);
		}

		input.append(" />");

		return input.toString();
	}
	
	private String buildTextAreaControl(String controlId, String inputType)
	{
		StringBuilder input = new StringBuilder(120);

		input.append(" <br/><textarea id=").append(QUOTE).append(controlId).append(QUOTE)
			.append(" name=").append(QUOTE).append(controlId).append(QUOTE)
			.append(" value=").append(QUOTE).append("").append(QUOTE) // do not display value
			.append(getClassAndStyle());

		input.append(" ></textarea>");

		return input.toString();
	}

	private String buildDropdownControl(final Answer answer, final String idSuffix) {
		return buildDropdownControl(answer, idSuffix, "");
	}
	
	private String buildDropdownControl(final Answer answer, final String idSuffix, final String value) {
		List<AnswerValue> answerValues = answer.getAnswerValues();
		String controlId =  "select." + idSuffix;
		StringBuilder input = new StringBuilder();
		input.append(" <select ")
//		.append(" multiple=").append(QUOTE).append("false").append(QUOTE)
		.append(" id=").append(QUOTE).append(controlId).append(QUOTE)
		.append(" name=").append(QUOTE).append(controlId).append(QUOTE)
		.append(getClassAndStyle());

		input.append(" >");

		if(answer.getQuestion().getParent().getForm().getModule().isShowPleaseSelectOptionInDropDown()) {
			input.append("<option value=\"\">" + PLEASE_SELECT_OPTION_TEXT + "</option>");
		}
		for (AnswerValue av: answerValues)
		{
			String pdesc = htmlEscape ? HtmlUtils.htmlEscape(av.getDescription().length() > MAX_LETTERS_IN_OPTION_TEXT ? av.getDescription().substring(0, MAX_LETTERS_IN_OPTION_TEXT) + "..." : av.getDescription()) : av.getDescription();
			String ptitle = av.getDescription().length() > MAX_LETTERS_IN_OPTION_TEXT ? 
					(htmlEscape ? HtmlUtils.htmlEscape(av.getDescription()) : av.getDescription()) 
					: null;
			
			input.append("<option ")
//			.append(" label=").append(QUOTE).append(av.getName()).append(QUOTE)
			.append(" value=").append(QUOTE).append(av.getValue()).append(QUOTE);
			if(org.apache.commons.lang.StringUtils.isNotBlank(ptitle)) {
				input.append(" title=").append(QUOTE).append(ptitle).append(QUOTE);
			}
			if(value != null && value.equals(av.getValue())) {
				input.append(" selected=").append(QUOTE).append("selected").append(QUOTE);
			}
			input.append(">")
			.append(pdesc)
			.append("</option>");

		}
		input.append("</select>");
		return input.toString();
	}
	
	private String buildDropdownControlRow(Answer answer) {
		StringBuilder input = new StringBuilder(START_ROW);
		List<AnswerValue> answerValues = answer.getAnswerValues();
		String defaultValue = "";
		if(answerValues != null) {
			for (AnswerValue answerValue : answerValues) {
				if(answerValue.isDefaultValue()) {
					defaultValue = answerValue.getValue();
				}
			}
		}
		input.append(buildDropdownControl(answer, String.valueOf(answer.getUuid()), defaultValue)).append(END_ROW);
		return input.toString();
	}

	private String getClassAndStyle()
	{
		StringBuilder sb = new StringBuilder();
		if (styleClass != null && styleClass.length() > 0)
			sb.append(" class=").append(QUOTE).append(styleClass).append(QUOTE);

		if (style != null && style.length() > 0)
			sb.append(" style=").append(QUOTE).append(style).append(QUOTE);

		return sb.toString();

	}

	public Boolean getCanEdit() {
		return canEdit;
	}

	public void setCanEdit(Boolean canEdit) {
		this.canEdit = canEdit;
	}
	private String buildAddRemoveSection( AnswerValue answerValue ) {
		FormElement fe = answerValue.getAnswer().getQuestion().getParent();
		if(!(fe instanceof ExternalQuestionElement)) {
			throw new RuntimeException("Wrong argument. External question expected.");
		}
		ExternalQuestionElement externalFe = (ExternalQuestionElement) fe;
		String answerExternalId = answerValue.getExternalId();
		String start = "<a href=\"#\" class=\"noticelink skipRemoveAns\" onclick=\"addRemoveAnswerValue(this)\" ";
		StringBuilder html = new StringBuilder( start );
		html.append("id=\"addRem.").append( answerExternalId ).append("\"");
		html.append( "\">REMOVE</a>" );
		html.append("<input type=\"hidden\" id=\"addOrRemQuestion.").append( answerExternalId ).append("\"");
		html.append(" value=\"").append( externalFe.getExternalUuid() ).append("\" />");
		return html.toString();
	}

}
