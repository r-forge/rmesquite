\name{editTree}
\Rdversion{1.1}
\alias{editTree}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Edit tree in Mesquite
}
\description{
  Sends a phylogenetic tree to Mesquite for editing in Mesquite's graphical tree window.
}
\usage{
editTree(tree)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{tree}{
A tree either as a phylo object, or as a MesquiteTree java object.
}
}
\details{
Requires use of the normal (GUI) version of Mesquite (not the headless version).
}
\value{
  Returns an edited version of the tree, of the same type as entered.
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

# library(RMesquite)
# startMesquite()
# data(bird.families)
# tree <- bird.families
# modifiedTree <- editTree(tree)

# At this point, Mesquite will show a tree window with your tree.  
# R will pause until you have edited the tree in Mesquite,
# then hit the "Done" button in the tree window.  
# Once you\'ve done that, the modified tree will be returned to R.
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
