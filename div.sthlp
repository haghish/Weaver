{smcl}

{marker title}{...}
{title:Title}

{phang}
{cmdab:div} {hline 2} performs Stata command and echoes the command or output or both
to the HTML log file. This command belongs to {bf:{help weaver}} packages.


{marker syntax}{...}
{title:Syntax}

    Perform command and echo command and output to the HTML log
	
	{cmdab:div} {it:command}
	

    Echo the command but suppress the output from the HTML log
	
	{cmdab:div} {cmdab:c:ode} {it:command}
	
	
    Echo the output but supress the command from the HTML log
	
	{cmdab:div} {cmdab:r:esult} {it:command}


{marker description}{...}
{title:Description}

{pstd}
{cmd:div} run Stata {it:command} and echo the command and output in the HTML log
in {help weaver} package. If {help weaver} is not in use (i.e. there is not HTML
log open), {cmd:div} run the command and return the output and at the end, it
also return a warning that the HTML log is not on.

{pstd}
The {cmdab:c:ode} subcommand can be added to {cmdab::div} command to only echo
the {it:command} in the HTML log and suppress the output from the HTML log. Although
it continues to print the output in Stata results window.

{pstd}
The {cmdab:r:esult} subcommand can be added to {cmdab::div} command to only echo the
output in the HTML log and suppress {it:command} from the HTML log.
Although it continues to print the output in Stata results window.


{marker example}{...}
{title:Example of interactive use}

{pstd}
You do care to see a particular {it:command} and output in the HTML log. {cmdab:div} 
echoes them to the HTML log. 

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. div regress mpg weight foreign headroom}

{pstd}
You do not care to see a particular {it:command} and only want to include the output 
in the HTML log. {cmdab:div} {cmdab:r:esult} echoes the output to the HTML log and 
suppresses the {it:command}. 

{phang2}{cmd:. div r code misstable summarize}

{pstd}
You do not care to see the output and wish to echo print some {it:command} 
in the HTML log. {cmdab:div} {cmdab:c:odes} echoes the {it:command} to the HTML log and 
suppresses the output.

{phang2}{cmd:. div c generate newvar = price}

