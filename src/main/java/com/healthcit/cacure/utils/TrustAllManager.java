/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.utils;

import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.X509TrustManager;

/**
 * TrustManager description
 * 
 * @author nik
 */

public class TrustAllManager implements X509TrustManager {

  public TrustAllManager() {
    // create/load keystore
  }

  @Override
public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
  }

  @Override
public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
  }

  @Override
public X509Certificate[] getAcceptedIssuers() {
    return null;
  }

}
