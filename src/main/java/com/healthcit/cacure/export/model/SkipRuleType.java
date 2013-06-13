/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.1-b02-fcs 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2012.09.11 at 12:38:39 PM EDT 
//


package com.healthcit.cacure.export.model;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for skipRuleType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="skipRuleType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="questionSkipRule" maxOccurs="unbounded">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="answerSkipRule" maxOccurs="unbounded">
 *                     &lt;complexType>
 *                       &lt;complexContent>
 *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                           &lt;attribute name="answerValueUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="formUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                         &lt;/restriction>
 *                       &lt;/complexContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                 &lt;/sequence>
 *                 &lt;attribute name="ruleValue" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *                 &lt;attribute name="logicalOp" use="required" type="{}skipLogicalOpType" />
 *                 &lt;attribute name="identifyingAnswerValueUUID" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="triggerQuestionUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="triggerFormUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *       &lt;attribute name="parentId" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="type" type="{}skipTypeType" />
 *       &lt;attribute name="logicalOp" type="{}skipLogicalOpType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "skipRuleType", propOrder = {
    "questionSkipRule"
})
public class SkipRuleType {

    @XmlElement(required = true)
    protected List<SkipRuleType.QuestionSkipRule> questionSkipRule;
    @XmlAttribute(required = true)
    protected String parentId;
    @XmlAttribute
    protected SkipTypeType type;
    @XmlAttribute
    protected SkipLogicalOpType logicalOp;

    /**
     * Gets the value of the questionSkipRule property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the questionSkipRule property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getQuestionSkipRule().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SkipRuleType.QuestionSkipRule }
     * 
     * 
     */
    public List<SkipRuleType.QuestionSkipRule> getQuestionSkipRule() {
        if (questionSkipRule == null) {
            questionSkipRule = new ArrayList<SkipRuleType.QuestionSkipRule>();
        }
        return this.questionSkipRule;
    }

    /**
     * Gets the value of the parentId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getParentId() {
        return parentId;
    }

    /**
     * Sets the value of the parentId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setParentId(String value) {
        this.parentId = value;
    }

    /**
     * Gets the value of the type property.
     * 
     * @return
     *     possible object is
     *     {@link SkipTypeType }
     *     
     */
    public SkipTypeType getType() {
        return type;
    }

    /**
     * Sets the value of the type property.
     * 
     * @param value
     *     allowed object is
     *     {@link SkipTypeType }
     *     
     */
    public void setType(SkipTypeType value) {
        this.type = value;
    }

    /**
     * Gets the value of the logicalOp property.
     * 
     * @return
     *     possible object is
     *     {@link SkipLogicalOpType }
     *     
     */
    public SkipLogicalOpType getLogicalOp() {
        return logicalOp;
    }

    /**
     * Sets the value of the logicalOp property.
     * 
     * @param value
     *     allowed object is
     *     {@link SkipLogicalOpType }
     *     
     */
    public void setLogicalOp(SkipLogicalOpType value) {
        this.logicalOp = value;
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;sequence>
     *         &lt;element name="answerSkipRule" maxOccurs="unbounded">
     *           &lt;complexType>
     *             &lt;complexContent>
     *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                 &lt;attribute name="answerValueUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="formUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *               &lt;/restriction>
     *             &lt;/complexContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *       &lt;/sequence>
     *       &lt;attribute name="ruleValue" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
     *       &lt;attribute name="logicalOp" use="required" type="{}skipLogicalOpType" />
     *       &lt;attribute name="identifyingAnswerValueUUID" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="triggerQuestionUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="triggerFormUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "answerSkipRule"
    })
    public static class QuestionSkipRule {

        @XmlElement(required = true)
        protected List<SkipRuleType.QuestionSkipRule.AnswerSkipRule> answerSkipRule;
        @XmlAttribute
        @XmlSchemaType(name = "anySimpleType")
        protected String ruleValue;
        @XmlAttribute(required = true)
        protected SkipLogicalOpType logicalOp;
        @XmlAttribute
        protected String identifyingAnswerValueUUID;
        @XmlAttribute(required = true)
        protected String triggerQuestionUUID;
        @XmlAttribute(required = true)
        protected String triggerFormUUID;

        /**
         * Gets the value of the answerSkipRule property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the answerSkipRule property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getAnswerSkipRule().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link SkipRuleType.QuestionSkipRule.AnswerSkipRule }
         * 
         * 
         */
        public List<SkipRuleType.QuestionSkipRule.AnswerSkipRule> getAnswerSkipRule() {
            if (answerSkipRule == null) {
                answerSkipRule = new ArrayList<SkipRuleType.QuestionSkipRule.AnswerSkipRule>();
            }
            return this.answerSkipRule;
        }

        /**
         * Gets the value of the ruleValue property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getRuleValue() {
            return ruleValue;
        }

        /**
         * Sets the value of the ruleValue property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setRuleValue(String value) {
            this.ruleValue = value;
        }

        /**
         * Gets the value of the logicalOp property.
         * 
         * @return
         *     possible object is
         *     {@link SkipLogicalOpType }
         *     
         */
        public SkipLogicalOpType getLogicalOp() {
            return logicalOp;
        }

        /**
         * Sets the value of the logicalOp property.
         * 
         * @param value
         *     allowed object is
         *     {@link SkipLogicalOpType }
         *     
         */
        public void setLogicalOp(SkipLogicalOpType value) {
            this.logicalOp = value;
        }

        /**
         * Gets the value of the identifyingAnswerValueUUID property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getIdentifyingAnswerValueUUID() {
            return identifyingAnswerValueUUID;
        }

        /**
         * Sets the value of the identifyingAnswerValueUUID property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setIdentifyingAnswerValueUUID(String value) {
            this.identifyingAnswerValueUUID = value;
        }

        /**
         * Gets the value of the triggerQuestionUUID property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getTriggerQuestionUUID() {
            return triggerQuestionUUID;
        }

        /**
         * Sets the value of the triggerQuestionUUID property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setTriggerQuestionUUID(String value) {
            this.triggerQuestionUUID = value;
        }

        /**
         * Gets the value of the triggerFormUUID property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getTriggerFormUUID() {
            return triggerFormUUID;
        }

        /**
         * Sets the value of the triggerFormUUID property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setTriggerFormUUID(String value) {
            this.triggerFormUUID = value;
        }


        /**
         * <p>Java class for anonymous complex type.
         * 
         * <p>The following schema fragment specifies the expected content contained within this class.
         * 
         * <pre>
         * &lt;complexType>
         *   &lt;complexContent>
         *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
         *       &lt;attribute name="answerValueUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="formUUID" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
         *     &lt;/restriction>
         *   &lt;/complexContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "")
        public static class AnswerSkipRule {

            @XmlAttribute(required = true)
            protected String answerValueUUID;
            @XmlAttribute(required = true)
            protected String formUUID;

            /**
             * Gets the value of the answerValueUUID property.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getAnswerValueUUID() {
                return answerValueUUID;
            }

            /**
             * Sets the value of the answerValueUUID property.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setAnswerValueUUID(String value) {
                this.answerValueUUID = value;
            }

            /**
             * Gets the value of the formUUID property.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getFormUUID() {
                return formUUID;
            }

            /**
             * Sets the value of the formUUID property.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setFormUUID(String value) {
                this.formUUID = value;
            }

        }

    }

}
