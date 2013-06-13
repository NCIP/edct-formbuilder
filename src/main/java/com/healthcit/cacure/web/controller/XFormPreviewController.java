/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

import java.io.InputStream;
import java.io.StringWriter;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.utils.IOUtils;
import com.healthcit.cacure.xforms.XForm;
import com.healthcit.cacure.xforms.XForm.XFormContainerType;

@Controller
public class XFormPreviewController
{
	private final static String MODEL_START_TAG= "<xform:model";
	private final static String MODEL_END_TAG= "</xform:model>";
	private final static String BODY_START_TAG= "<body>";
	private final static String BODY_END_TAG= "</body>";
	private final static String XFORM_BODY = "xformBody";
	private final static String XFORM_MODEL = "xformModel";
	private final static String XFORM_TITLE = "xFormTitle";
	private final static String XFORM_PREVIEW_VIEW = "xform-preview";

	@Autowired
    private FormManager formManager;
	
	@Autowired
	protected QuestionAnswerManager qaManager;

    @Autowired
    @Qualifier("servletContext")
	private ServletContext servletContext;

	@SuppressWarnings("unchecked")
	@RequestMapping(value = Constants.XFORM_PREVIEW_URI, method = RequestMethod.POST)
    public ModelAndView processXForm( HttpServletRequest request, HttpServletResponse response )
    {
		ModelAndView map = new ModelAndView();
		String xformContent = org.apache.commons.lang.StringUtils.defaultIfEmpty( IOUtils.read( request ), "No content available" );
		String escapedXformContent = StringEscapeUtils.escapeHtml( xformContent );
		map.getModelMap().put( XFORM_BODY, escapedXformContent );
		map.getModelMap().put( XFORM_MODEL, MODEL_START_TAG + ">" + xformContent + MODEL_END_TAG );
		map.getModelMap().put( XFORM_TITLE, "SUBMISSION SUCCESSFUL" );
		map.setViewName( XFORM_PREVIEW_VIEW );
    	return map;
    }

	@SuppressWarnings("unchecked")
	@RequestMapping(value = Constants.XFORM_PREVIEW_URI, method = RequestMethod.GET)
	public ModelAndView showXForm(
			@RequestParam(value = "file", required= false) String fileName,
			@RequestParam(value = Constants.FORM_ID, required=false) Long formID)
	{
		ModelAndView mav = new ModelAndView();
		mav.setViewName(XFORM_PREVIEW_VIEW);
		Map model = mav.getModel();
		String xformModel = "";
		String xformBody = "";

		// if file present - read in file
		String xFormData;
		if (StringUtils.hasText(fileName))
			xFormData = readResource(fileName);
		else
			xFormData = loadFormDB(formID);

		if (xFormData != null)
		{
			// split XForm into model and body
			int startOfModelIdx = xFormData.indexOf(MODEL_START_TAG);
			int endOfModelIdx = xFormData.lastIndexOf(MODEL_END_TAG);
			int startOfBodylIdx = xFormData.indexOf(BODY_START_TAG);
			int endOfBodyIdx = xFormData.indexOf(BODY_END_TAG);
			if (startOfModelIdx >= 0 && endOfModelIdx > 0)
			{
				endOfModelIdx += MODEL_END_TAG.length();
				xformModel = xFormData.substring(startOfModelIdx, endOfModelIdx);
				// xformModel = xformModel.replaceAll("xmlns=\"http://www.healthcit.com/FormDataModel\"", "xmlns=\"\"");
				// find form Title
				Pattern p = Pattern.compile("(<form.*)(.*name=\"(.*?)\" .*>)");
				Matcher m = p.matcher (xformModel);
				if (m.find() && m.groupCount() > 0)
				{
					String formTitle = m.group(3);
					model.put(XFORM_TITLE, formTitle);
				}
				else
				{
					model.put(XFORM_TITLE, "Unknown Form");
				}
				model.put(XFORM_MODEL, xformModel);

			}
			if (startOfBodylIdx >= 0 && endOfBodyIdx > 0)
			{
				startOfBodylIdx += BODY_START_TAG.length();
				xformBody = xFormData.substring(startOfBodylIdx, endOfBodyIdx);
				// Remove/disable the custom JS script that produces the "Confirm Leave Page" warning
				// Confirm Leave Page warning is disabled in xforms-layout.jsp

//				xformBody = xformBody.replaceAll( "xforms_html.js", "xforms_htl2.js" );

				model.put(XFORM_BODY, xformBody);
			}

		}
		else
			model.put(XFORM_BODY, "Unable to load XForm");

		return mav;

	}

	private String loadFormDB(Long formID)
	{
		BaseForm form = formManager.getForm(formID);
		XForm xForm = new XForm(form, XFormContainerType.HTML, qaManager);
		// initialize writer

		StringWriter writer = new StringWriter(5000);
		try
		{
			xForm.write(writer);
			return writer.toString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
	}

	private String readResource(String fileName)
	{
		InputStream is = null;
		String data = null;
		if (fileName != null)
		{
			try
			{
				// load resource from classpath

			    is = servletContext.getResourceAsStream("/WEB-INF/forms/" + fileName);

			    data = IOUtils.read(is);
			}
			catch (Exception e)
			{
				e.printStackTrace();
				data= null;
			}
			finally
			{
				if (is != null)
					try{is.close();}catch(Exception ex){}
			}
		  }
	    return data;
	}

}
