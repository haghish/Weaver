{smcl}

{marker title}{...}
{title:Title}

{phang}
{cmdab:Weaver mathematical notation} {hline 2} Rendering {bf:ASCIImath} and {bf:LaTeX}
mathematical notations in {bf:{help weaver}} package. 


{title:Description}

{p 4 4 2}
{help Weaver} package uses {browse "http://docs.mathjax.org/en/latest/":MathJax} JavaScript to render Mathematical notations in a dynamic document. The default language is {bf:ASCIImath} which is very has very intuitive syntax and thus is the default mathematical notation markup in {help Weaver} package. In contrast, {bf:LaTeX} notation for rendering mathematical notations are more complex but much more popular due to popularity of {bf:LaTex}.  using the {opt math(name)} option in the {cmd: weave} command, the default mathematical markup can be changed to {bf:LaTeX}. 

{p 4 4 2}
{c 149} {browse "http://asciimath.org/":MathJax ASCIImath Documentation}

{p 4 4 2}
{c 149} {browse "http://docs.mathjax.org/en/latest/tex.html#tex-and-latex-in-html-documents":MathJax LaTeX Math Documentation}


{title:Writing mathematical notations}

{p 4 4 2}
To write mathematical notations in {help Weaver} package, regardless of using 
{bf:ascii} or {bf:latex}, the notation must be written in {bf:{help txt}} 
command which is in charge of writing text in Weaver. The mathematical notation 
also must be separated from the rest of the text. If the notation is meant to 
be rendered within the text paragraph, it must being and end with double hashtags 
(number sign) "{bf:##}". In order to render the notations on a separate line, 
in the center of the document, triple hashtags "{bf:###}" can be used 
(see examples below). 

{p 4 4 2}
Note that MathJax uses notations that can potentially 
conflict with Stata syntax, particularly {help macro} syntax, which are dollar sign "{bf:$}" and grave accent "{bf:`}". In order to avoid any potential conflict with Stata syntax, Weaver has applied the double and triple hashtags. 

{synoptset 30}{...}
{marker mathnotation}
{p2col:{it:Markup}}Description{p_end}
{synoptline}

{synopt :{bf: ## } mathematical notation {bf: ##}}render mathematical notation within text paragraph {p_end}
{synopt :{bf: ###} mathematical notation {bf: ###}}render mathematical notation in the center of a separate line {p_end}

{synoptline}
{p2colreset}{...}


{marker example}{...}
{title:Example of mathematical notations}

{pstd}
You want to write the formula of a simple linear regression with a single predictor and you want to 
discuss it within the text paragraph, using {bf:ASCIImath} mathematical markup notation: 

{phang2}{cmd:. txt ## hat mu(x) = beta_0 + beta_1x ##}{p_end}

{pstd}
and to render the same notation in the center of the document, on a separate line, type:

{phang2}{cmd:. txt ### hat mu(x) = beta_0 + beta_1x ###}{p_end}

{pstd}
Writting the same formula in {bf:LaTeX} would be as follows:

{phang2}{cmd:. txt  ### \widehat{\mu} (x) = \beta{_0} + \beta{_1} x ###}


{title:Related Packages}

{psee}
{space 0}{bf:{help Weaver}} : Creating HTML and PDF dynamic documents



