{smcl}

{marker title}{...}
{title:Title}

{phang}
{cmdab:tbl} {hline 2} creates a dynamic table in {bf:HTML}, {bf:LaTeX}, or {bf:Markdown}. 
It can also align each column to left, center, or right, and also create 
multiple-colummns for hierarchical tables. This command belongs to 
{bf:{help Weaver}} package, but it also supports the {bf:{help MarkDoc}} package. 
The syntax for both packages is to some extent similar (see below), but
the {cmdab:tbl} command behaves differently based on which package is in use. 
Naturally, the {cmdab:tbl} command follows the same features and limits of these 
packages which are explained in the packages help files. Although, they are 
briefly mentioned here as well.


{title:Author} 
        {p 8 8 2}E. F. Haghish{break} 
	Center for Medical Biometry and Medical Informatics{break}
	University of Freiburg, Germany{break} 
        {browse haghish@imbi.uni-freiburg.de}{break}
	{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/weaver.php":{it:http://haghish.com/weaver}}{break}
   

{marker syntax}{...}
{title:Syntax}

    Creates dynamic table in HTML/Markdown
	
	{cmdab:tbl} {it:(*[,*...] [\ *[,*...] [\ [...]]])} [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} {opt h:eight(int)} {opt left} {opt center}  ]

{pstd}where the {bf:*} represents a {it:display directive} which is

	{cmd:"}{it:double-quoted string}{cmd:"}
{p 8 16 2}{cmd:`"}{it:compound double-quoted string}{cmd:"'}{p_end}
	[{help format:{bf:%}{it:fmt}}] [{cmd:=}]{it:{help exp}}
	{cmd:,} 
	{l}
	{c}
	{r}
	{col #}

{marker description}{...}
{title:Description}

{pstd}
{cmd:tbl} is a command in {help Weaver} package that creates a dynamic table 
in the Weaver log-file. It also can be used with {help MarkDoc} package for a 
similar purpose, although the program functions differently based on whether 
Weaver-log is on or not. The supported {it:display directive}s are:

{synoptset 32}
{synopt:{cmd:"}{it:double-quoted string}{cmd:"}}displays the string without
              the quotes{p_end}

{synopt:{cmd:`"}{it:compound double-quoted string}{cmd:"'}}display the string
              without the outer quotes; allows embedded quotes{p_end}

{synopt:[{cmd:%}{it:fmt}] [{cmd:=}] {cmd:exp}}allows results to be formatted;
         see {bf:{mansection U 12.5FormatsControllinghowdataaredisplayed:[U] 12.5 Formats: Controlling how data are displayed}}{p_end}

{synopt:{cmd:,}}separates the directives of each column of the table{p_end}

{synopt:{l}}if placed before any of the directives mentioned above, 
this directive create a left-aligned column. {p_end}

{synopt:{c}}creates a center-aligned column. {p_end}

{synopt:{r}}creates a right-aligned column. {p_end}

{synopt:{col #}}if placed before any of the directives mentioned above, 
this directive will create a multi-column by merging # number of columns. 
{ul:This directive is only supported in Weaver package}{p_end}

{p2colreset}{...}


{bf:{dlgtab:tbl in Weaver package}}

{pstd}
When the {help Weaver} package is in use, {cmd:tbl} command creates a dynamic  
table in HTML or LaTeX, depending on the markup language used in Weaver log. 
If Weaver HTML is in use, {cmd:tbl} will be able to interpret the 
{help Weaver Markup} codes as well as 
{help Weaver_mathematical_notation:Weaver mathematical notations}. In other words, 
Weaver Markups and Weaver mathematical notations
can be used as a display directives within the {cmd:tbl} command to alter other 
directives or display mathematical signs and formulas. Advanced users can also use HTML 
code to alter the table. 

{pstd}
If LaTeX markup is used for creating the Weaver log, then {cmd:tbl} command 
creates a LaTeX table. However, neither {help Weaver_Markup:Weaver Markup} nor 
{help Weaver_mathematical_notation:Weaver mathematical notations} are not 
supporting LaTeX. Instead, LaTeX mathematical notations can be 
used for writing mathematical notations or altering the table. 


{bf:{dlgtab:tbl in MarkDoc package}}

{pstd}
When Weaver log file is closed or off and the smcl log is on, the {cmd:tbl} 
command creates a Markdown dynamic table in the smcl log file. 

{pstd}
When {cmd:tbl} creates a markdown table, {help Weaver_Markup:Weaver Markup} and 
{help Weaver_mathematical_notation:Weaver mathematical notations} are no longer 
supported. Moreover, the display directives that is used for creating 
a multi-column which is {bf:{col #}} is not supported. 


{title:Notes}

{pstd}
For using LaTeX symbols in the {cmd:tbl} command, place a "{bf:#}" before "{bf:\}" of LaTeX code to avoid confusion with backslash required for separating lines. For example, write {bf:#\beta} instead of {bf:\beta} to render the Beta in the table. More over, for rendering LaTeX mathematical notations in the {cmd:tbl} command, use double dollar sign "{bf:$$}".  


{marker examples}{...}
{title:Examples}

{pstd}creating a simple 2x3 table with string and numbers

{phang2}{cmd:. tbl} ("Column 1", "Column 2", "Column 3" {bf:\} 10, 100, 1000 )

{pstd}creating a table that includes scalars and aligns the columns to left, center, and right respectively

{phang2}{cmd:. tbl} ({l}"Left", {c}"Centered", {r}"Right" {bf:\} c(os),  c(machine_type), c(username))


