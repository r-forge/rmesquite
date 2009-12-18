\name{getMatrixInWindow}
\Rdversion{1.1}
\alias{getMatrixInWindow}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Get character matrix from Mesquite window
}
\description{
Obtains the character matrix in the frontmost Character Matrix Editor window in Mesquite.
}
\usage{
getMatrixInWindow()
}
%- maybe also 'usage' for other objects documented here.
\details{
For continuous and meristic matrices in Mesquite, missing data (?) and inapplicable codings (-) are 
returned as NaN.  For three dimensional (multi item) matrices, only the first item is returned.  
For categorical matrices, these are returned as the strings ? and -.  For categorical matrices, 
polymorphisms and uncertainties are returned as a list of states, e.g. 0&2 and 0/2 are both returned as "0 2".
}
\value{
Matrix is returned as a Mesquite matrix (e.g., ContinuousData object, or CategoricalData object).
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
# mesquiteMatrix <- getMatrixInWindow()
# rMatrix <- as.matrix(mesquiteMatrix)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
