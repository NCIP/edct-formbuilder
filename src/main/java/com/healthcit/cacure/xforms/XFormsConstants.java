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
package com.healthcit.cacure.xforms;

import org.jdom.Namespace;

/**
 * Using interface instead of class - so I don't have to use class name every time I use the constant
 * @author lkagan
 *
 */
public interface XFormsConstants
{

	public enum SubmissionControls {
		SAVE( "Save", "SendDataElement"),
		SAVEFORLATER( "Save For Later", "PartialSendDataElement");

		/**
		 * The label for the control
		 */
		private final String label;

		/**
		 * The idref for the control
		 */
		private final String idref;
		
		private SubmissionControls( String label, String idref) {
			this.label = label;
			this.idref = idref;
		}

		public String getLabel() {
			return label;
		}

		public String getIdRef() {
			return idref;
		}
	}
	public enum HTMLSubmissionControls {
		SAVE("hcit-save-button"),
		SAVEFORLATER("hcit-save-for-later-button");

		/**
		 * The css class for the control
		 */
		private final String cssClass;
		
		private HTMLSubmissionControls( String cssClass) {
			this.cssClass = cssClass;
		}

		public String getCssClass() {
			return cssClass;
		}
	}

	// XForms model-related tags
	public static final String INSTANCE_TAG = "instance";
	public static final String MODEL_TAG = "model";
	public static final String BIND_TAG = "bind";
	public static final String SUBMISSION_TAG = "submission";
	public static final String RESOURCE_TAG = "resource";
	public static final String SUBMIT_TAG = "submit";
	public static final String MESSAGE_TAG = "message";
	public static final String LOOKUP_OPTIONS_TAG = "options";
	public static final String TRIGGER_TAG = "trigger";
	public static final String SWITCH_TAG = "switch";
	public static final String CASE_TAG = "case";
	public static final String TOGGLE_TAG = "toggle";
	public static final String SETVALUE_TAG = "setvalue";
	public static final String ACTION_TAG = "action";
	public static final String ALERT_TAG = "alert";
	public static final String LOAD_TAG = "load";
	public static final String SPAN_TAG = "span";
	public static final String TABLE_TAG = "table";
	public static final String ROW_TAG = "tr";
	public static final String COLUMN_TAG = "td";
	public static final String INSERT_TAG = "insert";
	public static final String DELETE_TAG = "delete";
	
	// Custom model-related tags
	public static final String LEARNMORE_TAG = "learn-more";
	public static final String CONTENT_TAG = "pure-content";
	public static final String DATAGROUP_TAG = "data-group";
	public static final String CROSSFORMSKIP_TAG = "cross-form-skip";
	public static final String ACTIONBASEURL_TAG = "base-url";
	public static final String ACTIONFULLURL_TAG = "full-url";
	public static final String ERROR_TAG = "error";
	public static final String ITEM_DELETE_MODEL_TAG = "item-delete-trigger";
	public static final String ITEM_INSERT_MODEL_TAG = "item-insert-trigger";

	// ui-related tags
	public static final String GROUP_TAG = "group";
	public static final String OUTPUT_TAG = "output";
	public static final String INPUT_TAG = "input";
	public static final String TEXTAREA_TAG = "textarea";
	public static final String REPEAT_TAG = "repeat";
	public static final String LABEL_TAG = "label";
	public static final String VALUE_TAG = "value";
	public static final String SELECT_TAG = "select";
	public static final String SELECT1_TAG = "select1";
	public static final String SELECTION_ITEM_TAG = "item";
	public static final String HELP_TAG = "help";
	
	// other tags
	public static final String SCRIPT_TAG = "script";

	// UI CSS class names
	public static final String XFORMS_REQUIRED_ICON_CSS_CLASS = "xforms-required-icon";
    public static final String HORIZONTAL_CSS_CLASS = "hcit-horizontal-align";
    public static final String VERTICAL_CSS_CLASS = "hcit-vertical-align";
    public static final String XFORMS_TEXTAREA_CSS_CLASS = "hcit-textarea";
	public static final String LENGTH_SHORT = "Short";
	public static final String LENGTH_MEDIUM = "Medium";
	public static final String LENGTH_LONG = "Long";
	public static final String LENGTH_SHORT_CSS_CLASS_PREFIX = "hcit-field-width-short-";
	public static final String LENGTH_MEDIUM_CSS_CLASS_PREFIX = "hcit-field-width-medium-";
	public static final String LENGTH_LONG_CSS_CLASS_PREFIX = "hcit-field-width-long-";
	public static final String LABEL_INPUT_CSS_CLASS_PREFIX = "hcit-label-input-";
	public static final String GROUP_INPUT_CSS_CLASS_PREFIX = "hcit-group-input-";
	public static final String FORM_TITLE_CSS_CLASS = "hcit-form-title";
	
	public static final String CSS_CLASS_LEANRMORE = "hcitLearnMore";
	public static final String CSS_CLASS_HAS_LEANRMORE = "hcitHasLearnMore";
	public static final String CSS_CLASS_QUESTION_TEXT = "hcitQuestionText";
	public static final String CSS_CLASS_REQUIRED_QUESTION = "hcitRequiredQuestionText";

	public static final String CSS_CLASS_ANSWER_ENTRY = "hcitAnswerText";

	public static final String CSS_CLASS_ANSWER_RADIO = "hcitAnswerRadio";
	public static final String CSS_CLASS_ANSWER_CHECKBOX = "hcitAnswerCheckbox";
	
	// initialize namespaces
	public static final String XFORM_NS_PREFIX_NO_COLUMN = "xform";
	public static final String XFORM_NS_PREFIX = XFORM_NS_PREFIX_NO_COLUMN + ":";
	public static final String DOMEVENT_NS_PREFIX_NO_COLUMN = "ev";
	public static final String DOMEVENT_NS_PREFIX = DOMEVENT_NS_PREFIX_NO_COLUMN + ":";
	public static final String HCIT_NS_PREFIX_NO_COLUMN = "hcitT";
	public static final String HCIT_NS_PREFIX = HCIT_NS_PREFIX_NO_COLUMN + ":";
	public static final String XML_TYPE_PREFIX = "xform:";
	

	public static final Namespace XFORMS_NAMESPACE = Namespace.getNamespace(XFORM_NS_PREFIX_NO_COLUMN, "http://www.w3.org/2002/xforms");
	public static final Namespace EVENTS_NAMESPACE = Namespace.getNamespace(DOMEVENT_NS_PREFIX_NO_COLUMN, "http://www.w3.org/2001/xml-events");
	public static final Namespace XSD_NAMESPACE = Namespace.getNamespace("xsd", "http://www.w3.org/2001/XMLSchema");
	public static final Namespace XHTML_NAMESPACE = Namespace.getNamespace("", "http://www.w3.org/1999/xhtml");
	public static final Namespace HCIT_NAMESPACE = Namespace.getNamespace(HCIT_NS_PREFIX_NO_COLUMN, "http://www.healthcit.com/2010/formbuilder");
	
	// XForms special attributes/attribute values
	public static final String XFORMS_HELP_ATTRIBUTE = "xforms-help";
	public static final String XFORMS_MESSAGE_MODAL_LEVEL = "modal";
	public static final String XFORMS_MESSAGE_EPHEMERAL_LEVEL = "ephemeral";
	public static final String XFORMS_MESSAGE_MODELESS_LEVEL = "modeless";
	public static final String XFORMS_DOMACTIVATE_EVENT = "DOMActivate";
	public static final String XFORMS_VALUE_CHANGED = "xforms-value-changed";
	public static final String XFORMS_TRUE = "true()";
	// XForms scripts
	public static final String XFORMS_HTML_SCRIPT_PATH = 
		    "<script type=\"text/javascript\" src=\"../xsltforms/xforms_html.js\"></script>" +
			"\n<script type=\"text/javascript\" src=\"../xsltforms/dialog_box.js\"></script>";
	public static final String XFORMS_DIALOG_SCRIPT = 
		    "javascript:showDialog('Help','XYZ','warning',false,'lmid-')";
	
	// XForms messages
	public static final String XFORMS_MESSAGES_BUNDLE_NAME = "messages";
	public static final String XFORMS_SUBMIT_ERROR_MESSAGE_KEY = "xforms.err.invalid";
	public static final String XFORMS_ERROR_REQUIRED_ALERT_KEY = "xforms.alert.required";
	public static final String XFORMS_ERROR_INVALID_ALERT_KEY = "xforms.alert.invalid";
	public static final String XFORMS_SUBMIT_ERROR_CSS_CLASS = "errorsClass";

	// Miscellaneous
	public static final String EMPTY_STRING = "";
	public static final String XFORM_SPACE = "_HCITSPACE_";
	public static final String ACTION_URL = "xform.view";
	public static final String ASTERISK = "*";
	
	//Messages
	public static final String PLEASE_SELECT_OPTION_TEXT = "Please Select...";
}
