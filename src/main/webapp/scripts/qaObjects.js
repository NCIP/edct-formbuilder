/*******************************************************************************
 *Copyright (c) 2012 HealthCare It, Inc.
 *All rights reserved. This program and the accompanying materials
 *are made available under the terms of the BSD 3-Clause license
 *which accompanies this distribution, and is available at
 *http://directory.fsf.org/wiki/License:BSD_3Clause
 *
 *Contributors:
 *    HealthCare It, Inc - initial API and implementation
 ******************************************************************************/
function QuestionsList() {
	this.questionList;
}
	
function AnswersList() {
	this.answersList;
}

function QuestionData() {
  this.id = "";
  this.ord = "";
  this.description = "";
  this.shortName = "";
  this.answer = "";
  this.type = "SINGLE_ANSWER";
  this.uuid = "";
}

function AnswerData() {
  this.id = "";
  this.ord = "";
  this.answerDescription = "";
  this.groupName = "";
  this.answerValuesArray = new Array();
  this.type = "RADIO";
  this.answerColumnHeading = "";
  this.answerDisplayStyle = "";
  this.answerConstraintsArray = new Array();
  this.uuid = "";
}

function AnswerValue() {
  this.id = "";
  this.formId = "";
  this.answerValueDescription = "";
  this.answerValue = "";
  this.shortname = "";
  this.permanentId = "";
  this.ord = "";
  this.answerDisplayStyle = "";
  this.defaultValue = false;
}

function Constraint() {
	this.name = "";
	this.value = "";
}
