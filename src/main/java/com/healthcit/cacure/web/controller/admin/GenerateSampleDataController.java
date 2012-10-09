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
package com.healthcit.cacure.web.controller.admin;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.xwork.StringUtils;
import org.apache.log4j.Logger;
import org.directwebremoting.annotations.RemoteMethod;
import org.directwebremoting.annotations.RemoteProxy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.GeneratedModuleDataManager;
import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.admin.GeneratedModuleDataDetail;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.editors.GeneratedModuleDataPropertyEditor;

@Controller
@Service
@RemoteProxy
public class GenerateSampleDataController {
	
	private static Logger log = Logger.getLogger( GenerateSampleDataController.class );
	
	@Autowired
	private GeneratedModuleDataManager dataManager;
	
	@Autowired
	private ModuleManager moduleManager;
	
	@Autowired
	private FormManager formManager;
	
	@InitBinder
	public void initBinder(WebDataBinder binder)
	{
		binder.registerCustomEditor( GeneratedModuleDataDetail.class, new GeneratedModuleDataPropertyEditor() );
	}
	
	/**
	 * Populates the GeneralModuleDataDetail object.
	 * @param formId
	 */
	@ModelAttribute
	public GeneratedModuleDataDetail populateForm(
			@RequestParam( value="moduleId",required=false ) String moduleId,
			@RequestParam( value="formId",required=false ) String formId)
	{
		log.debug( "In populateForm method..." );
		log.debug( "........................." );
		log.debug( "........................." );
		
		GeneratedModuleDataDetail moduleDetail = new GeneratedModuleDataDetail();
		
		moduleDetail.setModuleId( moduleId );
		
		if( StringUtils.isNotBlank( moduleId ) )
		{
			moduleDetail.setModuleId( moduleId );
			
			List<BaseForm> forms = new ArrayList<BaseForm>();
			
			if ( StringUtils.isNotBlank( formId ) )
			{
				BaseForm form = formManager.getForm( new Long( formId ) );
				
				if ( form != null ) forms.add( form );
			}
			
			else 
			{
				forms = formManager.getModuleForms( Long.parseLong( moduleId ) );
			}
			
			if ( moduleDetail.getQuestionFields().isEmpty() )
			{		
				for ( BaseForm form : forms )
				{	
					if ( form instanceof QuestionnaireForm )
					{
						log.debug( "Populating questions for " + form.getName() + "..." );
						log.debug( ".................................................." );
						
						moduleDetail.addQuestionFields( dataManager.generateQuestionFields( (QuestionnaireForm)form ) );
					}
				}
			}	
		}
		
		return moduleDetail;
	}
	
	/**
	 * Populates the list of modules.
	 * @return
	 */
	@ModelAttribute
	public List<Module> populateModuleList()
	{
		return moduleManager.getAllModules();
	}
	
	/**
	 * Populates the list of forms.
	 * @return
	 */
	@ModelAttribute(value="formList")
	public List<BaseForm> populateFormList( @RequestParam(value="moduleId",required=false) String moduleId )
	{
		if ( StringUtils.isBlank( moduleId ) ) return new ArrayList<BaseForm>();
		
		return formManager.getModuleForms(new Long(moduleId));
	}
	
	@RequestMapping( value=Constants.GENERATE_SAMPLE_DATA_URI, method=RequestMethod.GET )
	public String showForm( @ModelAttribute GeneratedModuleDataDetail moduleDetail,
							@RequestParam(value="moduleId",required=false) String moduleId)
	{
		log.debug( "In showForm method..." );
		
		return "generateSampleData";
	}
	
	@RequestMapping( value=Constants.GENERATE_SAMPLE_DATA_URI, method=RequestMethod.POST )
	public ModelAndView submitForm( @ModelAttribute GeneratedModuleDataDetail formDetail )
	{
		log.debug( "In submitForm method..." );
		
		ModelAndView modelAndView = new ModelAndView();
		
		modelAndView.setViewName("generateSampleDataConfirm");
		
		try
		{
			dataManager.generateSampleDataInCouchDB(formDetail);
			
			modelAndView.getModelMap().put( "tracker", formDetail.getTracker() );
			
			modelAndView.getModelMap().put( "numModulesGenerated", formDetail.getActualNumberOfModules() );
			
			modelAndView.getModelMap().put( "numEntitiesGenerated", formDetail.getActualNumberOfEntities() );
			
			modelAndView.getModelMap().put( "numDocumentsGenerated", formDetail.getActualNumberOfCouchDbDocuments() );
		}
		catch(Exception ex)
		{
			ex.printStackTrace();
			//TODO: Display error messages as appropriate
		}

		return modelAndView;
	}
	
	@RemoteMethod
	public List<BaseForm> getFormsForModule( String moduleId )
	{
		return populateFormList( moduleId );
	}

	public void setDataManager(GeneratedModuleDataManager manager) {
		this.dataManager = manager;
	}

	public void setModuleManager(ModuleManager moduleManager) {
		this.moduleManager = moduleManager;
	}

	public void setFormManager(FormManager formManager) {
		this.formManager = formManager;
	}
}
