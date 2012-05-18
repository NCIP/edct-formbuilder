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
}

function Constraint() {
	this.name = "";
	this.value = "";
}