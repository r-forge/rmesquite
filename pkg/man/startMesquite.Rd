\name{startMesquite}
\Rdversion{1.1}
\alias{startMesquite}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Start Mesquite
}
\description{
Starts Mesquite.  Must be done before calling Mesquite's functions.

}
\usage{
startMesquite(cp, showWindows = TRUE, headless = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cp}{
The classpath of Mesquite.  This should be the path to Mesquite_Folder, e.g.
"/Applications/Mesquite_Folder".  If not specified, then RMesquite attempts to find Mesquite 
by looking in Mesquite's preference file for either the GUI or headless version, 
depending on how the headless argument is set.
}
  \item{showWindows}{
By default TRUE.  Whether or not to show windows.  If FALSE, then Mesquite's windows are suppressed.  
This applies when you are using a normal version of Mesquite.  If you are using a headless version,
then windows will not be shown regardless (showWindows has no effect).
}
  \item{headless}{
By default FALSE.  If TRUE then if no classpath was specified, then the function attempts to find the
headless version by looking into the Mesquite preferences files (this requires that the headless version has been 
previously run outside of the context of R, 
so that it can record its location in Mesquite's preference file).  NOT YET IMPLEMENTED: This function will also
 set the headless flag so that Java is operating in headless mode.  Setting the headless flag is probably important only
 when running Mesquite on a server, because for other purposes it suffices to run the headless version (without the headless flag
 set).  Because the showWindows argument permits you to suppress windows,
the primary purpose of using headless=TRUE would be to run Mesquite where only headless is permitted
(e.g., running on a server or when using OS X and not using JGR to run R). 

}
}
\details{
If you don't specify the classpath, then before calling Mesquite from R, 
you should separately start up the copy of Mesquite that you want to call (and then quit Mesquite), 
at least once. Mesquite will record its location in its preferences file; 
RMesquite will look there to discover where Mesquite is. 
(You don't need to start Mesquite separately each time you want to call it from R, just once
for Mesquite to record its location.)
\cr\cr
Headless versus Graphical Mesquite: Mesquite can be called from R either in its normal graphical version, 
or as a headless version. If you want to have access to Mesquite's windows, 
you need to use its graphical version. If you want to use only non-graphical calculations 
in Mesquite, you can use either version. Mac OS X Users: you cannot call the graphical 
version of Mesquite from the normal "GUI" R application or from the Terminal even if you set showWindows to FALSE. 
If you want to use the graphical version of Mesquite from R, 
you need to use instead the alternative JGR application for running R.
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
library(RMesquite)
startMesquite()
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
