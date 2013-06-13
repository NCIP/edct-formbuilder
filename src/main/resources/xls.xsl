
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="urn:schemas-microsoft-com:office:spreadsheet"
xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
xmlns:x="urn:schemas-microsoft-com:office:excel">
	
    <xsl:template match="/">
        <xsl:processing-instruction name="mso-application">progid="Excel.Sheet"</xsl:processing-instruction>
        <Workbook >
            <xsl:apply-templates/>
        </Workbook>
    </xsl:template>
    <xsl:template match="/cure">
 <Styles>
  <Style ss:ID="Default" ss:Name="Normal">
   <Alignment ss:Vertical="Top" ss:WrapText="1"/>
   <Borders/>
   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
   <Interior/>
   <NumberFormat/>
   <Protection/>
  </Style>
  <Style ss:ID="s68">
   <Alignment ss:Vertical="Top" ss:WrapText="1"/>
   <NumberFormat ss:Format="@"/>
  </Style>
  <Style ss:ID="s97">
   <Interior ss:Color="#B7DEE8" ss:Pattern="Solid"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
  <Style ss:ID="s106">
   <Interior ss:Color="#31869B" ss:Pattern="Solid"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
  <Style ss:ID="s116">
   <Alignment ss:Vertical="Top" ss:WrapText="1"/>
   <Interior ss:Color="#31869B" ss:Pattern="Solid"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
  <Style ss:ID="s117">
   <Alignment ss:Vertical="Top" ss:WrapText="1"/>
   <Interior ss:Color="#B7DEE8" ss:Pattern="Solid"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
  <Style ss:ID="s118">
   <Alignment ss:Vertical="Top" ss:WrapText="1"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
  <Style ss:ID="s119">
   <Alignment ss:Vertical="Top" ss:WrapText="1"/>
   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
   <Style ss:ID="s127">
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
  <Style ss:ID="s140">
   <Alignment ss:Vertical="Top" ss:WrapText="1" />
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
   <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>
  </Style>
  <Style ss:ID="s141">
   <Alignment ss:Vertical="Top" ss:WrapText="1"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
 </Styles>
 
 
	<xsl:variable name="sheetName">
	<xsl:choose><xsl:when test="not(/cure/module/moduleName)"><xsl:text>Sheet1</xsl:text></xsl:when>
	  <xsl:otherwise>
	      <xsl:value-of select="/cure/module/moduleName"/>
	 </xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
 		
       <Worksheet ss:Name="{$sheetName}">
            <Table >
	           <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="199.5"/>
	           <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="120"/>
	           <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="120"/>		   
			   <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="120"/>
			   <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="120"/>
			   <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="75"/>
			   <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="97.5"/>
			   <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="97.5"/>
			   <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="168.75"/>
			   <Column ss:StyleID="s118" ss:AutoFitWidth="0" ss:Width="97.5"/>
	            <Row ss:AutoFitHeight="0" ss:StyleID="s106">
	                <Cell ss:StyleID="s116"><Data ss:Type="String">Form Name</Data></Cell>
	                <Cell ss:StyleID="s116"><Data ss:Type="String">Table Description</Data></Cell>
				    <Cell ss:StyleID="s116"><Data ss:Type="String">Table Short Name</Data></Cell>
				    <Cell ss:StyleID="s116"><Data ss:Type="String">Question Description</Data></Cell>
				    <Cell ss:StyleID="s116"><Data ss:Type="String">Question Short Name</Data></Cell>
				    <Cell ss:StyleID="s116"><Data ss:Type="String">Answer Type</Data></Cell>
				    <Cell ss:StyleID="s116"><Data ss:Type="String">Answer Description</Data></Cell>
				    <Cell ss:StyleID="s116"><Data ss:Type="String">Answer Value</Data></Cell>
				    <Cell ss:StyleID="s116"><Data ss:Type="String">Question Visibility Rule</Data></Cell>
				    <Cell ss:StyleID="s116"><Data ss:Type="String">Question Source</Data></Cell>
	            </Row>
                <xsl:choose>
	  				<xsl:when test="not(/cure/module/moduleName)">
	    				<xsl:apply-templates select="/cure/form"/>
	  				</xsl:when>
	  				<xsl:otherwise>
	      				<xsl:for-each select="/cure/module">
	                     <xsl:for-each select="./section">
	                         <xsl:call-template name="process-section"/>
	                     </xsl:for-each>
                    </xsl:for-each>
	 				</xsl:otherwise>
				</xsl:choose>

                    
            </Table>
        </Worksheet>
    </xsl:template>
    <xsl:template name="process-section">
        <xsl:variable name="idref" select="@ref"></xsl:variable> 
         <Row ss:StyleID="s97">
         	<Cell  ss:StyleID="s117">
            	<Data ss:Type="String">
            		<xsl:value-of select="/cure/form[@id= $idref]/name"/>
            	</Data>
            </Cell>
            <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
         </Row>
          <xsl:apply-templates select="/cure/form[@id= $idref]/*"/>
    </xsl:template>
    <xsl:template match="form">
   	     <Row ss:StyleID="s97">
         	<Cell  ss:StyleID="s117">
            	<Data ss:Type="String">
            		<xsl:value-of select="name"/>
            	</Data>
            </Cell>
            <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
		    <Cell ss:StyleID="s117"/>
         </Row>
         <xsl:apply-templates>
             <xsl:sort select="@order"/>
         </xsl:apply-templates>
    </xsl:template>


<xsl:template match="linkElement">
         <xsl:variable name="rowStyle">
	         <xsl:call-template name="setRowStyle">
	         	<xsl:with-param name="order" select="@order"/>
	         </xsl:call-template>
         </xsl:variable>
   	     <Row  ss:StyleID="{$rowStyle}">
   	        <xsl:variable name="columnIndex">
   	        	<xsl:choose>
   	        		<xsl:when test="descendant::questionElement"> 
   	        		<xsl:text>4</xsl:text>
   	        		</xsl:when>
   	        		<xsl:otherwise>
   	        		<xsl:text>2</xsl:text>
   	        		</xsl:otherwise>
   	        	</xsl:choose>
   	        </xsl:variable>
            <Cell ss:Index="{$columnIndex}"><Data ss:Type="String"><xsl:value-of select="description"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="descendant::questionElement/question/shortName | descendant::tableShortName"/></Data></Cell>
	        <Cell ss:Index="6"><Data ss:Type="String"><xsl:value-of select="descendant::answer/@type"/></Data></Cell>
	        <Cell ss:Index="9"><Data ss:Type="String"><xsl:call-template name="skipRule"/></Data></Cell>
         </Row>
         
         <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="questionElement">
        <xsl:variable name="order">
        	<xsl:choose>
                <xsl:when test="ancestor::linkElement">
                	<xsl:value-of select="ancestor::linkElement/@order"/>
                </xsl:when>
                <xsl:otherwise>
                	<xsl:value-of select="@order"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    	<xsl:variable name="rowStyle">
         <xsl:call-template name="setRowStyle">
         	<xsl:with-param name="order" select="$order"/>
         </xsl:call-template>
         </xsl:variable>
         <xsl:if test="parent::form">
   	     <Row   ss:StyleID="{$rowStyle}">
            <Cell ss:Index="4"><Data ss:Type="String"><xsl:value-of select="descriptions/mainDescription"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="question/shortName"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="question/answer/@type"/></Data></Cell>	        
	        <Cell ss:Index="9"><Data ss:Type="String"><xsl:call-template name="skipRule"/></Data></Cell>
	        
         </Row>
         </xsl:if>
         <xsl:apply-templates/>
         
    </xsl:template>
    
    <xsl:template match="externalQuestionElement">
        <xsl:variable name="order" select="@order"/>
    	<xsl:variable name="rowStyle">
         <xsl:call-template name="setRowStyle">
         	<xsl:with-param name="order" select="$order"/>
         </xsl:call-template>
         </xsl:variable>
   	     <Row   ss:StyleID="{$rowStyle}">
            <Cell ss:Index="4"><Data ss:Type="String"><xsl:value-of select="descriptions/mainDescription"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="question/shortName"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="question/answer/@type"/></Data></Cell>	        
	        <Cell ss:Index="9"><Data ss:Type="String"><xsl:call-template name="skipRule"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="@externalSource"/></Data></Cell>
	        
         </Row>
         <xsl:apply-templates/>
         
    </xsl:template>
     
    <xsl:template match="content">
    	<xsl:variable name="rowStyle">
	         <xsl:call-template name="setRowStyle">
	         	<xsl:with-param name="order" select="@order"/>
	         </xsl:call-template>
         </xsl:variable>
   	     <Row ss:StyleID="{$rowStyle}">
            <Cell ss:Index="4"><Data ss:Type="String"><xsl:value-of select="description"/></Data></Cell>
         </Row>
         <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tableElement">
    <xsl:variable name="order">
        	<xsl:choose>
                <xsl:when test="ancestor::linkElement">
                	<xsl:value-of select="ancestor::linkElement/@order"/>
                </xsl:when>
                <xsl:otherwise>
                	<xsl:value-of select="@order"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    	<xsl:variable name="rowStyle">
	         <xsl:call-template name="setRowStyle">
	         	<xsl:with-param name="order" select="$order"/>
	         </xsl:call-template>
         </xsl:variable>
         <xsl:if test="parent::form">
   	     <Row ss:StyleID="{$rowStyle}">
   	     	<Cell ss:Index="2"><Data ss:Type="String"><xsl:value-of select="descriptions/mainDescription"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="tableShortName"/></Data></Cell>
	        <Cell ss:Index="9"><Data ss:Type="String"><xsl:call-template name="skipRule"/></Data></Cell>
         </Row>
         </xsl:if>
         <xsl:for-each select="question">
	           <xsl:call-template name="processQuestions">
	           	<xsl:with-param name="parentOrder" select="$order"/>
	           </xsl:call-template>
	     </xsl:for-each>
    </xsl:template>
    
     <xsl:template match="answerValue">
     	<xsl:variable name="rowStyle">
	         <xsl:call-template name="setRowStyle">
	         	<xsl:with-param name="order">
	         	   <xsl:choose>
	         	   		<xsl:when test="ancestor::linkElement">
	         	   		   <xsl:value-of select="ancestor::linkElement/@order"/>
	         	   		</xsl:when>
	         	   		<xsl:otherwise>
	         	   		   <xsl:choose>
			         	   		<xsl:when test="ancestor::questionElement">
			         	   		   <xsl:value-of select="ancestor::questionElement/@order"/>
			         	   		</xsl:when>
			         	   		<xsl:when test="ancestor::tableElement">
			         	   		   <xsl:value-of select="ancestor::tableElement/@order"/>
			         	   		</xsl:when>
			         	   		<xsl:when test="ancestor::externalElement">
			         	   		   <xsl:value-of select="ancestor::externalElement/@order"/>
			         	   		</xsl:when>
		         	   		</xsl:choose>
	         	   		</xsl:otherwise>
	         	   </xsl:choose>
	         	</xsl:with-param>
	         </xsl:call-template>
         </xsl:variable>
   	     <Row ss:StyleID="{$rowStyle}">
	        <Cell ss:Index="7"><Data ss:Type="String"><xsl:value-of select="description"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="value"/></Data></Cell>
         </Row>
    </xsl:template>
    <xsl:template name="processQuestions">
    	<xsl:param name="parentOrder"/>
    	<xsl:variable name="rowStyle">
	         <xsl:call-template name="setRowStyle">
	         	<xsl:with-param name="order" select="$parentOrder"/>
	         </xsl:call-template>
         </xsl:variable>
   	     <Row ss:StyleID="{$rowStyle}">
            <Cell ss:Index="4"><Data ss:Type="String"><xsl:value-of select="descriptions/mainDescription"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="shortName"/></Data></Cell>
	        <Cell><Data ss:Type="String"><xsl:value-of select="answer/@type"/></Data></Cell>
         </Row>
         <xsl:apply-templates />
    </xsl:template>
    <xsl:template name="skipRule">
         <xsl:variable name="logicalOp" select="skipRule/@logicalOp"/>
         <xsl:for-each select="skipRule/questionSkipRule">
         	<xsl:variable name="questionLogicalOp" select="@logicalOp"/>
         	<xsl:text>Show this question when answer</xsl:text>
             <xsl:for-each select="answerSkipRule">
	             <xsl:variable name="answerId" select="@answerValueUUID"/>
	             <xsl:variable name="formId" select="@formUUID"/>
	             <xsl:text> </xsl:text>
	             <xsl:value-of select="//form[@id=$formId]//answerValue[@uuid=$answerId]/description"/>
	             <xsl:text> </xsl:text>
	             <xsl:if test="position()!= last()">
	             <xsl:text> </xsl:text>
	             <xsl:value-of select="$questionLogicalOp"/>
	             <xsl:text> </xsl:text>
	             </xsl:if>
             </xsl:for-each>
             <xsl:text> Question: </xsl:text>
             <xsl:variable name="triggerQuestionId" select="@triggerQuestionUUID"/>
             <xsl:variable name="triggerFormId" select="@triggerFormUUID"/>
             <xsl:choose>
                    <xsl:when test="not(//form[@id=$triggerFormId]//question[@uuid=$triggerQuestionId]/descriptions/mainDescription)">
	    				<xsl:value-of select="//form[@id=$triggerFormId]//question[@uuid=$triggerQuestionId]/../descriptions/mainDescription"/>
	  				</xsl:when>
	  				<xsl:otherwise>
	      				<xsl:value-of select="//form[@id=$triggerFormId]//question[@uuid=$triggerQuestionId]/descriptions/mainDescription"/>
	 				</xsl:otherwise>
             </xsl:choose>
             <xsl:if test="position()!= last()">
             <xsl:text> </xsl:text>
             <xsl:value-of select="$logicalOp"/>
             <xsl:text> </xsl:text>
             </xsl:if>
         </xsl:for-each>
    </xsl:template>
    <xsl:template name="setRowStyle">
    	<xsl:param name="order"/>
    	<xsl:choose>
    		<xsl:when test="$order mod 2 != 1">
    		    <xsl:text>s140</xsl:text>
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:text>s141</xsl:text>
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:template>
    <!--  Catch the rest of the text -->
    <xsl:template match="text()" />
    
</xsl:stylesheet>
