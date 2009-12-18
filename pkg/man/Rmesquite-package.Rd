\name{RMesquite-package}
\alias{RMesquite-package}
\alias{RMesquite}
\docType{package}
\title{
RMesquite - Provides a transparent wrapper for Mesquite functions in R
}
\description{
  The RMesquite package provides transparent access to data types and
  analysis modules in Mesquite, and to some of Mesquite\'s graphical functions. Mesquite is a modular system for
  evolutionary analysis in Java (http://mesquiteproject.org).  
}
\details{
  To use RMesquite, Mesquite version 2.72 or later must also be installed on your computer, and the package Mesquite.R 
must be installed in Mesquite. To install Mesquite.R in Mesquite, start Mesquite, 
go to the menu item \"Check Now for Notices/Updates\" in the File menu, and enter the URL 
http://mesquiteproject.org/packages/Mesquite.R/installOSX.xml for Mac OS X,
http://mesquiteproject.org/packages/Mesquite.R/installWindows.xml for Windows,
and http://mesquiteproject.org/packages/Mesquite.R/installLinux.xml for Linux. 
The Mesquite.R package of modules in Mesquite also enables Mesquite to call functions in R.
\cr\cr
Headless versus Graphical Mesquite: Mesquite can be called from R either in its normal graphical version, 
or as a headless version. If you want to have access to Mesquite\'s windows, 
you need to use its graphical version. If you want to use only non-graphical calculations 
in Mesquite, you can use either version. Mac OS X Users: you cannot call the graphical 
version of Mesquite from the normal \"GUI\" R application or from the Terminal for reasons outside of our control. 
If you want to use the graphical version of Mesquite from R, 
you need to use instead the alternative JGR application for running R.\cr
\tabular{ll}{
Package: \tab RMesquite\cr
Type: \tab Package\cr
Version: \tab 0.5\cr
Date: \tab 2009-12-04\cr
License: \tab GPLv2.0 or later\cr
}



}
\author{
Hilmar Lapp (hlapp@gmx.net) and Wayne Maddison (wmaddisn@interchange.ubc.ca)

Maintainer: Hilmar Lapp <hlapp@gmx.net>
}
\references{
RMesquite web page: http://mesquiteproject.org/packages/Mesquite.R/RMesquite.html\cr
Mesquite.R web page: http://mesquiteproject.org/packages/Mesquite.R/index.html\cr
Maddison, W. P. and D.R. Maddison. 2009. Mesquite: a modular system for 
     evolutionary analysis.  Version 2.72  http://mesquiteproject.org
}
\keyword{ package }
\seealso{

}
\examples{
#To use Mesquite from R, you will need to start up Mesquite by calling startMesquite().

library(RMesquite)
startMesquite()
}
