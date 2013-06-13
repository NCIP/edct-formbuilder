/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.xforms.uicontrols.htmlcontrols;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.xwork.StringUtils;
import org.jdom.Attribute;
import org.jdom.Element;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.Answer;
import com.healthcit.cacure.model.Answer.AnswerType;
import com.healthcit.cacure.model.BaseQuestion;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.model.TableElement.TableType;
import com.healthcit.cacure.model.TableQuestion;
import com.healthcit.cacure.xforms.XFormsConstants;
import com.healthcit.cacure.xforms.XFormsConstructionException;
import com.healthcit.cacure.xforms.XFormsUIBuilder;
import com.healthcit.cacure.xforms.XFormsUtils;

public class HTMLMultiAnswerEntryControl extends HTMLXFormUIControl {

	public HTMLMultiAnswerEntryControl(TableElement fe,
			QuestionAnswerManager qaManager) {
		super(fe, qaManager);
	}

	@Override
	protected List<Element> getAnswerElements() {
		TableElement tableElement = (TableElement) formElement;
		List<Element> elemList = new ArrayList<Element>();
		Element htmlTable = new Element(TABLE_TAG);
		htmlTable.setAttribute("class", "hcitComplexTable");
		elemList.add(htmlTable);

		// Create repeat block
		// <xform:repeat nodeset="instance('FormDataInstance')/item" id="r1">

		Element tHeadElem = new Element("thead");
		Element headerElem = new Element(ROW_TAG);
		tHeadElem.addContent(headerElem);

		/* Build Table header */
		for (BaseQuestion baseQuestion : tableElement.getQuestions()) {
			TableQuestion question = (TableQuestion) baseQuestion;
			Element columnHeaderElem = new Element("th");
			columnHeaderElem.addContent(question.getDescription());
			columnHeaderElem.setAttribute("class", getAnswerLengthClass(question.getAnswer()));
			headerElem.addContent(columnHeaderElem);
		}

		Element tBodyElem = new Element("tbody");

		/* create rows for questions */
		Element repeatElem = new Element(REPEAT_TAG, XFORMS_NAMESPACE);
		repeatElem.setAttribute("nodeset",
				XFormsUtils.getComplexTableRowXPathRepeat(tableElement));
		repeatElem.setAttribute("id",
				XFormsUtils.getRepeatElementId(tableElement));

		Element rowElem = new Element(ROW_TAG);
		repeatElem.addContent(rowElem);
		tBodyElem.addContent(repeatElem);
		int counter = 1;
		TableType tableType = tableElement.getTableType();
		for (BaseQuestion baseQuestion : tableElement.getQuestions()) {
			TableQuestion question = (TableQuestion) baseQuestion;
			Element columnElem = new Element(COLUMN_TAG);
			
			Element inputElem;
			Answer answer = question.getAnswer();
			if (question.isIdentifying()) {
				if(TableType.DYNAMIC.equals(tableType)) {
					inputElem = renderDropdownColumn(question, counter);
				} else {
					inputElem = new Element(OUTPUT_TAG, XFORMS_NAMESPACE);
					inputElem.setAttribute("ref", "column[" + counter + "]/answer");
				}
				columnElem.setAttribute("class", StringUtils.join(new String[] {getAnswerLengthClass(answer), "firsColumn"}, " "));
			} else {
				columnElem.setAttribute("nowrap", "");
				if(answer.getType().equals(AnswerType.DROPDOWN)) {
					inputElem = renderDropdownColumn(question, counter);
				} else if(answer.getType().equals(AnswerType.CHECKMARK)) {
					inputElem = renderCheckmarkColumn(question, counter);
				} else {
					inputElem = new Element(INPUT_TAG, XFORMS_NAMESPACE);
					inputElem.setAttribute("ref", "column[" + counter + "]/answer");
				}
				columnElem.setAttribute("class", getAnswerLengthClass(answer));
			}
			inputElem.setAttribute("class", getBaseCssClass(answer));
			addSkips(question, inputElem);
			columnElem.addContent(inputElem);
			rowElem.addContent(columnElem);
			counter++;

		}
		if (tableElement.getTableType().equals(TableType.DYNAMIC))
		{
			Element plusControlTh = new Element("th");
			plusControlTh.addContent("");
			headerElem.addContent(plusControlTh);
			
			Element minusControlTh = new Element("th");
			minusControlTh.addContent("");
			headerElem.addContent(minusControlTh);
			
			Element triggerColumn1 = new Element(COLUMN_TAG);
			Element triggerColumn2 = new Element(COLUMN_TAG);
			Element insertElem = createInsertEvent(tableElement);
			Element deleteElem = createDeleteEvent(tableElement);
			Element deleteImageLabel = new Element("image");
			deleteImageLabel.setAttribute("src", "/FormBuilder/images/placeholder.gif");
			
			Element insertImageLabel = new Element("image");
			insertImageLabel.setAttribute("src", "/FormBuilder/images/placeholder.gif");
			insertImageLabel.setAttribute("class", "insert-table-row");
			Element deleteLabel = new Element(LABEL_TAG, XFORMS_NAMESPACE);
			deleteLabel.setAttribute("class", "delete-table-row");
			Element insertLabel = new Element(LABEL_TAG, XFORMS_NAMESPACE);
			insertLabel.setAttribute("class", "insert-table-row");

			triggerColumn1.addContent(createTrigger(insertLabel, tableElement,insertElem, XFormsUtils.getItemInsertTriggerBindID(tableElement)));
			rowElem.addContent(triggerColumn1);
			triggerColumn2.addContent(createTrigger(deleteLabel, tableElement, deleteElem, XFormsUtils.getItemDeleteTriggerBindID(tableElement)));
			rowElem.addContent(triggerColumn2);
		}
		htmlTable.addContent(tHeadElem);
		htmlTable.addContent(tBodyElem);

		/* trigger */
		// <xform:trigger>
		// <xform:label>Insert</xform:label>
		//
		// <xform:insert ev:event="DOMActivate"
		// nodeset="instance('FormDataInstance')/complex-table[@id='05ba7e09-a86d-46e8-8521-39987c44a53d']/row"
		// at="index('r1')" position="after"/>
		// <xform:setvalue ev:event="DOMActivate"
		// ref="instance('FormDataInstance')/complex-table[@id='05ba7e09-a86d-46e8-8521-39987c44a53d']/row[index('r1')]/column[1]"
		// ></xform:setvalue>
		// <xform:setvalue ev:event="DOMActivate"
		// ref="instance('FormDataInstance')/complex-table[@id='05ba7e09-a86d-46e8-8521-39987c44a53d']/row[index('r1')]/column[2]"
		// ></xform:setvalue>
		//
		// </xform:trigger>

		// Add an empty group to the end to provide space between the table and
		// the next element
		Element emptyGroup = new Element(GROUP_TAG, XFORMS_NAMESPACE);
		emptyGroup.setAttribute("class", "hcitEmptyGroup");
		elemList.add(emptyGroup);
		// }
		return elemList;
	}
	
	private Element createTrigger(Element label, TableElement tableElement, Element actionElement, String bindId)
	{
		Element trigger = new Element(TRIGGER_TAG, XFORMS_NAMESPACE);
		trigger.setAttribute("appearance", "minimal");
//		if(hideLast) {
		trigger.setAttribute(BIND_TAG, bindId);
//		}
		trigger.addContent(label);
		
		trigger.addContent(actionElement);
		return trigger;
	}
	private Element createInsertEvent(TableElement tableElement)
	{
		/* insert element */
		Attribute eventAttribute = new Attribute("event", "DOMActivate");
		eventAttribute.setNamespace(EVENTS_NAMESPACE);

		Attribute nodesetAttribute = new Attribute("nodeset",
				XFormsUtils.getComplexTableRowXPath(tableElement));

		Attribute atAttribute = new Attribute("at", "index('"
					+ XFormsUtils.getRepeatElementId(tableElement) + "')");

		Attribute positionAttribute = new Attribute("position", "after");

		Element insertElem = new Element(INSERT_TAG, XFORMS_NAMESPACE);
		insertElem.setAttribute(eventAttribute);
		insertElem.setAttribute(nodesetAttribute);
		insertElem.setAttribute(atAttribute);
		insertElem.setAttribute(positionAttribute);
		return insertElem;
	}

	private Element createDeleteEvent(TableElement tableElement)
	{
		/* insert element */
		Attribute eventAttribute = new Attribute("event", "DOMActivate");
		eventAttribute.setNamespace(EVENTS_NAMESPACE);

		Attribute nodesetAttribute = new Attribute("nodeset",
				XFormsUtils.getComplexTableRowXPath(tableElement));

		Attribute atAttribute = new Attribute("at", "index('"
					+ XFormsUtils.getRepeatElementId(tableElement) + "')");

		Element insertElem = new Element(DELETE_TAG, XFORMS_NAMESPACE);
		insertElem.setAttribute(eventAttribute);
		insertElem.setAttribute(nodesetAttribute);
		insertElem.setAttribute(atAttribute);
		return insertElem;
	}

	private Element createSetValueElement(TableElement tableElement, int index,
			String defaultValue) {
		Attribute eventAttribute = new Attribute("event", "DOMActivate");
		eventAttribute.setNamespace(EVENTS_NAMESPACE);

		Attribute refAttribute = new Attribute("ref",
				XFormsUtils.getComplexTableColumnXPath(tableElement, index));

		Element setvalueElem = new Element(SETVALUE_TAG, XFORMS_NAMESPACE);
		setvalueElem.setAttribute(eventAttribute);
		setvalueElem.setAttribute(refAttribute);
		setvalueElem.addContent(defaultValue);
		return setvalueElem;
	}

	protected String getSelect1ControlName() {
		return SELECT1_TAG;
	}	

	@Override
	protected String getSelectControlName() {
		return SELECT_TAG;
	}

	@Override
	protected String getBaseCssClass(Answer answer) {
		AnswerType answerType = answer.getType();
		if ( AnswerType.CHECKMARK.equals(answerType))
			return XFormsConstants.CSS_CLASS_ANSWER_CHECKBOX;
		else
			return answer.getType() == null ? "" : answer.getType().toString().toLowerCase();
	}

	@Override
	protected String getControlTextRef() {
		if (formElement instanceof TableElement) {
			return XFormsUtils
					.getTableQuestionTextXPath((TableElement) formElement);
		} else
			throw new XFormsConstructionException("Element is not a table '"
					+ formElement.getUuid() + "'");

	}

	private Element renderDropdownColumn(BaseQuestion question, int counter) {
		Answer answer = question.getAnswer();
		Element inputElem = new Element(getSelect1ControlName(),
				XFORMS_NAMESPACE);
		inputElem.setAttribute("ref", "column[" + counter + "]/answer");
		inputElem.setAttribute("appearance", "minimal");
		inputElem.setAttribute("class", getEntryCssClasses(answer));

		Element itemsElement = new Element("itemset", XFORMS_NAMESPACE);
		itemsElement.setAttribute("nodeset", XFormsUtils.getXpathRef(
				XFormsUtils.getQuestionAnswerSetInstanceIDREF(question
						.getUuid()), "/answer"));
		itemsElement.addContent(createRefLabel("@text",
				getCssLabelClass(answer)));
		Element valueElem = new Element("value", XFORMS_NAMESPACE);
		valueElem.setAttribute("ref", ".");
		itemsElement.addContent(valueElem);

		inputElem.addContent(itemsElement);
		return inputElem;
	}
	
	private Element renderCheckmarkColumn(BaseQuestion question, int counter){
		Answer answer = question.getAnswer();
		Element inputElem = new Element(getSelectControlName(),
				XFORMS_NAMESPACE);
		inputElem.setAttribute("ref", "column[" + counter + "]/answer");
		inputElem.setAttribute("appearance", "full");
		inputElem.setAttribute("class", getEntryCssClasses(answer));

		Element itemsElement = new Element("itemset", XFORMS_NAMESPACE);
		itemsElement.setAttribute("nodeset", XFormsUtils.getXpathRef(
				XFormsUtils.getQuestionAnswerSetInstanceIDREF(question
						.getUuid()), "/answer"));
		Element valueElem = new Element("value", XFORMS_NAMESPACE);
		valueElem.setAttribute("ref", ".");
		itemsElement.addContent(valueElem);

		inputElem.addContent(itemsElement);
		return inputElem;
	}
	
	@Override
	protected Element getAlertElement(final FormElement fe) {
		String alertMessage = formElement.isRequired() ?
				"if(" + XFormsUtils.getAnyIsEmptyAnswerConditionXPath(fe) + ",'" + ON_EMPTY_ANSWER_MSG	+ "','" + INCORRECT_FORMAT_MSG + "')" 
				: "'" + INCORRECT_FORMAT_MSG + "'";
				
		Element alertElement =
			XFormsUIBuilder.addChild(
			   XFormsUIBuilder.createElement( new Element(ALERT_TAG, XFORMS_NAMESPACE)),
			   XFormsUIBuilder.createElement( new Element(OUTPUT_TAG, XFORMS_NAMESPACE),
				 new Attribute[]{XFormsUtils.getAttribute("value", alertMessage, null)}));
		return alertElement;
	}
}
