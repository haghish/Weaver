/*******************************************************************************

							  Stata Weaver Package
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de

		
                  The Weaver Package comes with no warranty    	
				  
				  
	Weaver version 1.0  August, 2014
	Weaver version 1.1  August, 2014
	Weaver version 1.2  August, 2014
	Weaver version 1.3  September, 2014 
	Weaver version 1.4  October, 2014 
	Weaver version 2.0  August, 2015 
	Weaver version 3.3.0  January, 2016
*******************************************************************************/
	

	/* ----     html code     ---- */
	
	* adds html code
	program define html
        version 11
        
        //if "$weaver" != "" confirm file `"$weaver"'

        tempname canvas
        cap file open `canvas' using `"$weaverFullPath"', write text append         
		cap file write `canvas' `"`macval(0)'"' _n
		
		// Make sure the weaver html log is open
		/*
		if "$weaver" == "" {
			
			di as txt _n(2) "{hline}"
			di as error "{bf:Warning}" 
			di as txt "{help weaver} log file is off!" 
			di as txt "{hline}{smcl}"	_n
			
		}  
		*/
		
	end
	
