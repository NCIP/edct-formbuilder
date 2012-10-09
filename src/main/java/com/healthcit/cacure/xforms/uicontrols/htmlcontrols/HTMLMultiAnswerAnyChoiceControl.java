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
package com.healthcit.cacure.xforms.uicontrols.htmlcontrols;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.jdom.Element;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.TableColumn;
import com.healthcit.cacure.model.TableElement;
import com.healthcit.cacure.xforms.XFormsUtils;

public class HTMLMultiAnswerAnyChoiceControl extends HTMLXFormUIControl {
	
	public HTMLMultiAnswerAnyChoiceControl(TableElement fe, QuestionAnswerManager qaManager)
	{
		super(fe, qaManager);
	}
	
	protected List<Element> getAnswerElements() {

		TableElement tableElement = (TableElement) formElement;
		List<Element> elemList = new ArrayList<Element>();
		/*Element table = new Element("span");
		table.setAttribute("class", "hcitSimpleTable");
		
		Element headingRow = new Element("span");
		*/
		Element htmlTable = new Element(TABLE_TAG);
		htmlTable.setAttribute("class", "hcitSimpleTable");
		htmlTable.setAttribute("cellspacing", "0");
		elemList.add(htmlTable);

		Element tHeadElem = new Element("thead");
		Element headerElem = new Element(ROW_TAG);
		tHeadElem.addContent(headerElem);

		List<TableColumn> columns = tableElement.getTableColumns();
//		 Build Table header 
		Element crossColumn = new Element("th"); 
		crossColumn.addContent("");
		crossColumn.setAttribute("class", "hcitHeaderCrossCell");
		headerElem.addContent(crossColumn);
		
		for(TableColumn tableColumn: columns) {
			Element column = new Element("th");
			column.setAttribute("class", "hcitColumnHeadingsCell");
			column.addContent( StringUtils.defaultIfEmpty( tableColumn.getHeading(), "Values") );
//			column.setAttribute("class", "hcitHeadingCell" );
			headerElem.addContent( column );
		}

		Element tBodyElem = new Element("tbody");

		Element rowElem = new Element(ROW_TAG);
//		heading
		Element rowHeadingElem = new Element(COLUMN_TAG);
		Element outputElem = new Element(OUTPUT_TAG, XFORMS_NAMESPACE);
		outputElem.setAttribute("ref", "text");
		rowHeadingElem.setAttribute("class", "hcitRowHeadingsCell");
		rowHeadingElem.addContent(outputElem);
//		columnHeadingElem.setAttribute("class", "hcitHeadingCell" );
		rowElem.addContent(rowHeadingElem);
		
		Element columnElem = new Element(COLUMN_TAG);
		columnElem.setAttribute("colspan", String.valueOf(columns.size()));
		Element inputElem = new Element(getSelectControlName(), XFORMS_NAMESPACE);
		inputElem.setAttribute("appearance", "full");
		inputElem.setAttribute("ref", "answer");
		Element itemsetElement = new Element("itemset", XFORMS_NAMESPACE);
		itemsetElement.setAttribute("nodeset", XFormsUtils.getXpathRef(XFormsUtils.getQuestionAnswerSetInstanceIDREF( tableElement.getUuid()), "/answer"));
		Element valueElem = new Element("value", XFORMS_NAMESPACE);
		valueElem.setAttribute("ref", ".");
		itemsetElement.addContent(valueElem);
		inputElem.addContent(itemsetElement);
		columnElem.addContent(inputElem);
		rowElem.addContent(columnElem);
			
		Element repeatElem = new Element(REPEAT_TAG, XFORMS_NAMESPACE);
		repeatElem.setAttribute("nodeset", XFormsUtils.getSimpleTableRowXPathRepeat(tableElement));
		repeatElem.setAttribute("id", XFormsUtils.getRepeatElementId(tableElement));
		repeatElem.addContent(rowElem);
		tBodyElem.addContent(repeatElem);
		
		htmlTable.addContent(tHeadElem);
		htmlTable.addContent(tBodyElem);

		// Add an empty group to the end to provide space between the table and the next element
		Element emptyGroup = new Element( GROUP_TAG, XFORMS_NAMESPACE );
		emptyGroup.setAttribute("class","hcitEmptyGroup");
		elemList.add( emptyGroup );
		
		return elemList;
	}

}
