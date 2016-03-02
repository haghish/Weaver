/*
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de
								   
                       * MarkDoc comes with no warranty *
				   
	
	DESCRIPTION
	==============================
	
	This command was initially written for MarkDoc package. Then it was moved 
	to the Weaver package to replace the "knit" command. Since the Weaver 
	version 3.0, it provides support for both MarkDoc and Weaver packages. 
	
	This command writes Dynamic text and can include string, scalar, etc. The 
	"txt" command is to some extent similar to "display" command in Stata, 
	but it has different purpose, namely it displays text on the dynamic 
	document. 
	
	If Weaver package is in use (i.e. $weaver exists) the program primarily 
	functions for Weaver. If the global is not found, it functions for MarkDoc
	package. 
	
	
	Notes for further updates
	-------------------------
	
	It seems that Stata (v 14) applies a different syntax for display directives 
	in the DISPLAY  and FILE commands. see
	
		- help display
		- help file
	
	The TXT command in Weaver, writes the display directives to the file, and 
	this might be problematic in some cases. Look into the syntax carefully and 
	adopt the FILE syntax to be extra conservative. 
	
	
	Weaver Versions
	==============================
	
	Weaver  version 3.3.6  February, 2016

*/

program define txt
version 11

	****************************************************************************
	* Allowing Scalar interpretation
	****************************************************************************
/*
	if "$weaver" != "" {
	capture local m : display `0'					
	if _rc == 0 {
		local 0 `m'
	}
}
*/
	****************************************************************************
	* Processing "code" suffix
	*
	* - check if the "code" subcomman is defined after "txt"
	* - if there is no code subcommand, define local "code = 0"
	* - if yes, remove it and append the rest to Weaver log
	* - interpret the scalars in the command, if there is any
	* - define a local macro identifier "code = 1",  if there is a code
	****************************************************************************
	
	capture tokenize "`0'" 							// add quotes to avoid "comma" error

	if  missing("`2'") local code = 0
	if !missing("`2'") {
		
		if "`1'" == "c" | "`1'" == "co" | "`1'" == "cod" | "`1'" == "code" {
			local 0 : subinstr local 0 "`1'" ""	
			local code = 1
		}
													
		else {
			local code = 0							// no code tag
		}	
	}
	
	****************************************************************************
	* If Weaver package is in use and there is no code subcommand 
	*
	* - change MathJax notation based on the markups
	* - print the text in Weaver log based on the Weaver markup
	*
	* Specifying the Mathematics Notation
	* ===================================
	*
	* It'd be nice to use a similar syntax for both ASCII and LaTeX notations, 
	* but there are some challenges:
	*
	* - first of all, if the "$" is connected, Stata considers it as a 
	*	Global Macro, both in LaTeX and HTML log
	*		
	* - if the "$" is specified for JavaScript engine in HTML log, JS will 
	*	remove the "$" of global macros in commands as well... So this notation 
	*	must no be specified in the JS engine. Besides, $ appears very often in
	*	documents and is not a distinct sign
	* 
	* - For ASCII math, MathJax supports "`" delimites which interfere with 
	*	Markdown syntax for mono-space font! Thus, it must not be used... 
	*
	* - One solution is applying "\(" "\)" and "\[" "\]" for both ASCII and LaTeX
	* - Making "$$" available for both ASCII and LaTeX
	****************************************************************************
	
	// Why not applying LaTeX syntax for all? 
	
	if "$weaver" != ""  {	
		
		if "$weaverMarkup" == "html" {
		
			if "$weavermath" == "mathlatex" {
				local 0 : subinstr local 0 "§§" "$$", all
				local 0 : subinstr local 0 "###" "$$", all
				*local 0 : subinstr local 0 "##" "§", all
			}
				
			if "$weavermath" == "mathascii" {
				forvalues i = 1(1)20 {
					local 0 : subinstr local 0 "###" `"<span class="math">##"'
					local 0 : subinstr local 0 "###" "## </span>"
					local 0 : subinstr local 0 "§§" `"<span class="math">##"'
					local 0 : subinstr local 0 "§§" "## </span>"
					local 0 : subinstr local 0 "\[" `"<span class="math">##"'
					local 0 : subinstr local 0 "\]" "## </span>"
					local 0 : subinstr local 0 "$$" `"<span class="math">##"'
					local 0 : subinstr local 0 "$$" "## </span>"
				}
			}
		}

		tempname canvas
		cap file open `canvas' using `"$weaverFullPath"', write text append
	
		/*
		if "$weaverMarkup" == "html" {
			cap file write `canvas' "<p>" 	
			cap file write `canvas' `"`macval(0)'"' 
			cap file write `canvas' "</p>" _n
		}
		
		if "$weaverMarkup" == "latex" {
			cap file write `canvas' _n `"`macval(0)'"' _n
		}
		*/
		
		if "`code'" == "0" & "$weaverMarkup" == "html" cap file write `canvas' "<p>" _c
		if "$weaverMarkup" == "latex" cap file write `canvas' _n    
		
		// ---------------------------------------------------------------------
		// Engine
		// =====================================================================
		local 0 : subinstr local 0 "`" "{c 96}", all
		local 0 : subinstr local 0 "'" "{c 39}", all

		tokenize `"`macval(0)'"'  , parse(`"""')
		
		while `"`1'"' ~= "" {
			
			local 1 : subinstr local 1 "{c 96}" "`", all
			local 1 : subinstr local 1 "{c 39}" "'", all
			
			local test : display real("`1'")	// exclude real numbers (macros)
			
			if "`test'" != "." cap file write `canvas' "`1'" _c
		
			if "`test'" == "." {
			
				if substr("`1'",1,2) != "_n" & substr("`1'",1,2) != "_s" &	///
				   substr("`1'",1,2) != "_c" & substr("`1'",1,2) != "_d" &  ///
				   substr("`1'",1,2) != "_r" {
			   
					// Non-Integer Scalars
					capture local test2 : display `1'
				
					// Integer Scalar
					capture local test3 : display int(`test2') 
				}	
								

				// `1' is an integer Scalar
				if !missing("`test2'") & "`test3'" == "`test2'" {
					if substr("`1'",1,2) != "_n" & substr("`1'",1,2) != "_s" &	///
					substr("`1'",1,2) != "_c" & substr("`1'",1,2) != "_d" &  	///
				    substr("`1'",1,2) != "_r" {
						capture local m : display `1'
						if _rc == 0 {
							local 1 `m'
							cap file write `canvas' "`1'" _c
						}	
					}	
				}		
					
				// Real 
				else if !missing("`test3'") & "`test3'" != "`test2'" {							
					capture local m : display %10.2f `1'
					if _rc == 0 {
						local 1 : display trim("`m'")     // Avoid extra space
						cap file write `canvas' "`1'" _c
					}
				}
				
				// Several scalars or numeric macros
				else if !missing("`test2'") & missing("`test3'") {							
					capture local m : display %10.2f `1'
					if _rc == 0 {
						local 1 : display trim("`m'")     // Avoid extra space
						cap file write `canvas' "`1'" _c
					}
				}
				
				
				//Strings
				if missing("`test2'") {	
					
					// New Lines
					if substr("`1'",1,2) == "_n" {
					
						cap file write `canvas' `1'  _c
					}
					
					//Duplicates
					else if substr("`1'",1,2) == "_d" {
						local memo "`1'"
						macro shift
						local memo2: display `memo' "`1'"
						cap file write `canvas' "`memo2'" _c
					}
					
					//Avoid _char()
					else if substr("`1'",1,6) =="_char(" {
						display as err _n(2) "`1' is not allowed" 
						err 198
					}
					
		
					// Other directives
					else if substr("`1'",1,2) == "_s" |							///
					   substr("`1'",1,2) == "_c" | substr("`1'",1,2) == "_r" {
						cap file write `canvas' `1' _c
					}
					
					// All other strings
					else {
						cap file write `canvas' "`1'" _c
					}
					
				}
			}
			
			macro shift
			local test
			local test2
			local test3	
		}
		// ---------------------------------------------------------------------

		
		if "$weaverMarkup" == "html" & "`code'" == "0" cap file write `canvas' "</p>" _n
		if "$weaverMarkup" == "latex" cap file write `canvas' _n  
	}	
		
	
	
	
	
	
	
	************************************************************************
	* MarkDoc: if Weaver package is NOT in use
	*
	* print the text output to smcl log anyway
	* if smcl log file is not on, notify the user
	************************************************************************
	
	if "$weaver" == "" | "$noisyWeaver" == "yes" {
		
		if "`code'" == "0" display as txt _n(2) `"> "' _c
		if "`code'" == "1" display as txt _n(2) ">~~~" _n ">" _c
		
		local 0 : subinstr local 0 "`" "{c 96}", all
		local 0 : subinstr local 0 "'" "{c 39}", all
		
		tokenize `"`macval(0)'"' , parse(`"""')	
		
		
	
		while `"`1'"' ~= "" {
			
			local 1 : subinstr local 1 "{c 96}" "`", all
			local 1 : subinstr local 1 "{c 39}" "'", all
			
			local test : display real("`1'")	// exclude real numbers (macros)
			
			if "`test'" != "." display as txt "`1'" _c
		
			if "`test'" == "." {
			
				if substr("`1'",1,2) != "_n" & substr("`1'",1,2) != "_s" &	///
				   substr("`1'",1,2) != "_c" & substr("`1'",1,2) != "_d" &  ///
				   substr("`1'",1,2) != "_r" {
			   
					// Non-Integer Scalars
					capture local test2 : display `1'
				
					// Integer Scalar
					capture local test3 : display int(`test2') 
				}	
								

				// `1' is an integer Scalar
				if !missing("`test2'") & "`test3'" == "`test2'" {
					if substr("`1'",1,2) != "_n" & substr("`1'",1,2) != "_s" &	///
					substr("`1'",1,2) != "_c" & substr("`1'",1,2) != "_d" &  	///
				    substr("`1'",1,2) != "_r" {
						capture local m : display `1'
						if _rc == 0 {
							local 1 `m'
							display "`1'" _c
						}	
					}	
				}		
					
				// Real 
				else if !missing("`test3'") & "`test3'" != "`test2'" {							
					capture local m : display %10.2f `1'
					if _rc == 0 {
						local 1 : display trim("`m'")     // Avoid extra space
					}
					display "`1'" _c
				}
			
				// Several scalars or numeric macros
				else if !missing("`test2'") & missing("`test3'") {							
					capture local m : display %10.2f `1'
					if _rc == 0 {
						local 1 : display trim("`m'")     // Avoid extra space
					}
					display "`1'" _c
				}
				
				//Strings
				if missing("`test2'") {	
					
					// New Lines
					if substr("`1'",1,2) == "_n" {
						display as txt `1' "> " _c
					}
					
					//Duplicates
					else if substr("`1'",1,2) == "_d" {
						local memo "`1'"
						macro shift
						display `memo' "`1'" _c
					}
					
					//Avoid _char()
					else if substr("`1'",1,6) =="_char(" {
						display as err _n(2) "`1' is not allowed" 
						err 198
					}
					
					// Other directives
					else if substr("`1'",1,2) == "_s" |							///
					   substr("`1'",1,2) == "_c" | substr("`1'",1,2) == "_r" {
						display `1' _c
					}
					
					// All other strings
					else {
						display "`1'" _c
					}
				}
			}
			
			macro shift
			local test
			local test2
			local test3
	
		}
		
		if "`code'" == "1" display _n ">~~~" 
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
	
	/*
	if "$weaver" == "" & "`code'" == "1" {
		capture local m : display `0'					
		if _rc == 0 {
			local 0 `m'
		}
		display as smcl  
		display ">~~~" _n `">`macval(0)'"' _n ">~~~" 
		display in smcl	
	}
	*/
end




