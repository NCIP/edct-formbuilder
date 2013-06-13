/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.utils;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.MailException;
import org.springframework.mail.MailSender;
import org.springframework.mail.SimpleMailMessage;
import com.healthcit.cacure.model.QuestionnaireForm;

/**
 * This is a class that contains the email sending functionality required by
 * Form Builder. The SimpleMailMessage objects are email template-like beans
 * defined in mailTemplates-config.xml and injected by Spring. Then their
 * identifiers are populated with instance-dependent values
 *
 * @author vstoyanov
 *
 */
public class MailSendingService {
	private static final Logger logger = Logger.getLogger(MailSendingService.class);

	/** The web app path identifier used in the mail templates*/
	public final static String WEB_APP_PATH_IDENTIFIER = "%WEB_APP_PATH%";

	/** The web app path identifier used in the mail templates*/
	public final static String MODULE_ID_IDENTIFIER = "%MODULE_ID%";

	/** The web app path identifier used in the mail templates*/
	public final static String FORM_ID_IDENTIFIER = "%FORM_ID%";

	@Autowired
	private MailSender mailSender;

	@Resource(name="submittedSectionNotificationTemplate")
	private SimpleMailMessage submittedSectionNotificationTemplate;

	/**
	 * Sends a notification email, that a section has been submitted for review
	 *
	 * @param form the form, which is submitted for review
	 * @param toEmail the recipient - the intended recipients are ROLE_APPROVERs
	 */
	public void sendSubmittedSectionNotification(QuestionnaireForm form, String toEmail, String webAppUri) {
		SimpleMailMessage message =
			new SimpleMailMessage(submittedSectionNotificationTemplate);

		StringBuilder emailText =
				new StringBuilder(submittedSectionNotificationTemplate.getText());
		//TODO: DEVISE A BETTER WAY OF OBTAINING THE WEB-APP PATH
		StringUtils.replace(emailText, WEB_APP_PATH_IDENTIFIER, webAppUri);
		StringUtils.replace(emailText, MODULE_ID_IDENTIFIER, form.getModule().getId().toString());
		StringUtils.replace(emailText, FORM_ID_IDENTIFIER, form.getId().toString());

		message.setText(emailText.toString());
		message.setTo(toEmail);

		try {
			if(logger.isDebugEnabled()) {
				logger.debug("Sending section submitted notification mail to " + toEmail);
			}

			mailSender.send(message);

		} catch(MailException me) {
			logger.error("Failed sending section submitted notification mail", me);
		}
	}

	public MailSender getMailSender() {
		return mailSender;
	}

	public void setMailSender(MailSender mailSender) {
		this.mailSender = mailSender;
	}

	public void setSubmittedSectionNotificationTemplate(
			SimpleMailMessage submittedSectionNotificationTemplate) {
		this.submittedSectionNotificationTemplate = submittedSectionNotificationTemplate;
	}
}
