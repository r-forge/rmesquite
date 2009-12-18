\name{getTreeInWindow}
\Rdversion{1.1}
\alias{getTreeInWindow}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Get tree from Mesquite window
}
\description{
Obtains the tree in the foremost tree window in Mesquite.
}
\usage{
getTreeInWindow()
}
%- maybe also 'usage' for other objects documented here.
\details{
You can combined this with showTree(tree) to send a tree to Mesquite, 
edit it and use it, then retrieve it in R.  An alternative but more restrictive way to edit
a tree in Mesquite is to use editTree(tree)
}
\value{
Returned as a MesquiteTree java object.
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
# mesquiteTree <- getTreeInWindow()
# phyloTree <- as.phylo(mesquiteTree)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
