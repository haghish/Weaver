{smcl}
{right:updated in Weaver 3.3.3 : February, 2016}
{marker title}{...}
{title:Title}

{phang}
{cmdab:txt} {hline 2} Prints string and values of scalar expressions or macros 
in dynamic document and by default writes a 
text paragraph. The primary purpose of the command is writing dynamic text, to 
interpret analysis results in the dynamic document. This command belongs to {help Weaver} package, but it also supports the 
{help MarkDoc} package. The syntax for both packages is similar, but
the {cmdab:txt} command behaves differently based on which package is in use. 
If Weaver log is on, {cmd:txt} functions for Weaver package only. 


{title:Author} 
        {p 8 8 2}E. F. Haghish{break} 
	Center for Medical Biometry and Medical Informatics{break}
	University of Freiburg, Germany{break} 
        {browse haghish@imbi.uni-freiburg.de}{break}
	{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/weaver.php":{it:http://haghish.com/weaver}}{break}
   

{marker syntax}{...}
{title:Syntax}

    Prints dynamic text in the Weaver log or smcl log
	
	{cmdab:txt} [{opt c:ode}] [{it:display_directive} [{it:display_directive} [{it:...}]]]

{pstd}where the {it:display_directive} is

	{help weaver_markup:Weaver Markup}
	{cmd:"}{it:double-quoted string}{cmd:"}
{p 8 16 2}{cmd:`"}{it:compound double-quoted string}{cmd:"'}{p_end}
	[{help format:{bf:%}{it:fmt}}] [{cmd:=}]{it:{help exp}}
	{cmd:_skip(#)}
	{cmdab:_col:umn:(}{it:#}{cmd:)}
	{cmdab:_n:ewline}[{cmd:(}{it:#}{cmd:)}]
	{cmdab:_d:up:(}{it:#}{cmd:)}
	{cmd:,}
	{cmd:,,}

	
{marker description}{...}
{title:Description}

{pstd}
{cmd:txt} prints dynamic text i.e. strings and values of scalar expressions or macros in the Weaver or the 
smcl log-file. {cmd:txt} also prints output from the user-written Stata programs. Any of the 
supported markup languages can be used to alter the string and scalar expressions. This command 
s to some extent similar to {cmd:display} command in Stata. For example, 
it can be used to carry out a mathematical calculation by typing {cmd:txt 1+1}. It also 
supports many of the display directives as well. 

{pstd}
The {opt c:ode} subcommand prints the output as "line of code" in the dynamic document. This 
subcommand functions differently based on whether {help markdoc} or {help weaver} packages is in use (see below). 

{pstd}
Note that in contrast to the {help display} command that prints the 
{help scalar} unformatted, the {cmd:txt} command uses the default 
{bf:%10.2f} format for displaying the scalar. This feature helps the users 
avoid specifying the format for every scalar, although specifying the format 
expression can overrule the default format. For example:

	{cmd:. scalar num = 10.123}
	{cmd:. txt "The value of the scalar is " %5.1f num}
	
{pstd}
The example above will print the scalar with only 1 decimal number. 
This feature only supports scalar interpretation and does not affect 
the {help macro} contents.  


{title:Display directives}

{pstd}
The supported {it:display_directive}s are used in do-files and programs
to produce formatted output.  The directives are		 

{synoptset 32}
{synopt:{bf:{help weaver_markup:Weaver Markup}}}A simplified markup language for 
	annotating the content of the HTML log{p_end}
			  
{synopt:{cmd:"}{it:double-quoted string}{cmd:"}}displays the string without
              the quotes{p_end}

{synopt:{cmd:`"}{it:compound double-quoted string}{cmd:"'}}display the string
              without the outer quotes; allows embedded quotes{p_end}

{synopt:[{cmd:%}{it:fmt}] [{cmd:=}] {cmd:exp}}allows results to be formatted;
         see {bf:{mansection U 12.5FormatsControllinghowdataaredisplayed:[U] 12.5 Formats: Controlling how data are displayed}}.{p_end}

{synopt:{cmd:_skip(}{it:#}{cmd:)}}skips {it:#} columns{p_end}

{synopt:{cmd:_column(}{it:#}{cmd:)}}skips to the {it:#}th column{p_end}

{synopt:{cmd:_newline}}goes to a new line{p_end}

{synopt:{cmd:_newline(}{it:#}{cmd:)}}skips {it:#} lines{p_end}

{synopt:{cmd:_dup(}{it:#}{cmd:)}}repeats the next directive {it:#} times{p_end}
		 
{synopt:{cmd:,}}displays one blank between two directives{p_end}

{synopt:{cmd:,,}}places no blanks between two directives{p_end}
{p2colreset}{...}



{bf:{dlgtab:txt in Weaver package}}

{pstd}
When the {help Weaver} package is in use, {cmd:txt} command prints string or numeric 
values in Weaver log. It will also be able to interpret the {help Weaver Markup} codes.

{pstd}
{cmd:txt} command can also be used for writing mathematical notations in Weaver 
package, both in HTML and LaTeX log files. Writing mathematical notations in the 
HTML log is made possible by including {bf:MathJax} engine, a JavaScript-based 
engine for rendering ASCii and LaTeX notations in HTML format. 
To do so, notations should begin and end with double hashtags "{bf:##}" for 
rendering notations within the text and triple hashtags "{bf:###}" for rendering 
notations in a separate line. For more information in this 
regard, see {help Weaver_mathematical_notation:mathematical notations} documentation. 

{pstd}
When Weaver package is running, the {opt c:ode} subcommand appends the dynamic text to the 
log. For example, in HTML Weaver log, the dynamic text will no longer be formated 
as paragraph (i.e. the {bf:<p>} and {bf:</p>} will not be added).
This subcommand is only meant for advanced users who wish to customize or style the dynamic 
text in the dynamic document. 


{bf:{dlgtab:txt in MarkDoc package}}

{pstd}
{help MarkDoc} package has a very convenient way for writing and styling text. 
However, it applies the {cmd:txt} command for writing and styling string, when 
it includes a {help macro} and {help scalar}, or when there is a need to print 
formatted dynamic text from a user-written program or within a loop. Note that this 
command only functions for MarkDoc package when the Weaver log is closed or off. 
Moreover, when {cmd:txt} command is used with MarkDoc, it does {ul:not}  
support {help Weaver Markup}

{pstd}
When the MarkDoc package is in use, {cmd:txt} command prints string in smcl 
log-file. However, in contrast to {help display} command, which prints text both in the 
command and output (i.e. duplicating text), MarkDoc removes the {cmd:txt} 
command automatically from the smcl log while converting it to another format such 
as HTML, PDF, Docx, OpenOffice, etc. 

{pstd}
In MarkDoc package, the {opt c:ode} subcommand creates a code block, displaying the 
dynamic text in mono-space text.



{marker examples}{...}
{title:Examples}

{pstd}As a hand calculator:

{phang2}{cmd:. txt 2 * 2}

{pstd}As might be used in do-files and programs:

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. summarize price}{p_end}
{phang2}{cmd:. txt "mean of Price variable is " r(mean) " and SD is " %9.3f r(sd)}{p_end}

{pstd}If the text only includes string and macro, the double quotations can be ignored. 
The {cmd:txt} command will interpret all of the {it:display_directives} and 
scalars as string (so it's not recommended):

{phang2}{cmd:. local n 9.9}{p_end}
{phang2}{cmd:. txt Not recommended, but you may also print the value of `n' without double quote}{p_end}

