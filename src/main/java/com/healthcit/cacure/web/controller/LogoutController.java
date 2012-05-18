package com.healthcit.cacure.web.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.utils.Constants;

@Controller
public class LogoutController {
	
	private static final Logger log = Logger.getLogger(LogoutController.class);
	
	@RequestMapping(value="/logout", method = RequestMethod.GET)
	public View processLogout(HttpServletRequest request) {
		 
		HttpSession session = request.getSession();
		
		try {
			session.removeAttribute(Constants.CREDENTIALS) ;
			session.invalidate();	
		} catch (Exception ex) {
			//log exception
			log.error( "Error in LogoutAction", ex );
		}
		
	     return new RedirectView (Constants.HOME_URI, true);
	}
}	