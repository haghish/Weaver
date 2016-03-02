{smcl}

{marker title}{...}
{title:Title}

{phang}
{cmdab:img} {hline 2} Imports images and graphs into the dynamic document. 
This command belongs to {bf:{help Weaver}} package but it also supports the 
{bf:{help MarkDoc}} package. The syntax for both packages is the same but
the {cmdab:img} command behave differently based on which of the packages is in use. 


{title:Author} 
        {p 8 8 2}E. F. Haghish{break} 
	Center for Medical Biometry and Medical Informatics{break}
	University of Freiburg, Germany{break} 
        {browse haghish@imbi.uni-freiburg.de}{break}
	{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/weaver.php":{it:http://haghish.com/weaver}}{break}
   
   
{marker syntax}{...}
{title:Syntax}

    Import graphical files in the HTML log
	
	{cmdab:img} {it:{help filename}} [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} {opt h:eight(int)} {opt left} {opt center}  ]


{marker description}{...}
{title:Description}

{phang}
The {cmdab:img} command imports images and graphs into the dynamic document. 
Any graphical file that is compatible with a web-browser can be inserted in the 
html log.  
This command belongs to {help Weaver} package but it also supports the 
{help MarkDoc} package. The syntax for both packages is the same but
the {cmdab:img} command behave differently based on which of the packages is in use. 
If Weaver html log and smcl log are open at the same time, the command 
only functions for Weaver and not for MarkDoc. In contrast, when Weaver html log is
not open and scml log is on, it will function for MarkDoc package. 

{p 8 8 2}
{bf:Note:} This command 
only support MarkDoc if the document is exported in {bf:html} or {bf:pdf} formats. 


{title:Options}

{phang}{cmdab:tit:tle(}{it:str}{cmd:)} specify a header string (title) for the figure {p_end}

{phang}{opt w:idth(int)} define the width of the figure. This option must be used 
with {opt h:ight(int)} option. Otherwise, it will keep the actual hight of the 
figure and only changes the width. {p_end}

{phang}{opt h:ight(int)} define the hight of the figure. This option must be used 
with {opt w:idth(int)} option for the same reason mentioned above. {p_end}
 
{phang}{cmdab::left} this option is the default and it aligns the figure to the 
left-side of the dynamic document. {p_end}

{phang}{cmdab::left} aligns the figure to the center of the dynamic document. {p_end}


{marker example}{...}
{title:Example of interactive use}

{pstd}
You have created a graph in Stata. Before importing in the HTML log, you should 
export it in a format that can be interpreted in html. Such as PNG which is recommended 
because it is lossless format and the same file can be used for publication. 

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. histogram price}{p_end}
{phang2}{cmd:. graph export price.png, replace}{p_end}

{phang2}{cmd:. img price.png}{p_end}
{phang2}{cmd:. img price.png, title(Figure 1. This is the histogram of the Price variable)}{p_end}
{phang2}{cmd:. img price.png, w(300) h(200) center}{p_end} 


