package com.healthcit.cacure.web.function;

import java.util.Collection;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;

import com.healthcit.cacure.model.Category;
import com.healthcit.cacure.model.FormElement;


public class JspUtilFunctions {
	
	public static Boolean contains(Collection<Object> collection, Object obj) {
		if(collection == null) {
			return false;
		}
		return collection.contains(obj);
	}
	
	public static String getSearchCriteriaString(Collection<FormElement> foundElements, Collection<Category> allCategories, Object categoryIdsO, String searchText) {
//		TODO How to declare array of strings in tld settings
		String[] categoryIds = (String[]) categoryIdsO;
		StringBuilder result = new StringBuilder();
		if(CollectionUtils.isEmpty(foundElements)) {
			result.append("No results was found");
		} else {
			result.append("<strong>");
			result.append(foundElements.size());
			result.append("</strong>");
			result.append(" question");
			if(foundElements.size() > 1) {
				result.append("s");
			}
			result.append(" was found");
		}
		if((categoryIds == null || categoryIds.length == 0) && StringUtils.isBlank(searchText)) {
			result.toString();
		}
		result.append(" for<br/>");
		if(categoryIds != null && categoryIds.length > 0) {
			result.append("<strong>categor");
			if(categoryIds.length > 1) {
				result.append("ies");
			} else {
				result.append("y");
			}
			result.append(":</strong> ");
			for (int i = 0; i < categoryIds.length; i++) {
				Long cId = Long.valueOf(categoryIds[i]);
				for (Category category : allCategories) {
					if(category.getId().equals(cId)) {
//						Note: Double quotes cutted out from dojo dialox box header
						result.append("''");
						result.append(category.getName());
						result.append("''");
						if(i + 1 < categoryIds.length) {
							result.append(", ");
						}
					}
				}
			}
			if(StringUtils.isNotBlank(searchText)) {
				result.append("<br/>");
			}
		}
		if(StringUtils.isNotBlank(searchText)) {
			result.append("<strong>text:</strong> ");
//			Note: Double quotes cutted out from dojo dialox box header
			result.append("''");
			result.append(searchText);
			result.append("''");
		}
		return result.toString();
	}
	
}
