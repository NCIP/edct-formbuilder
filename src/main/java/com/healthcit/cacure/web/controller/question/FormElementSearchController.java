package com.healthcit.cacure.web.controller.question;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.directwebremoting.annotations.RemoteMethod;
import org.directwebremoting.annotations.RemoteProxy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.utils.IOUtils;

@Controller
@Service
@RemoteProxy
public class FormElementSearchController {

	private static final int ERR_STATUS = -1;
	private static final int ALLREADY_EXISTS_STATUS = 0;
	private static final int OK_STATUS = 1;

	private static final long DISPLAY_LOADER_IN_MILLIS = 1000L;


	@Autowired
	QuestionAnswerManager qaManager;

	@Autowired
	FormManager formManager;

	@RequestMapping(value = "/questionSearch", method = RequestMethod.GET)
	public ModelAndView showFoundQuestions( 
			@RequestParam(value = "crit") int searchCriteria, 
			@RequestParam(value = "q", required = false) String searchText,
			@RequestParam(value = "categoryId", required = false) Long categoryId)
	{
		List<FormElement> list = qaManager.searchFormElements(searchCriteria, searchText, categoryId);
		return new ModelAndView("questionSearch", "resultList", list);
	}

	@RemoteMethod
	public String includeShowFoundQuestions(int searchCriteria, String query, Long categoryId) throws IOException, InterruptedException {
		long begin = System.currentTimeMillis();
		StringBuilder url = new StringBuilder("/questionSearch");
		url.append("?crit=").append(searchCriteria);
		if(StringUtils.isNotBlank(query)) {
			url.append("&q=").append(URLEncoder.encode(query, "UTF-8"));
		}
		if(categoryId != null) {
			url.append("&categoryId=").append(categoryId);
		}
        String html = IOUtils.getURLContent(url.toString());
        long end = System.currentTimeMillis();
        long dif = end - begin;
        if (dif < DISPLAY_LOADER_IN_MILLIS) { //if loading data was less then 1s
        	Thread.sleep(DISPLAY_LOADER_IN_MILLIS - dif);
        }
        return html;
    }
	
	@RemoteMethod
//	public int checkDuplicate( String formId, long id ) {
	public int checkDuplicate( String formId, String uuid ) {

		try {
			if (qaManager.isQuestionAlreadyExistsInForm(Long.parseLong(formId), uuid)) {
				return ALLREADY_EXISTS_STATUS;
			}
		}catch (Exception ex) {
			ex.printStackTrace();
			return ERR_STATUS;
		}
		return OK_STATUS;
	}
	
	@RemoteMethod
	public int importFormElements(String formId, String[][] questionSet, int searchCriteria){
		try {
			qaManager.importFormElements(Long.parseLong(formId), questionSet, searchCriteria);
		} catch (Exception ex) {
			ex.printStackTrace();
			return ERR_STATUS;
		}
		return OK_STATUS;
	}
}
