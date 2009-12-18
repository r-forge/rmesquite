\name{ancestralStatesCategorical}
\Rdversion{1.1}
\alias{ancestralStatesCategorical}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Reconstruct ancestral states
}
\description{
Reconstructs ancestral states for a character on a phylogenetic tree
}
\usage{
ancestralStatesCategorical(tree, categMatrix, method = "ML", charIndex = 1, taxaBlock = NULL, script = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{tree}{
 A phylogenetic tree, either an object of type phylo, or a MesquiteTree java object.
}
  \item{categMatrix}{
 A categorical character matrix, either an R matrix or a CategoricalData java object.
}
  \item{method}{
method = "ML" for maximum likelihood, "parsimony" for parsimony.
}
  \item{charIndex}{
 which character of the matrix to use.
}
  \item{taxaBlock}{
 which taxa block to use; if null Mesquite will make a taxa block based on the tree.
}
  \item{script}{
%%     ~~Describe \code{script} here~~
}
}
\details{
This function is not yet fully implemented.
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
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
