package com.healthcit.cacure.xforms;

import java.io.IOException;
import java.io.Writer;
import java.util.Iterator;
import java.util.List;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import org.jdom.transform.JDOMSource;
import org.jdom.xpath.XPath;

import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.FormElement;
import com.healthcit.cacure.model.LinkElement;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.xforms.uicontrolfactory.BaseXFormUIControlFactory;
import com.healthcit.cacure.xforms.uicontrolfactory.XFormHTMLFactory;
import com.healthcit.cacure.xforms.uicontrols.XFormUIControl;


/**
 * This is the main class which controls generation of a valid XForms file from
 * FormBuilder's internal storage.
 * The file generated is a valid XHTML file with all namespaces declared at the document level.
 * This provides for easy parsing as well as ability to generate a well formed XML.
 * @author lkagan
 *
 */
public class XForm {


	private Document doc;
	private XFormContainerType containerType;
	private BaseXFormUIControlFactory factory;
	private QuestionAnswerManager qaManager;
	@SuppressWarnings("unused")
	private static Logger log = Logger.getLogger(XForm.class);
	
	public enum XFormContainerType{ HTML };

	/**
	 * Constructor to create xforms representation out of a form model
	 * @param form
	 */
	public XForm( BaseForm form, XFormContainerType xFormContainerType, QuestionAnswerManager qaManager )
	{		
		this.qaManager = qaManager;
		initDocument( xFormContainerType );

		createXformFromModel( form );
		
	}

	private void initDocument(XFormContainerType xFormContainerType)
	{
		// set up the container type
		containerType = xFormContainerType;
		
		// initialize DOM structure for <xform:instance/>
		doc = new Document();

		// 1: For HTML containers
		// TODO: In the future, add support for other types of containers as well
		if ( containerType.equals( XFormContainerType.HTML )) {
			initHTMLDocument();
			factory = new XFormHTMLFactory();
		} 


	}
	
	private void initHTMLDocument() {
		Element htmlRoot = new Element("html", XFormsConstants.XHTML_NAMESPACE);
		htmlRoot.addNamespaceDeclaration(XFormsConstants.EVENTS_NAMESPACE);
		htmlRoot.addNamespaceDeclaration(XFormsConstants.XSD_NAMESPACE);
		htmlRoot.addNamespaceDeclaration(XFormsConstants.XFORMS_NAMESPACE);
		htmlRoot.addContent(new Element("head", XFormsConstants.XHTML_NAMESPACE));
		htmlRoot.addContent(new Element("body", XFormsConstants.XHTML_NAMESPACE));
		doc.setRootElement(htmlRoot);
	}


	@SuppressWarnings("unchecked")
	private void createXformFromModel(BaseForm form)
	{ 
		List<Element> elements = doc.getRootElement().getContent(new ElementFilter("head", XFormsConstants.XHTML_NAMESPACE));
		Element docHead = elements.get(0);
		elements = doc.getRootElement().getContent(new ElementFilter("body", XFormsConstants.XHTML_NAMESPACE));
		Element docBody = elements.get(0);		
		
		try
		{		
			if ( factory == null ) throw new Exception( "Could not instantiate UI factory" );
			
			docBody.addContent(factory.createFormTitleControl().getControlElements());
			XFormModel xfm = new XFormModel(docHead);		
			
			// Custom JS scripts
			docBody.addContent( factory.createCustomJSScripts() );			
			
			xfm.createSectionModel(form);
			
			// add any cross-form skips 
			// (question skips which are triggered by questions that are external to the form)
			if(form instanceof QuestionnaireForm)
			{
				xfm.addCrossFormSkipsToModel((QuestionnaireForm)form);
			}
			// add URL instance
			xfm.addURLInstanceToModel(form);
			
			// iterate through all elements to construct XForm
			for(FormElement fe: form.getElements())
			{
				FormElement pfe = fe;
				if(fe instanceof LinkElement) {
					pfe = qaManager.getFantom(fe.getId());
//					xforms use uuid of parent element
					pfe.setUuid(((LinkElement) fe).getSourceId());
//					pfe = ((LinkElement) fe).getSourceElement();
				}
				xfm.add(pfe);
				XFormUIControl control = factory.createXFormUIControl(pfe, qaManager);
				docBody.addContent(control.getControlElements());
			}
			
			xfm.finalizeModel(form);

			updateDocumentNamespaces( doc, form.getUuid());
			updateDocumentNamespaces( doc, XFormsUtils.getReadOnlyFormId(form.getUuid()));
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}
	
	@SuppressWarnings("unchecked")
	private void updateDocumentNamespaces(Object jdomObject, String objectId)
	throws JDOMException
	{
		List<Element> elements;
		
		if ( StringUtils.isBlank( objectId ) ) {
			
			elements = (( Element ) jdomObject).getChildren();
			
		} else {
			
			elements = XPath.selectNodes(jdomObject, XFormsUtils.getXPathByIdAttribute( objectId ));
			
		}
		
		for ( Iterator<Element> iter = elements.iterator(); iter.hasNext(); ) {
			
			Element element = iter.next();			
						
			element.setNamespace( Namespace.NO_NAMESPACE );
					
			updateDocumentNamespaces( element, null );
		}
	}

	public void write(Writer writer) throws IOException, JDOMException
	{
		try
		{
	
	        Source source = new JDOMSource(doc);
	        Result result = new StreamResult(writer);
	        TransformerFactory factory = TransformerFactory.newInstance();
	        Transformer transformer = factory.newTransformer();
	        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
	        transformer.setOutputProperty(OutputKeys.STANDALONE, "yes");
	        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
	        transformer.setOutputProperty("{http://xml.apache.org/xalan}indent-amount", "2");

	        transformer.transform(source, result);
		}
		catch (TransformerException e)
		{
			throw new XFormsConstructionException(e);
		}


	}

}
