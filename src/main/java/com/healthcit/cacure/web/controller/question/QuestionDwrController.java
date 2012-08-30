package com.healthcit.cacure.web.controller.question;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.directwebremoting.annotations.RemoteMethod;
import org.directwebremoting.annotations.RemoteProxy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;

import com.healthcit.cacure.businessdelegates.DuplicateResultBean;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;

@Controller
@Service
@RemoteProxy
public class QuestionDwrController
{
	private static final Logger log = Logger.getLogger(QuestionDwrController.class);

	@Autowired
	protected QuestionAnswerManager qaManager;

	@RemoteMethod
	public String answerValueIsSkip(String permAnswerValueId, Long formId) throws IOException, InterruptedException {

		if(qaManager.isAnswerValueSkip(permAnswerValueId, formId)){
			return "yes";
		}

		log.info("******************deleteAnswerValueIsSkip()****** permAnswerValueId: " + permAnswerValueId);

		return "no";
	}

	@RemoteMethod
	public String answerValueIsSkipTable(String [] permAnswerValueIdArray, Long formId) throws IOException, InterruptedException {

		for(String pav: permAnswerValueIdArray){
			log.info("******************answerValueIsSkipTable()****** permAnswerValueId: " + pav);
			if(qaManager.isAnswerValueSkip(pav, formId)){
				return "yes";
			}
		}

		return "no";
	}


	@RemoteMethod
	public String answerValueIsSkipTableRow(Long answerId) throws IOException, InterruptedException {

		if(qaManager.isAnswerValueSkipTableRow(answerId)){
			return "yes";
		}

		log.info("******************answerValueIsSkipTableRow()****** answerId: " + answerId);

		return "no";
	}

	/**
	 * Checks whether a question (at least one of its answers) is used as 
	 * a skip for any section(form) or for another question. Used for 
	 * notifying the user on modifying/deleting such question.
	 * @param questionId the question Id
	 * @return whether the question is used as skip
	 * @throws IOException 
	 * @throws InterruptedException
	 */
	@RemoteMethod
	public String questionIsSkip(Long questionId) throws IOException, InterruptedException {

		if(qaManager.isSkip(questionId)){
			log.debug("******************deleteQuestionIsSkip()****** questionId: " + questionId + " -- is associated with skips.");
			return "yes";
		}
		else {
			log.debug("******************deleteQuestionIsSkip()****** questionId: " + questionId + " -- is not associated with skips.");
			return "no";
		}
	}



	@RemoteMethod
	public Integer countLinkedFormElements(String linkId) throws IOException, InterruptedException {
	  log.debug("In countLinkedQuestions method...");
	  return qaManager.getLinkedFormElementIds(linkId).size();
	}
	
	@RemoteMethod
	public String descriptionIsLinked(String formElementId, String description) {
		log.debug("In descriptionIsLinked method");
		List<String> descriptions = qaManager.getLinkedFormElementDescriptions(formElementId);
		if ( descriptions.contains( description )) return "yes";
		else return "no";
	}


    public Integer countLinkedReadOnlyFormElements(String linkSource, String linkId) throws IOException, InterruptedException {
	  log.debug("In countLinkedReadOnlyQuestions method...");
	  return qaManager.getLinkedReadOnlyFormElementIds(linkId).size();
  }

	@RemoteMethod
	public Integer countLinkedSkippedFormElements(String linkId) throws IOException, InterruptedException {
      log.debug("In countLinkedSkippedQuestions method...");
	  return qaManager.getLinkedSkippedFormElementIds(linkId).size();
	}
	
	@RemoteMethod
	public String batchCheckBeforeDelete(String[] feUuids) {
		HashSet<String> uniqueUuid = new HashSet<String>(Arrays.asList(feUuids));
		Set<String> skipsUuidsFrom = qaManager.getSkipsUuidsFrom(uniqueUuid);
		Set<String> linkedFormElementUuids = qaManager.getLinkedFormElementUuids(uniqueUuid);
		JSONObject jsonObject = new JSONObject();
		for (String uuid : uniqueUuid) {
			JSONObject jsonStatusesObject = new JSONObject();
			jsonStatusesObject.put("hasSkips", skipsUuidsFrom.contains(uuid));
			jsonStatusesObject.put("hasLinks", linkedFormElementUuids.contains(uuid));
			jsonObject.put(uuid, jsonStatusesObject);
		}
		return jsonObject.toString();
	}

	@RemoteMethod
	public String hasShortNameDuplicates(String[] shortNames) throws IOException, InterruptedException {

		DuplicateResultBean hasShortNameDuplicates = qaManager.hasShortNameDuplicates(Arrays.asList(shortNames));
		log.info("******************hasShortNameDuplicates(" + StringUtils.join(shortNames, ", ") + ")****** returns " + hasShortNameDuplicates);

		JSONObject jsonObject = new JSONObject();
		jsonObject.put("result", hasShortNameDuplicates.getResult());
		jsonObject.put("shortNames", hasShortNameDuplicates.getShortNames());
		return jsonObject.toString();
	}
}
