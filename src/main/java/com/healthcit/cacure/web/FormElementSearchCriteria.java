/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web;

public class FormElementSearchCriteria {
	
	public static final int SEARCH_BY_TEXT = 1;
	public static final int SEARCH_BY_CATEGORY = 2;
	public static final int SEARCH_BY_TEXT_WITHIN_CATEGORY = 3;
	public static final int SEARCH_BY_CADSR_TEXT = 4;
	public static final int SEARCH_BY_CADSR_CART_USER = 5;
	
	private final int searchType;
	private String searchText;
	private Long categoryId;
	
	public FormElementSearchCriteria(int searchType, String q, Long categoryId) {
		this.searchType = searchType;
		this.searchText = q;
		this.categoryId = categoryId;
	}

	public int getSearchType() {
		return searchType;
	}

	public String getSearchText() {
		return searchText;
	}

	public void setSearchText(String searchText) {
		this.searchText = searchText;
	}

	public Long getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(Long categoryId) {
		this.categoryId = categoryId;
	}

}
