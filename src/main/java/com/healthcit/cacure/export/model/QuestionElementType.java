//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.1-b02-fcs 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2012.05.25 at 01:47:39 PM EDT 
//


package com.healthcit.cacure.export.model;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for questionElementType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="questionElementType">
 *   &lt;complexContent>
 *     &lt;extension base="{}FormElementType">
 *       &lt;sequence>
 *         &lt;element name="question" type="{}questionType"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "questionElementType", propOrder = {
    "question"
})
@XmlSeeAlso({
    com.healthcit.cacure.export.model.Cure.Form.ExternalQuestionElement.class
})
public class QuestionElementType
    extends FormElementType
{

    @XmlElement(required = true)
    protected QuestionType question;

    /**
     * Gets the value of the question property.
     * 
     * @return
     *     possible object is
     *     {@link QuestionType }
     *     
     */
    public QuestionType getQuestion() {
        return question;
    }

    /**
     * Sets the value of the question property.
     * 
     * @param value
     *     allowed object is
     *     {@link QuestionType }
     *     
     */
    public void setQuestion(QuestionType value) {
        this.question = value;
    }

}
