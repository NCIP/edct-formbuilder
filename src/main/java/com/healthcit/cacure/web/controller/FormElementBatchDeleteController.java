/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import net.sf.json.JSONArray;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;

@Controller(value = "feBatchDeleteController")
public class FormElementBatchDeleteController {

	@Autowired
	protected QuestionAnswerManager qaManager;
	
	@RequestMapping(value = "/questionList.delete", method = RequestMethod.POST)
	public ResponseEntity<String> batchDelete(@RequestParam(value = "feIds[]", required = false) Long[] feIds) {
		HashSet<Long> uniqueIds = new HashSet<Long>(Arrays.asList(feIds));
		Set<Long> deleted = new HashSet<Long>();
		for (Long id : uniqueIds) {
			try {
				qaManager.deleteFormElementByID(id);
				deleted.add(id);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		JSONArray jsonArray = new JSONArray();
		for (Long id : deleted) {
			jsonArray.add(id);
		}
		
		HttpHeaders headers = new HttpHeaders();
		headers.add("Content-Type", "application/json");
		return new ResponseEntity<String>(jsonArray.toString(), headers, HttpStatus.OK);
	}
	
	public QuestionAnswerManager getQaManager() {
		return qaManager;
	}
	
	public void setQaManager(QuestionAnswerManager qaManager) {
		this.qaManager = qaManager;
	}
	
}
