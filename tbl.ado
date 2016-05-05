/*

					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de
								   
                  The Weaver Package comes with no warranty
				   
	
	Description
	===========
	
	The tbl command is used for creating dynamic tables and its syntax is to 
	some extent similar to "matrix define" command in Stata. Therefore, the 
	dynamic table could be thought of as a matrix that can include anything, a 
	number, string, etc. 
	
	The tbl command supports both Weaver and MarkDoc packages. However, the 
	program functions differently based on which package is in use. When Weaver
	log is on, the command will function for Weaver and when it's off, if there 
	is a smcl log on, then it functions for MarkDoc. 
	
	
	Functions
	---------
	
	MarkDoc: tbl creates a simple Markdown table, without any hierarchy
	Weaver : tbl creates a table in HTML or LaTeX, based on which markup 
			 is in use. 
			 
	
	Note
	----
	
	Before Stata 14, there was no solid function to infer on the type of a
	variable/scalar/macro. Since Weaver is supposed to run on Stata 11 forth, 
	I have programmed an alternative procedure to seperate integers from real 
	numbers, in Macros and Scalars. 
	

	Version
	-------
	
	Weaver version 2.2    September, 2015  
	Weaver version 3.3.6  February,  2015

*/

program define tbl
    version 11
	syntax anything(name=0) [, Width(numlist max=1 >0 <=14000)] 				///
	[Height(numlist max=1 >0 <=14000)] [left|center] [TITle(str)]  				///
	[Markup(str)]
	
	local 0 : subinstr local 0 "\(" "//(", all
	local 0 : subinstr local 0 "\)" "//)", all
	
	****************************************************************************
	* GENERAL SYNTAX PROCESSING
	*
	* - check that only one of the align options is selected
	* - make sure the entery begins and ends with parenthesis
	****************************************************************************
	
	capture weaversetup
	
	
	if "`left'" == "left" & "`center'" == "center" {
		di as err `"{p}The {bf:left} and "' 									///
		`"{bf:center} options cannot be used together"'
		exit 198
	}
	
	if "`markup'" != "markdown" & "`markup'" != "html" & 						///
	"`markup'" != "latex" & !missing("`markup'") {
		di as err `"{p}markup(`markup') not recognized"'
		exit 198
	}
	
	local a : di substr(`"`0'"',1,1)
	local b : di substr(`"`0'"',-1,1)
	if "`a'" ~= "(" | "`b'" ~= ")" {
		di as err "{p}The table entery should be placed in parenthesis"
		err 198
	}
	
	if missing("`center'") & missing("`left'") local center center

	****************************************************************************
	* ENGINE 
	* ======
	*
	* Remove the Paranthesis
	* Remove Quotations
	* Parse the `0' based on "\"
	*
	* - the i presents number of rows
	* - the content of each row is saved in a local macro "m`i'" to obtain 
	*   each directives of the row
	* 
	* Parse each row based on Comma "," to obtain each directive
	****************************************************************************
	
	local len = strlen(`"`macval(0)'"')
	local 0   : di substr(`"`0'"',2,`len'-2)
	
	local 0 : subinstr local 0 "###" " $$ ", all
	local 0 : subinstr local 0 "##" " $ ", all
	
	local 0 : subinstr local 0 `"$""' "$ {c 34}", all
	local 0 : subinstr local 0 `"""' "{c 34}", all	
	
	//For interpreting LaTeX Mathematics
	local 0 : subinstr local 0 "$\"  "$ \", all
	local 0 : subinstr local 0 "\\" "{c 92}", all //Problematic LaTeX
	
*	local 0 : subinstr local 0 "$ \" "$ {c 92}", all
*	local 0 : subinstr local 0 "#\" "{c 92}", all //Problematic LaTeX
	
*	local 0 : subinstr local 0 `"$$""' `"$$ ""', all
*	local 0 : subinstr local 0 `"$""' `"{c 36}""', all
*	local 0 : subinstr local 0 "$" "{c 36}", all
	local i = 0
	*tokenize `"`0'"' , parse("\")
	
	tokenize `"`macval(0)'"' , parse("\")	
	while `"`1'"' ~= "" {
		if `"`1'"' ~= "\" {
			loc i `++i'	
			local 1 : subinstr local 1 "//(" "\(", all
			local 1 : subinstr local 1 "//)" "\)", all
			local m`i' = `"`1'"'		
		}
		macro shift
	}
	
	****************************************************************************
	* FOR WEAVER PACKAGES
	* -------------------
	*
	* - print the table's title
	* - interpret scalars
	****************************************************************************
	if "$weaver" ~= ""  {
			
		html
		html
		if "$weaverMarkup" == "html" {
			if "`title'" ~= "" html <span class="tble`center'">`title'</span> 
			html <table width="`width'" height="`height'" align="`center'" >
		}	
		if "$weaverMarkup" == "latex" {
			html \begin{table}[h] 
			if !missing("`center'") | missing("`left'") html \centering
			if !missing("`left'") html \captionsetup{justification=raggedright,singlelinecheck=false}
			if !missing("`title'") html \caption{`title'} 
		}
	
		forval j = 1/`i' {
			local m : display "`m`j''"	
			if _rc == 0 {
				local this 1
			}
							
			*tokenize "`m`j''" , parse(",")
			if !missing(`this') {		
				tokenize `"`macval(m)'"' , parse(",")	
			}
			else {
				tokenize `"`macval(m`j')'"', parse(",")
			}
				
			local col 0
			local next 0
			local mergedCol 0
				
			// Print the First row
			// ===================
			
			if "`j'" == "1" {
				if "$weaverMarkup" == "html" html <thead>
				if "$weaverMarkup" == "html" html 	<tr class="header">
					
					
				while `"`1'"' ~= "" {					
					if `col' == 0 & "`1'" == "," {
					local align 	// reset the align macro
						if "$weaverMarkup" == "html"  html <th align="center"> </th>
						if "$weaverMarkup" == "latex" local tex`col' " "
						local align l
						local html`col' left					
						*loc col `++col'
					}
						
					if `"`1'"' ~= "," {
						local test
						local test1
						local test2
						local test3
						local align 	// reset the align macro
						
						// MERGING CELLS IN THE FIRST ROW
						// ==============================
							
						// Check if there is any cell merge
						// remember the sign can be placed at the beginning 
						// or the end of the text. 
						
						if substr("`1'",1,3) == "{c}" {
							local 1 : subinstr local 1 "{c}" ""
							local align center
						}
						
						if substr("`1'",1,3) == "{l}" {
							local 1 : subinstr local 1 "{l}" ""
							local align left
						}
						
						if substr("`1'",1,3) == "{r}" {
							local 1 : subinstr local 1 "{r}" ""
							local align right
						}	
						
						if substr("`1'",1,5) == "{col " {
							local 1 : subinstr local 1 "{col " ""
							   
							//Check if it has 1 or 2 digits
							if substr("`1'",2,1) == "}" {
							    local number : di substr("`1'",1,1)
								local 1 : subinstr local 1 "`number'}" ""
							}
							   
							if substr("`1'",3,1) == "}" {
							    local number : di substr("`1'",1,2)
								local 1 : subinstr local 1 "`number'}" ""
							}
							
							if "`number'" == "1" local number 
							
							local nomarkdoc 1
						}
					
						if substr("`1'",1,3) == "{c}" {
							local 1 : subinstr local 1 "{c}" ""
							local align center
						}
						
						if substr("`1'",1,3) == "{l}" {
							local 1 : subinstr local 1 "{l}" ""
							local align left
						}
						
						if substr("`1'",1,3) == "{r}" {
							local 1 : subinstr local 1 "{r}" ""
							local align right
						}
						
							
						// The first column by default always left
						// ---------------------------------------
						
						if `col' == 0 {
							*local 1 : subinstr local 1 "{c 34}" "", all
							local test : display real("`1'")	// exclude real numbers
							if "`test'" == "." {	
							
								capture local test2 : display `1'	//search scalars
								capture local test3 : display int(`test2')								
								// Integers
								if "`test3'" == "`test2'"  {	//is an integer							
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								// Real 
								else if !missing("`test3'") & "`test3'" != "`test2'" {							
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								//Strings
								if missing("`test2'") {						
									local 1 : subinstr local 1 "{c 34}" "", all
								}
							}

							if  missing("`number'") {
								
								if "$weaverMarkup" == "html" {
									if missing("`align'") local align left
									html <th align=	"`align'" style=			///
									"padding:3px 10px 2px 2px;"> `1' </th>
									local html`col' `align'									
								}
								
								if "$weaverMarkup" == "latex" {
									if missing("`align'") local align l
									if "`align'" == "left" local align l
									if "`align'" == "center" local align c
									if "`align'" == "right" local align r
*									local 1 : subinstr local 1 "$$ " " $", all
									local 1 : subinstr local 1 "{c 92}" "\", all
									local texalign `texalign'`align'
									local tex`col' `1'
								}	
							}	
									
							if !missing("`number'") {
								if "$weaverMarkup" == "html" {
									if missing("`align'") local align center
									html <th colspan="`number'" align="`align'" ///
									style="padding:3px 10px 2px 10px;"> `1' </th>
									
									forvalues num = 1/`number' {
										local temp = `col'+`num'
										local html`temp' `align'
									}								
								}	
								
								if "$weaverMarkup" == "latex" {
									if missing("`align'") local align c
									if "`align'" == "left" local align l
									if "`align'" == "center" local align c
									if "`align'" == "right" local align r
									local 1 : subinstr local 1 "{c 92}" "\", all
									local tex`col' \multicolumn{`number'}{c}{`1'}
									local align : di _dup(`number') "`align'"
									local texalign `texalign'`align'
								}	
								
								// Creating the merged column if there was a number
								local mergedCol = `mergedCol' + `number'							
							}	
						}
						
						//The other columns are centered
						if `col' > 0 {					
							/*
							local 1 : subinstr local 1 "{c 34}" "", all
							local test : display real("`1'")
							if "`test'" == "." {
								capture local test2 : display `1'
								capture local test3 : display int(`test2')
								if !missing("`test2'") & "`test3'" == "`test2'"  {  //is an integer
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								else {
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}	
							}
							*/
							
							*local 1 : subinstr local 1 "{c 34}" "", all
							local test : display real("`1'")	// exclude real numbers
							if "`test'" == "." {	
							
								capture local test2 : display `1'	//search scalars
								capture local test3 : display int(`test2')								
								// Integers
								if "`test3'" == "`test2'"  {	//is an integer							
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								// Real 
								else if !missing("`test3'") & "`test3'" != "`test2'" {							
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								//Strings
								if missing("`test2'") {	
									local 1 : subinstr local 1 "{c 92}" "\", all
									local 1 : subinstr local 1 "{c 34}" "", all
								}
							}
							
							/*
							capture local m : display `1'	// for interpreting scalars
							if _rc == 0 {
								local 1 `m'
							}
							*/							
							if  missing("`number'") {
								if "$weaverMarkup" == "html" {
									if missing("`align'") local align center
									html <th align=	"`align'" style= 			///
									"padding:3px 10px 2px 10px;"> `1' </th>								
									
									if "`mergedCol'" != "0" {
										local temp = `col'+`mergedCol'-1
										local html`temp' `align'	
									}
									else {
										local html`col' `align'
									}
								}	
								
								if "$weaverMarkup" == "latex" {
									local tex`col' `1'
									if missing("`align'") local align c
									if "`align'" == "left" local align l
									if "`align'" == "center" local align c
									if "`align'" == "right" local align r
									local 1 : subinstr local 1 "{c 92}" "\", all
									local texalign `texalign'`align'
								}	
							}
									
							if !missing("`number'") {
								if "$weaverMarkup" == "html" {
									if missing("`align'") local align center
									html <th colspan= "`number'" align=			///
									"center" tyle="padding:3px 10px 2px 10px;" ///
									> `1' </th>
									
									forvalues num = 1/`number' {
										local temp = `col'+`mergedCol'+`num'-1
										local html`temp' `align'										
									}
								
								}	
								
								if "$weaverMarkup" == "latex" {
									if missing("`align'") local align c
									if "`align'" == "left" local align l
									if "`align'" == "center" local align c
									if "`align'" == "right" local align r
									local 1 : subinstr local 1 "{c 92}" "\", all
									local align : di _dup(`number') "`align'"
									local texalign `texalign'`align'
									local tex`col' \multicolumn{`number'}{c}{`1'}
								}	
								
								local mergedCol = `mergedCol' + `number'								
							}	
						}
						
						local number 	//reset the value to nothing
						loc col `++col'
					}
						
					macro shift
				}
				
				if "$weaverMarkup" == "html" {
					html </thead>
					local htmlColumns `temp'	//save the number of columns					
				}	
				
				// PRINT THE FIRST ROW OF THE LATEX TABLE
				if "$weaverMarkup" == "latex" {
					*local write l	//the first column is left-aligned
					if !missing(`mergedCol') local mergedCol = `mergedCol' - 1 + `col'
					*forval num = 2/`mergedCol' {
					*	local write `write'c	//the other columns centered
					*}
					html \begin{tabular}{@{}`texalign'@{}}
					html \toprule
					
					forval num = 0/`col' {
						if `num' <  `col'-1 local firstrow `firstrow' `tex`num'' &
						if `num' == `col'-1 local firstrow `firstrow' `tex`num'' \\ \midrule
					}
					html `firstrow' 					
				}
			}
	
			// Print the other rows
			// ====================
				
			if "$weaverMarkup" == "html" {
				if `j' == 2 html <tbody>
			}	
				
			if `j' > 1 {				
					
					
				// Specify if J is Odd or Even
				//----------------------------
				
				if "$weaverMarkup" == "html" {
					//if J is Odd
					if mod(`j',2) html <tr class="odd">
				
					//if J is even
					if !mod(`j',2) html <tr class="even">
				}	
					
				while `"`1'"' ~= "" {	
					if `col' == 0 & "`1'" == "," {
						if "$weaverMarkup" == "html" html <td align="`html0'"> </td>
						if "$weaverMarkup" == "latex" local tex`col' " "						
					}
						
					//Handle consequent commas
					//------------------------
						
						
							
					if `col' > 0 & "`1'" == "," {
								
						//If it's the second column or more and the entery 
						// is ",", then check the next entery. As long as 
						// the next entery is comma, replace it with 
						// empty column
								
						while "`1'" == "," {
							macro shift
									
							if "`1'" == "," {
								if "$weaverMarkup" == "html" html 				///
								<td align="`html`col''"> </td> 
								if "$weaverMarkup" == "latex" local tex`col' " "
							}
						}
					}
						
						
					if `"`1'"' ~= "," {
						local test
						local test1
						local test2
						local test3
							
						// MERGING CELLS IN THE OTHER ROW
						// ==============================
							
						if substr("`1'",1,5) == "{col " {
							   
							local 1 : subinstr local 1 "{col " ""
							   
							//Check if it has 1 or 2 digits
							if substr("`1'",2,1) == "}" {
							    local number : di substr("`1'",1,1)
								local 1 : subinstr local 1 "`number'}" ""
							}
							   
							if substr("`1'",3,1) == "}" {
							    local number : di substr("`1'",1,2)
								local 1 : subinstr local 1 "`number'}" ""
							}
							
							if "`number'" == "1" local number 
							local nomarkdoc 1
						}
												
						if  missing("`number'") {
							*local 1 : subinstr local 1 "{c 34}" "", all
							local test : display real("`1'")	// exclude real numbers
							if "`test'" == "." {	
							
								capture local test2 : display `1'	//search scalars
								capture local test3 : display int(`test2')								
								// Integers
								if "`test3'" == "`test2'"  {	//is an integer							
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								// Real 
								else if !missing("`test3'") & "`test3'" != "`test2'" {							
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								//Strings
								if missing("`test2'") {		
									local 1 : subinstr local 1 "{c 92}" "\", all
									local 1 : subinstr local 1 "{c 34}" "", all
								}
							}


							if "$weaverMarkup" == "html" {
								if `col' == 0 html <td align="`html`col''" 			///
								style="padding:1px 10px 1px 2px;"> `1' </td>
								
								if `col' > 0 html <td align="`html`next''" 			///
								style="padding:1px 10px;"> `1' </td>
							}	
							if "$weaverMarkup" == "latex" {
								if `col' == 0 local nextrow `1' 
								if `col' > 0 local nextrow `nextrow' & `1' 
							}	
						}
							
							
						if  !missing("`number'") {
							*local 1 : subinstr local 1 "{c 34}" "", all
							local test : display real("`1'")	// exclude real numbers
							if "`test'" == "." {	
							
								capture local test2 : display `1'	//search scalars
								capture local test3 : display int(`test2')								
								// Integers
								if "`test3'" == "`test2'"  {	//is an integer							
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								// Real 
								else if !missing("`test3'") & "`test3'" != "`test2'" {							
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								//Strings
								if missing("`test2'") {		
									local 1 : subinstr local 1 "{c 92}" "\", all
									local 1 : subinstr local 1 "{c 34}" "", all
								}
							}
							
							//Always align the merged cells to the center
							
							if "$weaverMarkup" == "html" {
								if `col' == 0 html <td colspan="`number'" 		///
								align="center" style=							///
								"border-bottom:solid thin;padding:3px 10px 1px 2px;" ///
								> `1' </td>
									
								if `col' > 0 html <td colspan="`number'" 		///
								align="center" style= 							///
								"border-bottom:solid thin;padding:3px 10px 1px 10px;" ///
								> `1' </td>
								
								local next = `next' + `number' - 1
							}
							if "$weaverMarkup" == "latex" {
								if `col' == 0 local nextrow \multicolumn{`number'}{c}{`1'} 
								if `col' > 0 local nextrow `nextrow' & \multicolumn{`number'}{c}{`1'} 
								local tmp1 = `col'+1
								local tmp2 = `col'+`number'
								local cmidrule \cmidrule(l){`tmp1'-`tmp2'}
							}
							
						}
							 
							
						local number //reset the value to nothing
						local col  `++col'
						local next `++next'
					}
						
					macro shift
				}
				
				if "$weaverMarkup" == "html"  html </tr>
				if "$weaverMarkup" == "latex" html `nextrow' \\ `cmidrule'
				local cmidrule
			}
		}
			
		if "$weaverMarkup" == "html" {
			html </tbody>
			html </table>
		}	
		
		if "$weaverMarkup" == "latex" {
			html \bottomrule
			html \end{tabular}
			html \end{table}
			html
		}
			
		// FOOT Note
		// =========
		//if "`foot'" ~= "" {
		//	html <p style="text-align:`center';font-size:smaller;font-style:italic;">`foot'</p>
		//	html      <br />
		//}		
	}
	
	
	****************************************************************************
	* MarkDoc PACKAGES
	* ----------------
	*
	* - Make sure the smcl log file is on
	* - Parse each row "`i'" based on Comma
	* - Local `col' saves the number of columns in the table
	* - Loop over the content of the "`1'" variable, obtained from tokenize
	* 		1. If the first entery of the row is missing, leave it empty
	*		2. Interpret the scalars
	*		3. Obtain the column alignment
	* - if log file is off, give a warning instead
	****************************************************************************
	
	
	//if "$weaver" == "" & !missing("`nomarkdoc'") {
	//	di as txt "{p}(ttable includes {bf:{col #}} and cannot be used in "		///
	//	"MarkDoc)" _n
	//}
	
	
	
	if "$weaver" == "" | "$noisyWeaver" == "yes" {

		// -----------------------------------------------------------------
		// Define the Markup language and print the output
		// =================================================================
		if missing("`markup'") & !missing("$markdocDefault") {
			local markup "$markdocDefault"
		}
		if missing("`markup'") & missing("$markdocDefault") {
			local markup "markdown" 
		}
		
		
		// -----------------------------------------------------------------
		// Print the title
		// -----------------------------------------------------------------
		if "`markup'" == "markdown" & !missing("`title'") 	{					
			display as txt _n `"> `title'"' 
		}
		
		if "`markup'" == "html" {
			display as txt  _n "> " 
			
			if !missing("`title'") & !missing("`left'") {
				display as txt  _n `"> <p class="tble`center'">"' 			///
				"`title'</p>" 
			}	
		}	
		if "`markup'" == "latex" & !missing("`title'") {
			display as txt `"> \begin{table}[h] "'
			if !missing("`center'") | missing("`left'") di as txt `"> \centering"'
			if !missing("`left'") di as txt `"> \captionsetup{justification=raggedright,singlelinecheck=false}"'
			if !missing("`title'") di as txt `"> \caption{`title'} "'
		}
		
			
		forval j = 1/`i' {
			local m : display "`m`j''"	
			if _rc == 0 {
				local this 1
			}
			
						
			if !missing(`this') {		
				tokenize `"`macval(m)'"' , parse(",")	
			}
			else {
				tokenize `"`macval(`m`j'')'"', parse(",")
			}
				
			local col 0
			local next 0
			local mergedCol 0
			
			// -----------------------------------------------------------------
			// Print the First row
			// -----------------------------------------------------------------
			if "`j'" == "1" {				
				display as txt _n "> "
				
				if "`markup'" == "html" {
					
					display as txt `"> <table width="`width'" "'				///
					`"height="`height'" align="`center'" >"'
					
					if missing("`left'") & !missing("`title'") {
						di as txt "> <caption>`title'</caption>" 
					}	
					
					di as txt `"> <thead>"' 
					di as txt `"> <tr class="header">"' 
				}	
			
			
				while `"`1'"' ~= "" {
				
					if `col' == 0 & "`1'" == "," {
					local align 	// reset the align macro
						if "`markup'" == "html"  di as txt `"> <th align="center"> </th>"'
						if "`markup'" == "latex" local tex`col' " "
						if "`markup'" == "markdown"  {
							di  "> " _c
							di "|" _c 
							*loc col `++col'
						}
						local align l
						local html`col' left					
					}
					
					if `"`1'"' == "," & "`markup'" == "markdown" di "|" _c				
					
					if `"`1'"' ~= "," {
						local test
						local test1
						local test2
						local test3
						local align 	// reset the align macro
						
						// MERGING CELLS IN THE FIRST ROW
						// ==============================
							
						// Check if there is any cell merge
						// remember the sign can be placed at the beginning 
						// or the end of the text. 
						if substr("`1'",1,3) == "{c}" {
							local 1 : subinstr local 1 "{c}" ""
							local align center
							local align`col' center
						}
						
						if substr("`1'",1,3) == "{l}" {
							local 1 : subinstr local 1 "{l}" ""
							local align left
							local align`col' left
						}
						
						if substr("`1'",1,3) == "{r}" {
							local 1 : subinstr local 1 "{r}" ""
							local align right
							local align`col' right
						}
			
						if substr("`1'",1,5) == "{col " {
				
							local 1 : subinstr local 1 "{col " ""
							
							if "`markup'" == "markdown" {
								local error 1
								//exit 198
							}	
							
							//Check if it has 1 or 2 digits
							if substr("`1'",2,1) == "}" {
							    local number : di substr("`1'",1,1)
								local 1 : subinstr local 1 "`number'}" ""
							}
							   
							if substr("`1'",3,1) == "}" {
							    local number : di substr("`1'",1,2)
								local 1 : subinstr local 1 "`number'}" ""
							}
							
							if "`number'" == "1" local number 
							
							local nomarkdoc 1
						}
					
						if substr("`1'",1,3) == "{c}" {
							local 1 : subinstr local 1 "{c}" ""
							local align center
						}
						
						if substr("`1'",1,3) == "{l}" {
							local 1 : subinstr local 1 "{l}" ""
							local align left
						}
						
						if substr("`1'",1,3) == "{r}" {
							local 1 : subinstr local 1 "{r}" ""
							local align right
						}
	
						
						
							
						// The first column by default left
						// ---------------------------------------
						if `col' == 0 {
							*local 1 : subinstr local 1 "{c 34}" "", all
							local test : display real("`1'")	// exclude real numbers
							if "`test'" == "." {	
							
								capture local test2 : display `1'	//search scalars
								capture local test3 : display int(`test2')		
								
								// Integers
								if "`test3'" == "`test2'"  {	//is an integer							
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								// Real 
								else if !missing("`test3'") & "`test3'" != "`test2'" {							
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								//Strings
								if missing("`test2'") {						
									local 1 : subinstr local 1 "{c 34}" "", all
								}
							}
							
							if "`markup'" == "markdown" { 
								//Make sure the first character is not "|" e.g. "|e|"
								local char : di substr(`"`1'"',1,1)
								if "`char'" == "|" di `"> __`1'__"' _c
								if "`char'" ~= "|" di `"> `1'"' _c
							}	
							
							if  missing("`number'") {
								
								if "`markup'" == "html" {
									if missing("`align'") local align left
									di as txt "> <th align=" `""`align'" "'	///
									`"style="padding:3px 10px 2px 2px;"> `1' </th>"'
									local html`col' `align'									
								}
								
								if "`markup'" == "latex" {
									if missing("`align'") local align l
									if "`align'" == "left" local align l
									if "`align'" == "center" local align c
									if "`align'" == "right" local align r
*									local 1 : subinstr local 1 "$$ " " $", all
									local 1 : subinstr local 1 "{c 92}" "\", all
									local texalign `texalign'`align'
									local tex`col' `1'
								}	
							}
							if !missing("`number'") {
								if "`markup'" == "html" {
									if missing("`align'") local align center
									di as txt `"> <th colspan="`number'" "'		///
									`"align="`align'" style="padding:"'			///
									`"3px 10px 2px 10px;"> `1' </th>"'
									
									forvalues num = 1/`number' {
										local temp = `col'+`num'
										local html`temp' `align'
									}								
								}	
								
								if "`markup'" == "latex" {
									if missing("`align'") local align c
									if "`align'" == "left" local align l
									if "`align'" == "center" local align c
									if "`align'" == "right" local align r
									local 1 : subinstr local 1 "{c 92}" "\", all
									local tex`col' \multicolumn{`number'}{c}{`1'}
									local align : di _dup(`number') "`align'"
									local texalign `texalign'`align'
								}	
								
								// Creating the merged column if there was a number
								local mergedCol = `mergedCol' + `number'							
							}	
						}
						if `col' > 0 {
							local test : display real("`1'")	// exclude real numbers
							if "`test'" == "." {	
							
								capture local test2 : display `1'	//search scalars
								capture local test3 : display int(`test2')								
								// Integers
								if "`test3'" == "`test2'"  {	//is an integer							
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								// Real 
								else if !missing("`test3'") & "`test3'" != "`test2'" {							
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								//Strings
								if missing("`test2'") {	
									local 1 : subinstr local 1 "{c 92}" "\", all
									local 1 : subinstr local 1 "{c 34}" "", all
								}
							}
							
							if "`markup'" == "markdown" { 
								//Make sure the first character is not "|" e.g. "|e|"
								local char : di substr(`"`1'"',1,1)
								if "`char'" == "|" di `"__`1'__"' _c
								if "`char'" ~= "|" di `"`1'"' _c
							}
							
							if  missing("`number'") {
								if "`markup'" == "html" {
									if missing("`align'") local align center
									di as txt `"> <th align="`align'" "'	///
									`"style= "padding:3px 10px 2px 10px;"> "'	///
									`"`1' </th>	"'							
									
									if "`mergedCol'" != "0" {
										local temp = `col'+`mergedCol'-1
										local html`temp' `align'	
									}
									else {
										local html`col' `align'
									}
								}	
								
								if "`markup'" == "latex" {
									local tex`col' `1'
									if missing("`align'") local align c
									if "`align'" == "left" local align l
									if "`align'" == "center" local align c
									if "`align'" == "right" local align r
									local 1 : subinstr local 1 "{c 92}" "\", all
									local texalign `texalign'`align'
								}	
							}
									
							if !missing("`number'") {
								if "`markup'" == "html" {
									if missing("`align'") local align center
									di as txt `"> <th colspan= "`number'" "'	///	
									`"align= "center" tyle="padding:"'			///
									`"3px 10px 2px 10px;" > `1' </th>"'
									
									forvalues num = 1/`number' {
										local temp = `col'+`mergedCol'+`num'-1
										local html`temp' `align'										
									}
								}	
								
								if "`markup'" == "latex" {
									if missing("`align'") local align c
									if "`align'" == "left" local align l
									if "`align'" == "center" local align c
									if "`align'" == "right" local align r
									local 1 : subinstr local 1 "{c 92}" "\", all
									local align : di _dup(`number') "`align'"
									local texalign `texalign'`align'
									local tex`col' \multicolumn{`number'}{c}{`1'}
								}	
								
								local mergedCol = `mergedCol' + `number'								
							}	
						}
						
						local number 	//reset the value to nothing
						loc col `++col'
					}
						
					macro shift
				}
				
				if "`markup'" == "markdown" {
					di "    " _c 	//close the line
					
					
					if "`j'" == "1" {
					
						//Printing the first column
						if "`align0'" == "left" | missing("`align`n''") {
							di _n "> :--------" _c
						}	
						else if "`align0'" == "right"  di _n "> --------:" _c
						else if "`align0'" == "center" di _n "> :--------:" _c
						
						//Printing the following columns
						local b = `col' - 1
						forvalues n = 1/`b' {
							di "|" _c
							if "`align`n''" == "center" | missing("`align`n''") {
								di ":--------:" _c
							}
							else if "`align`n''" == "left" di ":--------" _c
							else if "`align`n''" == "right" di "--------:" _c
						}
						di "   " 
					}
					
				}
				
				
				if "`markup'" == "html" {
					di as txt `"> </tr>"'
					di as txt `"> </thead>"'
					local htmlColumns `temp'	//save the number of columns					
				}	
				
				// PRINT THE FIRST ROW OF THE LATEX TABLE
				if "`markup'" == "latex" {
					*local write l	//the first column is left-aligned
					if !missing(`mergedCol') local mergedCol = `mergedCol' - 1 + `col'
					*forval num = 2/`mergedCol' {
					*	local write `write'c	//the other columns centered
					*}
					di as txt `"> \begin{tabular}{@{}`texalign'@{}}"'
					di as txt `"> \toprule"'
					
					forval num = 0/`col' {
						if `num' <  `col'-1 local firstrow `firstrow' `tex`num'' &
						if `num' == `col'-1 local firstrow `firstrow' `tex`num'' \\ \midrule
					}
					di as txt `"> `firstrow'"'				
				}
			}
	
			// Print the other rows
			// ====================
				
			if "`markup'" == "html" {
				if `j' == 2 di as txt `"> <tbody>"'
			}	
				
			if `j' > 1 {				
					
				// Specify if J is Odd or Even
				//----------------------------
				
				if "`markup'" == "html" {
					//if J is Odd
					if mod(`j',2) di as txt `"> <tr class="odd">"'
				
					//if J is even
					if !mod(`j',2) di as txt `"> <tr class="even">"'
				}	
				
				if "`markup'" == "markdown" {
					di "> " _c
				}	
				
				while `"`1'"' ~= "" {	
				
					if `col' == 0 & "`1'" == "," {
						if "`markup'" == "html" {
							di as txt `"> <td align="`html0'"> </td>"'
						}	
						if "`markup'" == "latex" local tex`col' " "
						
						if "`markup'" == "markdown"  {
							*di  "> " _c
							di "|" _c 
							loc col `++col'
						}
					}
					
					
					if `"`1'"' == "," & "`markup'" == "markdown" di "|" _c	
					
					
					//Handle consequent commas
					//------------------------
						
						
							
					if `col' > 0 & "`1'" == "," {
								
						//If it's the second column or more and the entery 
						// is ",", then check the next entery. As long as 
						// the next entery is comma, replace it with 
						// empty column
								
						while "`1'" == "," {
							macro shift
									
							if "`1'" == "," {
								if "`markup'" == "html" di as txt `">"' 		///
								`"<td align="`html`col''"> </td>"'
								if "`markup'" == "latex" local tex`col' " "
							}
						}
					}
						
						
					if `"`1'"' ~= "," {
						local test
						local test1
						local test2
						local test3
							
						// MERGING CELLS IN THE OTHER ROW
						// ==============================
							
						if substr("`1'",1,5) == "{col " {
							   
							local 1 : subinstr local 1 "{col " ""
							   
							//Check if it has 1 or 2 digits
							if substr("`1'",2,1) == "}" {
							    local number : di substr("`1'",1,1)
								local 1 : subinstr local 1 "`number'}" ""
							}
							   
							if substr("`1'",3,1) == "}" {
							    local number : di substr("`1'",1,2)
								local 1 : subinstr local 1 "`number'}" ""
							}
							
							if "`number'" == "1" local number 
							local nomarkdoc 1
						}
												
						if  missing("`number'") {
							*local 1 : subinstr local 1 "{c 34}" "", all
							local test : display real("`1'")	// exclude real numbers
							if "`test'" == "." {	
							
								capture local test2 : display `1'	//search scalars
								capture local test3 : display int(`test2')								
								// Integers
								if "`test3'" == "`test2'"  {	//is an integer							
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								// Real 
								else if !missing("`test3'") & "`test3'" != "`test2'" {							
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								//Strings
								if missing("`test2'") {		
									local 1 : subinstr local 1 "{c 92}" "\", all
									local 1 : subinstr local 1 "{c 34}" "", all
								}
							}


							if "`markup'" == "html" {
								if `col' == 0 di as txt `"> <td align="`html`col''" "'			///
								`"style="padding:1px 10px 1px 2px;"> `1' </td>"'
								
								if `col' > 0 di as txt `"> <td align="'		///
								`""`html`next''" style="padding:1px 10px;"> "'	///
								`"`1' </td>"'
							}	
							if "`markup'" == "latex" {
								if `col' == 0 local nextrow `1' 
								if `col' > 0 local nextrow `nextrow' & `1' 
							}
							
							if "`markup'" == "markdown" { 
								//Make sure the first character is not "|" e.g. "|e|"
								local char : di substr(`"`1'"',1,1)
								*if `col' == 0 di "> " _c
								if "`char'" == "|" di `"__`1'__"' _c
								if "`char'" ~= "|" di `"`1'"' _c
							}
						}
							
							
						if  !missing("`number'") {
							*local 1 : subinstr local 1 "{c 34}" "", all
							local test : display real("`1'")	// exclude real numbers
							if "`test'" == "." {	
							
								capture local test2 : display `1'	//search scalars
								capture local test3 : display int(`test2')								
								// Integers
								if "`test3'" == "`test2'"  {	//is an integer							
									capture local m : display `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								// Real 
								else if !missing("`test3'") & "`test3'" != "`test2'" {							
									capture local m : display %10.2f `1'
									if _rc == 0 {
										local 1 `m'
									}
								}
								
								//Strings
								if missing("`test2'") {		
									local 1 : subinstr local 1 "{c 92}" "\", all
									local 1 : subinstr local 1 "{c 34}" "", all
								}
							}
							
							//Always align the merged cells to the center
							
							if "`markup'" == "html" {
								if `col' == 0 di as txt `"> <td colspan="'	///
								`""`number'"align="center" style="border-"'		///
								`"bottom:solid thin;padding:3px 10px 1px 2px;""' ///
								`"> `1' </td>"'
									
								if `col' > 0 di as txt `"> <td colspan="'	///
								`""`number'" align="center" style="border-"'	///
								`"bottom:solid thin;padding:3px 10px 1px "'		///
								`"10px;" > `1' </td>"'
								
								local next = `next' + `number' - 1
							}
							if "`markup'" == "latex" {
								if `col' == 0 local nextrow \multicolumn{`number'}{c}{`1'} 
								if `col' > 0 local nextrow `nextrow' & \multicolumn{`number'}{c}{`1'} 
								local tmp1 = `col'+1
								local tmp2 = `col'+`number'
								local cmidrule \cmidrule(l){`tmp1'-`tmp2'}
							}
						}
							 
							
						local number //reset the value to nothing
						local col  `++col'
						local next `++next'
					}
						
					macro shift
					
				}
				if "`markup'" == "markdown" di "   " 
				if "`markup'" == "html"  di as txt `"> </tr>"'
				if "`markup'" == "latex" di as txt `"> `nextrow' \\ `cmidrule'"'
				local cmidrule
				
				
			}
		}
		if "`markup'" == "markdown" di "> "
		if "`markup'" == "html" {
			di as txt `"> </tbody>"'
			di as txt `"> </table>"'
		}	
		
		if "`markup'" == "latex" {
			di as txt `"> \bottomrule"'
			di as txt `"> \end{tabular}"'
			di as txt `"> \end{table}"' _n(2)
		}
		
		if "`markup'" == "markdown" & !missing("`error'") {
			if missing("$weaver") {
				di as err `"{p}The {bf:{col #}} sign is not "' 					///
				"supported in Markdown because Markdown does "					///
				"not support nested tables"
			}	
			if !missing("$weaver") {
				di as txt `"{p}Warning: The {bf:{col #}} sign is not "' 		///
				"supported in Markdown. The code printed in the Results Window"	///
				" is not usable"
			}
		}
		
		
	}		
								
	// Check the Status of the log files for Weaver and MarkDoc					
	qui log query
	if "`r(status)'" ~= "on" & "$weaver" == "" {
		di as txt _n(2) "{hline}"
		di as error "{bf:Warning}" _n
		di as txt "{p}log file is off! " _n 
		di as txt "{c 149} If you wish to use {help weaver}  package, turn the html log on"  
		di as txt "{c 149} If you wish to use {help markdoc} package, turn the smcl log on"		
		di as txt "{hline}{smcl}"	_n
	}
			
			
end

