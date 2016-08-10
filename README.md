# Weaver : a LaTeX and HTML log system for dynamic documents in Stata

A general purpose package for creating dynamic report in HTML, LaTeX, and PDF.
Weaver includes a built-in JavaScript syntax highlighter for Stata code, an engine
for rendering ASCII and LaTeX mathematical notations, a number of specialized
commands for creating publication-ready dynamic table, inserting and resizing a
figure, and writing dynamic text.  Moreover, Weaver also includes a built-in
JavaScript-based language called Weaver markup Language which allows the users to
create a sophisticated HTML document using a simplified and minimalistic markup
language, similar but not identical to Markdown.

Weaver is essentially an independent HTML or LaTeX log system that runs in paralel
        to Stata log and can be used simultaniously with regular smcl or text logfile. In
        contrast to smcl log file, the main idea of the Weaver package is to provide the
        possibility of deciding which commands, results, and figures should appear in the
        Weaver log (dynamic report). Therefore, Weaver log is not autonomous. The big
        advantage of this approach to dynamic reporting is that as the user carries out the
        data analysis interactively, the dynamic document can be viewed in real-time by
        refreshing the HTML web-browser, or opening the LaTeX document in [TeXstudio](http://www.texstudio.org/) or any
        advanced text editor such as [Sublime Text](https://www.sublimetext.com/), 
        or alternatively, reandering a PDF
        document at any point.  These features work smoothly for both LaTeX and HTML.
        Another example would be a LaTeX table exported from tabout command which can be
        merged in Weaver's LaTeX log.

 Weaver is a general purpose package that is designed to effectively handle HTML and
        LaTeX documents. It includes many additional features that makes it a prime package
        for collaborating with all other packages for developing automated outputs such as 
        MarkDoc, tabout, etc. Any package that produces LaTeX or HTML output, cal
        collaborate with Weaver because Weaver allows importing HTML and LaTeX documents.
        For example, a document written in Markdown language and exported to LaTeX or HTML
        using the [MarkDoc package](http://haghish.com/markdoc), can be simple merged into Weaver's LaTeX or HTML log
        respectively.

Visit [](http://haghish.com/weaver) for a complete tutorial on Weaver as well as
        downloading template do-files.


 

        
Author
------
  **E. F. Haghish**  
  Center for Medical Biometry and Medical Informatics
  University of Freiburg, Germany      
  _haghish@imbi.uni-freiburg.de_     
  _http://www.haghish.com/weaver_  
  _[@Haghish](https://twitter.com/Haghish)_   
  
Installation
------------

The __Weaver__ releases are also hosted on SSC server. So you can download the latest release as follows:

    ssc install weaver
    
You can also directly download __Weaver__ from GitHub which includes the latest beta version (unreleased). The `force` 
option ensures that you _reinstall_ the package, even if the release date is not yet changed, and thus, must be specified. 
  
    net install weaver, replace  from("https://raw.githubusercontent.com/haghish/weaver/master/")
    
__Weaver__ also requires one additional Stata packages which is __`statax`__, hosted on SSC.

    ssc install statax
    
Finally, in order to export dynamic PDF documents, __Weaver__ requires two additional third-party software which are [wkhtmltopdf](http://wkhtmltopdf.org/) for exporting HTML log to PDF, and a [complete distribution of LaTeX](https://latex-project.org/ftp.html) for Typesetting LaTeX documents. The complete guide for installing them is provided in the MarkDoc help file and also, 
[__Weaver Homepage__ ](http://www.haghish.com/weaver)
    





