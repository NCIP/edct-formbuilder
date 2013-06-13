/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

import org.springframework.web.servlet.ModelAndView;

public interface EditControllable
{
	public boolean isModelEditable(ModelAndView mav);
}
