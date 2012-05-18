package com.healthcit.cacure.web.tag;

import java.io.IOException;
import java.util.EnumSet;
import java.util.List;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;

import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.AnswerValue;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.TableQuestion;

/**
 * Custom tag for Answer Presenter.
 *
 * @author vetali, Suleman
 *
 */
public class SkipPresenterTag extends TagSupport {

	private static final long serialVersionUID = -2131617603353280289L;
	private static final String QUOTE = "\"";
	private static final String START_ROW = "<tr><td align=\"left\" colspan=\"2\"><span class=\"aswerText\">";
	private static final String END_ROW = "</span></td></tr>";


//	private List<Answer> answers;
//	private Answer singleAnswer;
//	private List<AnswerValue> singleAnswerValues;
	private String styleClass;
	private String style;
//	private int columnCtr = 0;
//	private Long questionId;
//	private String type = "question";
	private FormElement element;


	/**
	 * Returns whether or not an answer exists
	 * @author Oawofolu
	 */
	public boolean hasAnyAnswers(){
		return org.apache.commons.collections.CollectionUtils.isNotEmpty( element.getQuestions() );
	}

	public void setElement(FormElement element) {
		this.element = element;
/*		// If this is NOT a Table Question, then set up the Single Answer and Single ANswer Values properties
		if ( !element.isTable() ) {
			BaseQuestion firstQuestion = getFirstQuestion();
			setSingleAnswer( firstAnswer );
			setSingleAnswerValues( firstAnswer == null ? new ArrayList<AnswerValue>() :firstAnswer.getAnswerValues() );
		}
		*/
	}

/*	public void setSingleAnswer( Answer answer ) {
		this.singleAnswer = answer;
	}

	public void setSingleAnswerValues(List<AnswerValue> answerValues) {
		this.singleAnswerValues = answerValues;
	}
*/
	public void setStyleClass(String styleClass) {
		this.styleClass = styleClass;
	}

	public void setStyle(String style) {
		this.style = style;
	}

	@Override
	public int doStartTag() throws JspException {
		try {

			String controlHtml = "";

			if ( hasAnyAnswers() ) {
				controlHtml = processSimpleControls();
			}

			System.out.println("controlHtml " + controlHtml);
			pageContext.getOut().print(controlHtml);
		} catch (IOException ioe) {
			throw new JspTagException("Error: IOException while writing to the user");
		}
		return SKIP_BODY;
	}

	private String processSimpleControls()
	{
    	List<? extends BaseQuestion> questions = element.getQuestions();
    	String start ="<table>";
    	StringBuilder input = new StringBuilder(start);
    	
    	EnumSet<AnswerType> supportedTypes = EnumSet.of( 
        		AnswerType.DROPDOWN,
        		AnswerType.CHECKBOX,
        		AnswerType.RADIO);
    	for (BaseQuestion question : questions) {
			Answer answer = question.getAnswer();
			if(supportedTypes.contains(answer.getType())) {
				if(question instanceof TableQuestion) {
					input.append(START_ROW);
					input.append("<th>");
					input.append(((TableQuestion)question).getDescription());
					input.append("</th>");
					input.append(END_ROW);
				}
				List<AnswerValue> answerValues = answer.getAnswerValues();
				for ( AnswerValue answerValue : answerValues ){
					input.append(buildCheckboxControlRow( answerValue, element.getId() ));
				}
			}
		}

		input.append("</table>");

		return input.toString();
	}
	
	/*private String processComplexControls(){

		this.columnCtr = 0;
		return buildMatrix();
	}*/

	/*
	private String buildMatrix() {

	   	String QuestionDesc = "";

    	for( Answer answer: answers ) {
    		QuestionDesc = answer.getQuestion().getParent().getDescription();
    		if(questionId != null && answer.getQuestion().getId().compareTo(questionId) == 0 ){
    			return "";
    		}
    		break;
    	}

		String start = "<tr>" +
		   "<td valign='top'>" +
				"<div class='questionListQuestion'>" +
					"<div class='questionListQuestionText'>" + QuestionDesc + "</div>" +
				"</div>" +
				"<div class='clearfloat'></div>" +
				"<table>";

		StringBuilder input = new StringBuilder(start);

		for(Answer ans1: answers){
			input.append(getColumnHeadings(ans1));
			break;
		}

		for(Answer ans2: answers){
			input.append(getRow(ans2));
		}

		input.append("</td></tr></table>");

		return input.toString();
	}

	private String getColumnHeadings(Answer answer){

		StringBuilder input = new StringBuilder("<tr><td><td>");
		columnCtr++;

		List<AnswerValue> answerValues = answer.getAnswerValues();

		for(AnswerValue av: answerValues){
			input.append("<td>").append(av.getDescription()).append("</td>");
			columnCtr++;
		}

		input.append("</tr>");
		return input.toString();
	}

	private String getRow(Answer answer){

		StringBuilder input = new StringBuilder("<tr><td>" + answer.getDescription() + "<td>");

		List<AnswerValue> answerValues = answer.getAnswerValues();
		String rowContent = "";
		boolean checkboxRow = StringUtils.equalsIgnoreCase( answer.getType().name(), "CHECKBOX" );
		boolean radioRow    = StringUtils.equalsIgnoreCase( answer.getType().name(), "RADIO" );
		//for(int i=1; i<columnCtr; i++){
		for(AnswerValue av: answerValues){
			input.append("<td>");
			if ( checkboxRow ) input.append(buildCheckboxControlMatrix(av));
			if ( radioRow ) input.append(buildRadioControlMatrix(av));
			input.append("</td>");			
		}		
		input.append("<td>").append( rowContent ).append("</td>");

		input.append("</tr>");
		return input.toString();

	}

	private String buildRadioControlMatrix(AnswerValue answerValue) {

		String altText = "Show this " + this.type + " when Answer: &quot;" + answerValue.getAnswer().getDescription() + "&quot; with value " + answerValue.getDescription() + " for Question: &quot;" + answerValue.getAnswer().getQuestion().getParent().getDescription() + "&quot; is selected.";
		String inputControlId =  "radio." + String.valueOf(answerValue.getAnswer().getGroupName());

		return buildInputControlMatrix(inputControlId, "radio", answerValue.getPermanentId(), altText, answerValue.getDescription());
	}
	
	private String buildCheckboxControlMatrix(AnswerValue answerValue) {

		String altText = "Show this " + this.type + " when Answer: &quot;" + answerValue.getAnswer().getDescription() + "&quot; with value " + answerValue.getDescription() + " for Question: &quot;" + answerValue.getAnswer().getQuestion().getParent().getDescription() + "&quot; is selected.";
		String inputControlId =  "checkbox." + String.valueOf(answerValue.getAnswer().getGroupName());

		return buildInputControlMatrix(inputControlId, "checkbox", answerValue.getPermanentId(), altText, answerValue.getDescription());
	}

	private String buildRadioControlRow(AnswerValue answerValue) {

		long questionId = answerValue.getAnswer().getQuestion().getId();
		String altText = "Show this " + this.type + " when Answer: &quot;" + answerValue.getDescription() + "&quot; for Question: &quot;" + answerValue.getAnswer().getQuestion().getParent().getDescription() + "&quot; is selected.";
		String inputControlId =  "radio." + String.valueOf(answerValue.getId());
		StringBuilder input = new StringBuilder(START_ROW);
		input.append(buildInputControl(inputControlId, "radio", answerValue.getPermanentId(), altText, answerValue.getDescription(), questionId) + " " + answerValue.getDescription()).append(END_ROW);
		return input.toString();
	}
	*/
	private String buildCheckboxControlRow(AnswerValue answerValue, long elementId) {

//		long questionId = answerValue.getAnswer().getQuestion().getId();
		//String altText = "Show this " + this.type + " when Answer: &quot;" + answerValue.getDescription() + "&quot; for Question: &quot;" + answerValue.getAnswer().getQuestion().getDescription() + "&quot; is selected.";
	//	String altText = "&quot;" + answerValue.getAnswer().getQuestion().getParent().getDescription() + "&quot;";
		String altText = answerValue.getAnswer().getQuestion().getParent().getDescription();
		//String inputControlId =  "radio." + String.valueOf(answerValue.getId());
		String inputControlId =  answerValue.getPermanentId();
		StringBuilder input = new StringBuilder(START_ROW);
		input.append(buildInputControl(inputControlId, "checkbox", answerValue.getPermanentId(), altText, answerValue.getDescription(), elementId) + " " + answerValue.getDescription()).append(END_ROW);
		return input.toString();
	}

	private String buildInputControl(String controlId, String inputType, String answerValuePermanentId, String alt, String answerDesc, long questionId )
	{
		StringBuilder input = new StringBuilder(120);

		input.append(" <input type=").append(QUOTE).append(inputType).append(QUOTE)
		     .append(" id=").append(QUOTE).append(answerValuePermanentId).append(QUOTE)
			.append(" name=").append(QUOTE).append(questionId).append(QUOTE)
			.append(" value=").append(QUOTE).append(answerDesc).append(QUOTE).append(" ").append("onclick='return highlightQuestionDiv(this);'")//.append("onclick='return disableOtherSkipQuestions(this);'")
			.append(" alt=").append(QUOTE).append(alt).append(QUOTE);

		if (styleClass != null && styleClass.length() > 0)
			input.append(" class=").append(QUOTE).append(styleClass).append(QUOTE);

		if (style != null && style.length() > 0)
			input.append(" style=").append(QUOTE).append(style).append(QUOTE);

		input.append(" />");

		return input.toString();
	}
/*
	private String buildInputControlMatrix(String controlId, String inputType, String answerValuePermanentId, String alt, String answerDesc )
	{
		StringBuilder input = new StringBuilder(120);

		input.append(" <input type=").append(QUOTE).append(inputType).append(QUOTE)
			.append(" id=").append(QUOTE).append(controlId).append(QUOTE)
//			.append(" name=").append(QUOTE).append(answerDesc).append(QUOTE)
			.append(" name=").append(QUOTE).append(this.questionId).append(QUOTE)
			.append(" value=").append(QUOTE).append(answerValuePermanentId).append(QUOTE).append(" ").append("onclick='return addSkipBlock(this);'")
			.append(" alt=").append(QUOTE).append(alt).append(QUOTE);

		if (styleClass != null && styleClass.length() > 0)
			input.append(" class=").append(QUOTE).append(styleClass).append(QUOTE);

		if (style != null && style.length() > 0)
			input.append(" style=").append(QUOTE).append(style).append(QUOTE);

		input.append(" />");

		return input.toString();
	}

	public Long getQuestionId() {
		return questionId;
	}

	public void setQuestionId(Long questionId) {
		this.questionId = questionId;
	}
	
	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}
*/

}
