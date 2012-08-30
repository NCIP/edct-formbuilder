package com.healthcit.cacure.web.controller;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.bind.util.JAXBSource;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;


import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.businessdelegates.export.DataExporter;
import com.healthcit.cacure.businessdelegates.export.DataImporter;
import com.healthcit.cacure.export.model.Cure;
import com.healthcit.cacure.utils.AppConfig;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.utils.Constants.ExportFormat;


@Controller
@RequestMapping(value=Constants.FORM_EXPORT_URI)
public class FormExportController {
	private static final Logger log = Logger.getLogger(FormExportController.class);

	@Autowired
	DataExporter dataExporter;
	
	@Autowired
	DataImporter dataImporter;

	
	@RequestMapping(method=RequestMethod.GET)
	public void exportForm(
			@RequestParam(value = "id", required = true) Long formId,
			@RequestParam(value = "format", required = true) String format,
			HttpServletResponse response)
	{
		
		
		try {
			OutputStream oStream = response.getOutputStream();
			Cure cureXml = dataExporter.constructFormXML(formId);
			JAXBContext jc = JAXBContext.newInstance("com.healthcit.cacure.export.model");
			
			

			if(ExportFormat.XML.name().endsWith(format))
			{
				String fileNameHeader =	String.format("attachment; filename=form-%d.xml;",formId);
				response.setHeader("Content-Disposition", fileNameHeader);
				response.setContentType("application/xml");
							
				Marshaller m = jc.createMarshaller();
				m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
				m.marshal(cureXml, oStream);
				oStream.flush();
			}
			else if(ExportFormat.EXCEL.name().equals(format))
			{
				String fileNameHeader =	String.format("attachment; filename=form-%d.xlxml;",formId);
				response.setHeader("Content-Disposition", fileNameHeader);
				response.setContentType("application/xml");
				StreamSource xslSource = new StreamSource(this.getClass().getClassLoader().getResourceAsStream(AppConfig.getString(Constants.EXPORT_EXCEL_XSLT_FILE)));
			    JAXBSource xmlSource = new JAXBSource(jc, cureXml);
				Transformer transformer = TransformerFactory.newInstance().newTransformer(xslSource);
				transformer.transform(xmlSource,new StreamResult(oStream));
			}
		} catch (IOException e) {
			log.error("Unable to obtain output stream from the response");
			log.error(e.getMessage(), e);
		}
		catch(JAXBException e)
		{
			log.error("Unable to marshal the object");
			log.error(e.getMessage(), e);
		}
		catch(TransformerException e)
		{
			log.error("XSLT transformation failed");
			log.error(e.getMessage(), e);
		}
	}
	
	
	@RequestMapping(method=RequestMethod.POST)
	public ModelAndView importForm( @RequestParam("file") MultipartFile file, @RequestParam("moduleId") long moduleId, HttpServletRequest request, HttpServletResponse response)
	{
		try
		{
			if(file != null)
			{
				Map<String, String> existingForms = new HashMap<String, String>();
				List<String> existingQuestions = new ArrayList<String>();
				InputStream is = file.getInputStream();
				JAXBContext jc = JAXBContext.newInstance("com.healthcit.cacure.export.model");
				Unmarshaller m = jc.createUnmarshaller();
				Cure cure = (Cure)m.unmarshal(is);
				dataImporter.importData(cure, moduleId,existingForms, existingQuestions);
				if(existingForms.size()>0 || existingQuestions.size()>0)
				{
					ModelAndView mav = new ModelAndView("formUploadStatus"); // initialize with view name
					ModelMap model = mav.getModelMap();
					model.addAttribute("existingForms", existingForms);
					model.addAttribute("existingQuestions", existingQuestions);
					return mav;
					/* there had been errors */
//					return new ModelAndView("formUploadStatus", "existingForms", existingForms);
				}
			}
			return new ModelAndView("formUploadStatus", "status", "OK");
		     
		}catch(Exception e)
		{
			log.error(e.getMessage(), e);
			return new ModelAndView("formUploadStatus", "status", "FAIL");
		}	
	}
	
	
}
