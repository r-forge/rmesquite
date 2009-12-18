\name{showTree}
\Rdversion{1.1}
\alias{showTree}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Show tree in Mesquite window
}
\description{
 Shows a phylogenetic tree in Mesquite's tree window. The tree may be analyzed, printed, and so on in Mesquite.
 }
\usage{
showTree(tree)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{tree}{
 A tree either as a phylo object or a MesquiteTree java object.
}
}
\details{
Requires use of the normal (GUI) version of Mesquite (not the headless version).
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
# Assume "tree" is an object of type phylo.

# library(RMesquite)
# startMesquite()
# showTree(tree)

# If desired, you can recover the tree later in R, if you\'ve modified it, using getTreeInWindow().
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
