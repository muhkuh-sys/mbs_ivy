<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
   Licensed to the Apache Software Foundation (ASF) under one
   or more contributor license agreements.  See the NOTICE file
   distributed with this work for additional information
   regarding copyright ownership.  The ASF licenses this file
   to you under the Apache License, Version 2.0 (the
   "License"); you may not use this file except in compliance
   with the License.  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing,
   software distributed under the License is distributed on an
   "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
   KIND, either express or implied.  See the License for the
   specific language governing permissions and limitations
   under the License.    
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="confs"    select="/ivy-report/info/@confs"/>
<xsl:param name="extension"    select="'xml'"/>

<xsl:variable name="myorg"    select="/ivy-report/info/@organisation"/>
<xsl:variable name="mymod"    select="/ivy-report/info/@module"/>
<xsl:variable name="myconf"   select="/ivy-report/info/@conf"/>

<xsl:variable name="modules"    select="/ivy-report/dependencies/module"/>
<xsl:variable name="conflicts"    select="$modules[count(revision) > 1]"/>

<xsl:variable name="revisions"  select="$modules/revision"/>
<xsl:variable name="evicteds"   select="$revisions[@evicted]"/>
<xsl:variable name="downloadeds"   select="$revisions[@downloaded='true']"/>
<xsl:variable name="searcheds"   select="$revisions[@searched='true']"/>
<xsl:variable name="errors"   select="$revisions[@error]"/>

<xsl:variable name="artifacts"   select="$revisions/artifacts/artifact"/>
<xsl:variable name="cacheartifacts" select="$artifacts[@status='no']"/>
<xsl:variable name="dlartifacts" select="$artifacts[@status='successful']"/>
<xsl:variable name="faileds" select="$artifacts[@status='failed']"/>
<xsl:variable name="artifactsok" select="$artifacts[@status!='failed']"/>

<xsl:template name="calling">
    <xsl:param name="org" />
    <xsl:param name="mod" />
    <xsl:param name="rev" />
    <xsl:if test="count($modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]) = 0">
    <table><tr><td>
    No dependency
    </td></tr></table>
    </xsl:if>
    <xsl:if test="count($modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]) > 0">
    <table class="deps">
      <thead>
      <tr>
        <th>Module</th>
        <th>Revision</th>
        <th>Status</th>
        <th>Resolver</th>
        <th>Default</th>
        <th>Licenses</th>
        <th>Size</th>
        <th></th>
      </tr>
      </thead>
      <tbody>
        <xsl:for-each select="$modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]">
          <xsl:call-template name="called">
            <xsl:with-param name="callstack"     select="concat($org, string('/'), $mod)"/>
            <xsl:with-param name="indent"        select="string('')"/>
            <xsl:with-param name="revision"      select=".."/>
          </xsl:call-template>
        </xsl:for-each>   
      </tbody>
    </table>
    </xsl:if>
</xsl:template>

<xsl:template name="called">
    <xsl:param name="callstack"/>
    <xsl:param name="indent"/>
    <xsl:param name="revision"/>

    <xsl:param name="organisation" select="$revision/../@organisation"/>
    <xsl:param name="module" select="$revision/../@name"/>
    <xsl:param name="rev" select="$revision/@name"/>
    <xsl:param name="resolver" select="$revision/@resolver"/>
    <xsl:param name="isdefault" select="$revision/@default"/>
    <xsl:param name="status" select="$revision/@status"/>
    <tr>
    <td>
       <xsl:element name="a">
         <xsl:attribute name="href">#<xsl:value-of select="$organisation"/>-<xsl:value-of select="$module"/></xsl:attribute>
         <xsl:value-of select="concat($indent, ' ')"/>
         <xsl:value-of select="$module"/>
         by
         <xsl:value-of select="$organisation"/>
       </xsl:element>
    </td>
    <td>
       <xsl:element name="a">
         <xsl:attribute name="href">#<xsl:value-of select="$organisation"/>-<xsl:value-of select="$module"/>-<xsl:value-of select="$rev"/></xsl:attribute>
         <xsl:value-of select="$rev"/>
       </xsl:element>
    </td>
    <td align="center">
         <xsl:value-of select="$status"/>
    </td>
    <td align="center">
         <xsl:value-of select="$resolver"/>
    </td>
    <td align="center">
         <xsl:value-of select="$isdefault"/>
    </td>
    <td align="center">
      <xsl:call-template name="licenses">
        <xsl:with-param name="revision"      select="$revision"/>
      </xsl:call-template>
    </td>
    <td align="center">
      <xsl:value-of select="round(sum($revision/artifacts/artifact/@size) div 1024)"/> kB
    </td>
    <td align="center">
          <xsl:call-template name="icons">
            <xsl:with-param name="revision"      select="$revision"/>
          </xsl:call-template>
    </td>
    </tr>
    <xsl:if test="not($revision/@evicted)">
    <xsl:if test="not(contains($callstack, concat($organisation, string('/'), $module)))">
    <xsl:for-each select="$modules/revision/caller[(@organisation=$organisation and @name=$module) and @callerrev=$rev]">
          <xsl:call-template name="called">
            <xsl:with-param name="callstack"     select="concat($callstack, string('#'), $organisation, string('/'), $module)"/>
            <xsl:with-param name="indent"        select="concat($indent, string('---'))"/>
            <xsl:with-param name="revision"      select=".."/>
          </xsl:call-template>
    </xsl:for-each>   
    </xsl:if>
    </xsl:if>
</xsl:template>

<xsl:template name="licenses">
      <xsl:param name="revision"/>
      <xsl:for-each select="$revision/license">
      	<span style="padding-right:3px;">
      	<xsl:if test="@url">
  	        <xsl:element name="a">
  	            <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
  		    	<xsl:value-of select="@name"/>
  	        </xsl:element>
      	</xsl:if>
      	<xsl:if test="not(@url)">
  		    	<xsl:value-of select="@name"/>
      	</xsl:if>
      	</span>
      </xsl:for-each>
</xsl:template>

<xsl:template name="icons">
    <xsl:param name="revision"/>
    <xsl:if test="$revision/@searched = 'true'">
         <img src="data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAATlBMVEUAAACpssaLlqtMZIFVbIdo
fJUyTm56mbueq7qptcLk6OwJWpggaJ0wcqFBfKRRhqhfjquJqb5plK3V8//r+v+WusGewsP8//+z
2sfB68oFcvkjAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCanBgA
AAAHdElNRQffBxwOOzHgofJlAAAAbElEQVQY022P7Q6AIAhFMYpSK9O0j/d/0UboZs3z426c3cEA
aDBRr+u5QwM960G0GgyABoXA+i2QQkXYsWZojySRwXiiREYjaokQfudDqszG3Gkrs7uE5LJYD8Gv
pbIw3i+fpfM4f69Y23r9AS+zBLopmA5WAAAAAElFTkSuQmCC" alt="searched" title="required a search in repository"/>
    </xsl:if>
    <xsl:if test="$revision/@downloaded = 'true'">
         <img src="data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAD1BMVEVldC0AaAd+0IT/+P////8x
81c9AAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElN
RQffBxwOOiZ6aUbjAAAANklEQVQI12NgwAZYHKAMRxGogJCiAw6Gi5CiC1hAUEhR0AEso6QEkXNU
UhJBVQw3kIHZAavNAJMbBbaBWpyrAAAAAElFTkSuQmCC" alt="downloaded" title="downloaded from repository"/>
    </xsl:if>
    <xsl:if test="$revision/@evicted">
        <xsl:element name="img">
            <xsl:attribute name="src">data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAOVBMVEUAACHoMDjoOEDoQEjoSFDw
aHDAECDoIDDIKDjQYHDIUEDIWEj4sKjIQDi4ODjoUFDweHj4qKjYmJgkoPECAAAAAXRSTlMAQObY
ZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQffBxwOOyH9FuIBAAAA
S0lEQVQY053POxaAIBBDUfwwAgoy2f9iLTKx9njLd9IkpV9wChjaJS2C3+QROnZCV9hIYcyFpkI+
KA+G8i4Kg2ElWASXCNWkfjn2AEaxBE84OkObAAAAAElFTkSuQmCC</xsl:attribute>
            <xsl:attribute name="alt">evicted</xsl:attribute>
            <xsl:attribute name="title">evicted by <xsl:for-each select="$revision/evicted-by"><xsl:value-of select="@rev"/> </xsl:for-each></xsl:attribute>
        </xsl:element>
    </xsl:if>
    <xsl:if test="$revision/@error">
        <xsl:element name="img">
            <xsl:attribute name="src">data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA1VBMVEUAABTyXF/zY2bzZGf1h4jw
T1bwUFfuWF3yW1/xW2DyZ2zvbnPrbXHwc3f1en/1fIDtR1HxTVbxTlbdSlTeS1PfT1f1bXX0bXW7
EiDCHyvOKTjGKzbuO0jROEXdQE3xTlrrVWD0YG3TVl/caXLIFinIGCrIGCvIGSvCHC3kL0DXY27f
doHOIjnfmqXmq7XKXUnObl7CW0z3iYD3oprJRz72f3n2gHn2iIDgYVv1dnLzeXTteXX4i4jxjIny
Zmbzb23tgoD3i4nwh4X/v7/btrbjxMT///8U+I1zAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgA
AAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQffBxwOOwnIo0r7AAAAvUlEQVQY022P6Q6CQAyE
vUVEWFA8EBDBC1EEXW8FdLHv/0gWDP+ctE36pZN0SqV/SsMdpbvgU+wBvSSHQ3KhwW8P6fN8ut2O
+zsN83v6vsYQx9hvmiJw1EcUMYiARS/VRmAIVa5cBmAtriIYCOaSjAKQFaUhLRDMpq7rMgCc7mSW
WSxdZ5CVrluZxTEHBAghjJG+6SDwN22+notva372iKd1xCZK7Gje71Vv1RNqNaE7WhdhtvZ4uDTs
7d/kX4IHGaXq+On+AAAAAElFTkSuQmCC</xsl:attribute>
            <xsl:attribute name="alt">error</xsl:attribute>
            <xsl:attribute name="title">error: <xsl:value-of select="$revision/@error"/></xsl:attribute>
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template name="error">
    <xsl:param name="organisation"/>
    <xsl:param name="module"/>
    <xsl:param name="revision"/>
    <xsl:param name="error"/>
    <tr>
    <td>
       <xsl:element name="a">
         <xsl:attribute name="href">#<xsl:value-of select="$organisation"/>-<xsl:value-of select="$module"/></xsl:attribute>
         <xsl:value-of select="$module"/>
         by
         <xsl:value-of select="$organisation"/>
       </xsl:element>
    </td>
    <td>
       <xsl:element name="a">
         <xsl:attribute name="href">#<xsl:value-of select="$organisation"/>-<xsl:value-of select="$module"/>-<xsl:value-of select="$revision"/></xsl:attribute>
         <xsl:value-of select="$revision"/>
       </xsl:element>
    </td>
    <td>
         <xsl:value-of select="$error"/>
    </td>
    </tr>
</xsl:template>

<xsl:template name="confs">
    <xsl:param name="configurations"/>
    
    <xsl:if test="contains($configurations, ',')">
      <xsl:call-template name="conf">
        <xsl:with-param name="conf" select="normalize-space(substring-before($configurations,','))"/>
      </xsl:call-template>
      <xsl:call-template name="confs">
        <xsl:with-param name="configurations" select="substring-after($configurations,',')"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(contains($configurations, ','))">
      <xsl:call-template name="conf">
        <xsl:with-param name="conf" select="normalize-space($configurations)"/>
      </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="conf">
    <xsl:param name="conf"/>
    
     <li>
       <xsl:element name="a">
         <xsl:if test="$conf = $myconf">
           <xsl:attribute name="class">active</xsl:attribute>
         </xsl:if>
         <xsl:attribute name="href"><xsl:value-of select="$myorg"/>-<xsl:value-of select="$mymod"/>-<xsl:value-of select="$conf"/>.<xsl:value-of select="$extension"/></xsl:attribute>
         <xsl:value-of select="$conf"/>
       </xsl:element>
     </li>
</xsl:template>

<xsl:template name="date">
    <xsl:param name="date"/>
    
    <xsl:value-of select="substring($date,1,4)"/>-<xsl:value-of select="substring($date,5,2)"/>-<xsl:value-of select="substring($date,7,2)"/>
    <xsl:value-of select="' '"/>
    <xsl:value-of select="substring($date,9,2)"/>:<xsl:value-of select="substring($date,11,2)"/>:<xsl:value-of select="substring($date,13)"/>
</xsl:template>


<xsl:template match="/ivy-report">

  <html>
  <head>
    <title>Ivy report :: <xsl:value-of select="info/@module"/> by <xsl:value-of select="info/@organisation"/> :: <xsl:value-of select="info/@conf"/></title>
    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
    <meta http-equiv="content-language" content="en" />
    <meta name="robots" content="index,follow" />
    <style type="text/css">
body {
	font-family:"Trebuchet MS",Verdana,Geneva,Arial,Helvetica,sans-serif;
	font-size:small;
}

div#logo {
	float: right;
	padding-left: 10px;
	padding-bottom: 10px;
	background: white;
	text-align: center;
}

#logo img {
	border: 0;
}

div#date {
	font-style: italic;
	padding-left: 60px;
	padding-bottom: 40px;
}


h1 {
	margin-bottom:2px;
	border-color:#7A9437;
	border-style:solid;
	border-width:0 0 3px 0;
}

span#module {
	color:#7A9437;
	text-decoration:none;
}

span#organisation {
	color:black;
	text-decoration:none;
}

#confmenu {
	color: #000;
	border-bottom: 2px solid black;
	margin: 12px 0px 0px 0px;
	padding: 0px;
	z-index: 1;
	padding-left: 10px;
}

#confmenu li {
	display: inline;
	overflow: hidden;
	list-style-type: none;
}

#confmenu a, a.active {
	color: #DEDECF;
	background: #898B5E;
	font: bold 1em "Trebuchet MS", Arial, sans-serif;
	border: 2px solid black;
	padding: 2px 5px 0px 5px;
	text-decoration: none;
}

/*
background: #ABAD85 #CED4BD
background: #DEE4CD
*/

#confmenu a.active {
	color: #7A9437;
	background: #DEE4CD;
	border-bottom: 3px solid #DEE4CD;
}

#confmenu a:hover {
	color: #fff;
	background: #ADC09F;
}

#confmenu a:visited {
	color: #DEDECF;
}

#confmenu a.active:visited {
	color: #7A9437;
}

#confmenu a.active:hover {
	background: #DEE4CD;
	color: #DEDECF;
}

#content {
	background: #DEE4CD;
	padding: 20px;
	border: 2px solid black;
	border-top: none;
	z-index: 2;
}

#content a {
	text-decoration: none;
	color: #E8E9BE;
}

#content a:hover {
	background: #898B5E;
}


h2 {
	margin-bottom:2px;
	font-size:medium;

	border-color:#7A9437;
	border-style:solid;
	border-width:0 0 2px 0;
}

h3 {
	margin-top:30px;
	margin-bottom:2px;
	padding: 5 5 5 0;
	font-size: 24px;
	border-style:solid;
	border-width:0 0 2px 0;
}

h4 {
	margin-bottom:2px;
	margin-top:2px;
	font-size:medium;

	border-color:#7A9437;
	border-style:dashed;
	border-width:0 0 1px 0;
}

h5 {
	margin-bottom:2px;
	margin-top:2px;
	margin-left:20px;
	font-size:medium;
}

span.resolved {
	padding-left: 15px;
	font-weight: 500;
	font-size: small;
}


#content table  {
	border-collapse:collapse;
	width:90%;
	margin:auto;
	margin-top: 5px;
}
#content thead {
	background-color:#CED4BD;
	border:1px solid #7A9437;
}
#content tbody {
	border-collapse:collapse;
	background-color:#FFFFFF;
	border:1px solid #7A9437;
}

#content th {
	font-family:monospace;
	border:1px solid #7A9437;
	padding:5px;
}

#content td {
	border:1px dotted #7A9437;
	padding:0 3 0 3;
}

#content table a {
	color:#7A9437;
	text-decoration:none;
}

#content table a:hover {
	background-color:#CED4BD;
	color:#7A9437;
}



table.deps  {
	border-collapse:collapse;
	width:90%;
	margin:auto;
	margin-top: 5px;
}

table.deps thead {
	background-color:#CED4BD;
	border:1px solid #7A9437;
}
table.deps tbody {
	border-collapse:collapse;
	background-color:#FFFFFF;
	border:1px solid #7A9437;
}

table.deps th {
	font-family:monospace;
	border:1px solid #7A9437;
	padding:2;
}

table.deps td {
	border:1px dotted #7A9437;
	padding:0 3 0 3;
}





table.header  {
	border:0;
	width:90%;
	margin:auto;
	margin-top: 5px;
}

table.header thead {
	border:0;
}
table.header tbody {
	border:0;
}
table.header tr {
	padding:0px;
	border:0;
}
table.header td {
	padding:0 3 0 3;
	border:0;
}

td.title {
	width:150px;
	margin-right:15px;

	font-size:small;
	font-weight:700;
}

td.title:first-letter {
	color:#7A9437;
	background-color:transparent;
}
    </style>
  </head>
  <body>
    <div id="logo"><a href="http://ant.apache.org/ivy/"><img src="data:image/png;base64,
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"/></a></div>
    <h1>
      <xsl:element name="a">
        <xsl:attribute name="name"><xsl:value-of select="info/@organisation"/>-<xsl:value-of select="info/@module"/></xsl:attribute>
      </xsl:element>
        <span id="module">
    	        <xsl:value-of select="concat(info/@module, ' ', info/@revision)"/>
        </span> 
        by 
        <span id="organisation">
    	        <xsl:value-of select="info/@organisation"/>
        </span>
    </h1>
    <div id="date">
    resolved on 
      <xsl:call-template name="date">
        <xsl:with-param name="date" select="info/@date"/>
      </xsl:call-template>
    </div>
    <ul id="confmenu">
      <xsl:call-template name="confs">
        <xsl:with-param name="configurations" select="$confs"/>
      </xsl:call-template>
    </ul>

    <div id="content">
    <h2>Dependencies Stats</h2>
        <table class="header">
          <tr><td class="title">Modules</td><td class="value"><xsl:value-of select="count($modules)"/></td></tr>
          <tr><td class="title">Revisions</td><td class="value"><xsl:value-of select="count($revisions)"/>  
            (<xsl:value-of select="count($searcheds)"/> searched <img src="data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAATlBMVEUAAACpssaLlqtMZIFVbIdo
fJUyTm56mbueq7qptcLk6OwJWpggaJ0wcqFBfKRRhqhfjquJqb5plK3V8//r+v+WusGewsP8//+z
2sfB68oFcvkjAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCanBgA
AAAHdElNRQffBxwOOzHgofJlAAAAbElEQVQY022P7Q6AIAhFMYpSK9O0j/d/0UboZs3z426c3cEA
aDBRr+u5QwM960G0GgyABoXA+i2QQkXYsWZojySRwXiiREYjaokQfudDqszG3Gkrs7uE5LJYD8Gv
pbIw3i+fpfM4f69Y23r9AS+zBLopmA5WAAAAAElFTkSuQmCC" alt="searched" title="module revisions which required a search with a dependency resolver to be resolved"/>,
            <xsl:value-of select="count($downloadeds)"/> downloaded <img src="data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAD1BMVEVldC0AaAd+0IT/+P////8x
81c9AAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElN
RQffBxwOOiZ6aUbjAAAANklEQVQI12NgwAZYHKAMRxGogJCiAw6Gi5CiC1hAUEhR0AEso6QEkXNU
UhJBVQw3kIHZAavNAJMbBbaBWpyrAAAAAElFTkSuQmCC" alt="downloaded" title="module revisions for which ivy file was downloaded by dependency resolver"/>,
            <xsl:value-of select="count($evicteds)"/> evicted <img src="data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAOVBMVEUAACHoMDjoOEDoQEjoSFDw
aHDAECDoIDDIKDjQYHDIUEDIWEj4sKjIQDi4ODjoUFDweHj4qKjYmJgkoPECAAAAAXRSTlMAQObY
ZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQffBxwOOyH9FuIBAAAA
S0lEQVQY053POxaAIBBDUfwwAgoy2f9iLTKx9njLd9IkpV9wChjaJS2C3+QROnZCV9hIYcyFpkI+
KA+G8i4Kg2ElWASXCNWkfjn2AEaxBE84OkObAAAAAElFTkSuQmCC" alt="evicted" title="module revisions which were evicted by others"/>,
            <xsl:value-of select="count($errors)"/> errors <img src="data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAA1VBMVEUAABTyXF/zY2bzZGf1h4jw
T1bwUFfuWF3yW1/xW2DyZ2zvbnPrbXHwc3f1en/1fIDtR1HxTVbxTlbdSlTeS1PfT1f1bXX0bXW7
EiDCHyvOKTjGKzbuO0jROEXdQE3xTlrrVWD0YG3TVl/caXLIFinIGCrIGCvIGSvCHC3kL0DXY27f
doHOIjnfmqXmq7XKXUnObl7CW0z3iYD3oprJRz72f3n2gHn2iIDgYVv1dnLzeXTteXX4i4jxjIny
Zmbzb23tgoD3i4nwh4X/v7/btrbjxMT///8U+I1zAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgA
AAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQffBxwOOwnIo0r7AAAAvUlEQVQY022P6Q6CQAyE
vUVEWFA8EBDBC1EEXW8FdLHv/0gWDP+ctE36pZN0SqV/SsMdpbvgU+wBvSSHQ3KhwW8P6fN8ut2O
+zsN83v6vsYQx9hvmiJw1EcUMYiARS/VRmAIVa5cBmAtriIYCOaSjAKQFaUhLRDMpq7rMgCc7mSW
WSxdZ5CVrluZxTEHBAghjJG+6SDwN22+notva372iKd1xCZK7Gje71Vv1RNqNaE7WhdhtvZ4uDTs
7d/kX4IHGaXq+On+AAAAAElFTkSuQmCC" alt="error" title="module revisions on which error occurred"/>)</td></tr>
          <tr><td class="title">Artifacts</td><td class="value"><xsl:value-of select="count($artifacts)"/> 
            (<xsl:value-of select="count($dlartifacts)"/> downloaded,
            <xsl:value-of select="count($faileds)"/> failed)</td></tr>
          <tr><td class="title">Artifacts size</td><td class="value"><xsl:value-of select="round(sum($artifacts/@size) div 1024)"/> kB
            (<xsl:value-of select="round(sum($dlartifacts/@size) div 1024)"/> kB downloaded,
            <xsl:value-of select="round(sum($cacheartifacts/@size) div 1024)"/> kB in cache)</td></tr>
        </table>
    
    <xsl:if test="count($errors) > 0">
    <h2>Errors</h2>
    <table class="errors">
      <thead>
      <tr>
        <th>Module</th>
        <th>Revision</th>
        <th>Error</th>
      </tr>
      </thead>
      <tbody>
      <xsl:for-each select="$errors">
          <xsl:call-template name="error">
            <xsl:with-param name="organisation"  select="../@organisation"/>
            <xsl:with-param name="module"        select="../@name"/>
            <xsl:with-param name="revision"      select="@name"/>
            <xsl:with-param name="error"        select="@error"/>
          </xsl:call-template>
      </xsl:for-each>
      </tbody>
      </table>
    </xsl:if>

    <xsl:if test="count($conflicts) > 0">
    <h2>Conflicts</h2>
    <table class="conflicts">
      <thead>
      <tr>
        <th>Module</th>
        <th>Selected</th>
        <th>Evicted</th>
      </tr>
      </thead>
      <tbody>
      <xsl:for-each select="$conflicts">
        <tr>
        <td>
           <xsl:element name="a">
             <xsl:attribute name="href">#<xsl:value-of select="@organisation"/>-<xsl:value-of select="@name"/></xsl:attribute>
             <xsl:value-of select="@name"/>
             by
             <xsl:value-of select="@organisation"/>
           </xsl:element>
        </td>
        <td>
          <xsl:for-each select="revision[not(@evicted)]">
             <xsl:element name="a">
               <xsl:attribute name="href">#<xsl:value-of select="../@organisation"/>-<xsl:value-of select="../@name"/>-<xsl:value-of select="@name"/></xsl:attribute>
               <xsl:value-of select="@name"/>
             </xsl:element>
             <xsl:text> </xsl:text>
          </xsl:for-each>
        </td>
        <td>
          <xsl:for-each select="revision[@evicted]">
             <xsl:element name="a">
               <xsl:attribute name="href">#<xsl:value-of select="../@organisation"/>-<xsl:value-of select="../@name"/>-<xsl:value-of select="@name"/></xsl:attribute>
               <xsl:value-of select="@name"/>
			   <xsl:text> </xsl:text>
               <xsl:value-of select="@evicted-reason"/>
             </xsl:element>
             <xsl:text> </xsl:text>
          </xsl:for-each>
        </td>
        </tr>
      </xsl:for-each>
      </tbody>
      </table>
    </xsl:if>

    <h2>Dependencies Overview</h2>
        <xsl:call-template name="calling">
          <xsl:with-param name="org" select="info/@organisation"/>
          <xsl:with-param name="mod" select="info/@module"/>
          <xsl:with-param name="rev" select="info/@revision"/>
        </xsl:call-template>

    <h2>Details</h2>    
    <xsl:for-each select="$modules">
    <h3>
      <xsl:element name="a">
         <xsl:attribute name="name"><xsl:value-of select="@organisation"/>-<xsl:value-of select="@name"/></xsl:attribute>
      </xsl:element>
      <xsl:value-of select="@name"/> by <xsl:value-of select="@organisation"/>
    </h3>    
      <xsl:for-each select="revision">
        <h4>
          <xsl:element name="a">
             <xsl:attribute name="name"><xsl:value-of select="../@organisation"/>-<xsl:value-of select="../@name"/>-<xsl:value-of select="@name"/></xsl:attribute>
          </xsl:element>
           Revision: <xsl:value-of select="@name"/>
          <span style="padding-left:15px;">
          <xsl:call-template name="icons">
            <xsl:with-param name="revision"      select="."/>
          </xsl:call-template>
          </span>
        </h4>
        <table class="header">
        	<xsl:if test="@homepage">
            <tr><td class="title">Home Page</td><td class="value">
              <xsl:element name="a">
    	            <xsl:attribute name="href"><xsl:value-of select="@homepage"/></xsl:attribute>
    		    	<xsl:value-of select="@homepage"/>
    	        </xsl:element></td>
            </tr>  	        
        	</xsl:if>
          <tr><td class="title">Status</td><td class="value"><xsl:value-of select="@status"/></td></tr>
          <tr><td class="title">VCS ID</td><td class="value"><xsl:value-of select="@extra-vcs-id"/></td></tr>
          <tr><td class="title">Resolver</td><td class="value"><xsl:value-of select="@resolver"/></td></tr>
          <tr><td class="title">Configurations</td><td class="value"><xsl:value-of select="@conf"/></td></tr>
          <tr><td class="title">Artifacts size</td><td class="value"><xsl:value-of select="round(sum(artifacts/artifact/@size) div 1024)"/> kB
            (<xsl:value-of select="round(sum(artifacts/artifact[@status='successful']/@size) div 1024)"/> kB downloaded,
            <xsl:value-of select="round(sum(artifacts/artifact[@status='no']/@size) div 1024)"/> kB in cache)</td></tr>
        	<xsl:if test="count(license) > 0">
            <tr><td class="title">Licenses</td><td class="value">
			      <xsl:call-template name="licenses">
			        <xsl:with-param name="revision"      select="."/>
			      </xsl:call-template>
            </td></tr>  	        
        	</xsl:if>
        <xsl:if test="@evicted">
        <tr><td class="title">Evicted by</td><td class="value">  
            <b>
			<xsl:for-each select="evicted-by">
              <xsl:value-of select="@rev"/>
			  <xsl:text> </xsl:text>
            </xsl:for-each>
			</b>
			<xsl:text> </xsl:text>
             <b><xsl:value-of select="@evicted-reason"/></b>
			 in <b><xsl:value-of select="@evicted"/></b> conflict manager
        </td></tr>
        </xsl:if>
        </table>
        <h5>Required by</h5>
        <table>
          <thead>
          <tr>
            <th>Organisation</th>
            <th>Name</th>
            <th>Revision</th>
            <th>In Configurations</th>
            <th>Asked Revision</th>
          </tr>
          </thead>
          <tbody>
            <xsl:for-each select="caller">
              <tr>
              <td><xsl:value-of select="@organisation"/></td>
              <td>
      	         <xsl:element name="a">
	                 <xsl:attribute name="href">#<xsl:value-of select="@organisation"/>-<xsl:value-of select="@name"/></xsl:attribute>
		    	         <xsl:value-of select="@name"/>
	               </xsl:element>
              </td>
              <td><xsl:value-of select="@callerrev"/></td>
              <td><xsl:value-of select="@conf"/></td>
              <td><xsl:value-of select="@rev"/></td>
              </tr>
            </xsl:for-each>   
          </tbody>
        </table>
        <xsl:if test="not(@evicted)">
        
        <h5>Dependencies</h5>
        <xsl:call-template name="calling">
          <xsl:with-param name="org" select="../@organisation"/>
          <xsl:with-param name="mod" select="../@name"/>
          <xsl:with-param name="rev" select="@name"/>
        </xsl:call-template>
        <h5>Artifacts</h5>
        <xsl:if test="count(artifacts/artifact) = 0">
        <table><tr><td>
        No artifact
        </td></tr></table>
        </xsl:if>
        <xsl:if test="count(artifacts/artifact) > 0">
        <table>
          <thead>
          <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Ext</th>
            <th>Download</th>
            <th>Size</th>
          </tr>
          </thead>
          <tbody>
            <xsl:for-each select="artifacts/artifact">
              <tr>
              <td><xsl:value-of select="@name"/></td>
              <td><xsl:value-of select="@type"/></td>
              <td><xsl:value-of select="@ext"/></td>
              <td align="center"><xsl:value-of select="@status"/></td>
              <td align="center"><xsl:value-of select="round(number(@size) div 1024)"/> kB</td>
              </tr>
            </xsl:for-each>    
          </tbody>
        </table>
        </xsl:if>
        
        </xsl:if>
      </xsl:for-each>    
    </xsl:for-each>
    </div>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>
