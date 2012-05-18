package com.healthcit.cacure.web.controller;

import java.io.IOException;
import java.util.Collection;

import org.directwebremoting.annotations.RemoteMethod;
import org.directwebremoting.annotations.RemoteProxy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.model.FormLibraryForm;
import com.healthcit.cacure.utils.IOUtils;

@Controller
@Service
@RemoteProxy
public class FormSearchController {
	
	private static final int ERR_STATUS = -1;
	private static final int OK_STATUS = 1;

	private static final long DISPLAY_LOADER_IN_MILLIS = 1000L;
	
	@Autowired
	private FormManager formManager;
	
	@RequestMapping(value="/formSearch", method=RequestMethod.GET)
	public String getForms(@RequestParam(value="query", required=false) String query, Model model)
	{
		Collection<FormLibraryForm> forms = this.formManager.findLibraryForms(query);
		model.addAttribute("forms", forms);
		return "formSearch";
	}
	
	@RequestMapping(value="/allLibraryForms", method=RequestMethod.GET)
	public ModelAndView allLibraryForms()
	{
		Collection<FormLibraryForm> forms = this.formManager.getAllLibraryForms();
		return new ModelAndView("formSearch", "forms", forms);
	}
	
	@RemoteMethod
	public String getAllLibraryForms()throws IOException, InterruptedException
	{
		long begin = System.currentTimeMillis();
		StringBuilder url = new StringBuilder("/allLibraryForms");
        String html = IOUtils.getURLContent(url.toString());
        long end = System.currentTimeMillis();
        long dif = end - begin;
        if (dif < DISPLAY_LOADER_IN_MILLIS) { //if loading data was less then 1s
        	Thread.sleep(DISPLAY_LOADER_IN_MILLIS - dif);
        }
        return html;
	}
	
	@RemoteMethod
	public String searchForms(String query) throws IOException, InterruptedException
	{
		long begin = System.currentTimeMillis();
		StringBuilder url = new StringBuilder("/formSearch");
		url.append("?query=").append(IOUtils.convertStringToStringQuery(query));
        String html = IOUtils.getURLContent(url.toString());
        long end = System.currentTimeMillis();
        long dif = end - begin;
        if (dif < DISPLAY_LOADER_IN_MILLIS) { //if loading data was less then 1s
        	Thread.sleep(DISPLAY_LOADER_IN_MILLIS - dif);
        }
        return html;
	}
	
	@RemoteMethod
	public int importForms(String moduleId, String[] formSet){
		try {
			formManager.importForms(Long.parseLong(moduleId), formSet);
		} catch (Exception ex) {
			ex.printStackTrace();
			return ERR_STATUS;
		}
		return OK_STATUS;
	}
}
