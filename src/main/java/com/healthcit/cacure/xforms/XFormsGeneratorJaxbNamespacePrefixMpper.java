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
package com.healthcit.cacure.xforms;

import com.sun.xml.bind.marshaller.NamespacePrefixMapper;

public class XFormsGeneratorJaxbNamespacePrefixMpper extends
		NamespacePrefixMapper
{

	@Override
	public String getPreferredPrefix(String namespaceUri, String suggestedPrefix, boolean requirePrefix)
	{
		if ("http://www.healthcit.com/FormDataModel".equals(namespaceUri))
			return null;
		else
			return suggestedPrefix;
	}

	@Override
	public String[] getContextualNamespaceDecls()
	{
		return new String[]{"xform","http://www.w3.org/2002/xforms",
							"ev", "http://www.w3.org/2001/xml-events",
							"", "http://www.healthcit.com/FormDataModel"
							};
//		return super.getContextualNamespaceDecls();
	}

}
