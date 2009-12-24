#=================== Harvesting Data Objects from Mesquite ==================

#==== Asks Mesquite to read a file.  Format is by default nexus; otherwise currently use name of Mesquite module that does interpretation (e.g., "#InterpretFastaDNA")
mesquiteReadFile <- function(mesquite,path,format="NEXUS"){
  project <- .jcall(.mesquite(),
                    "Lmesquite/lib/MesquiteProject;",
                    "readFile",
                    path, format)
  project
}

#==== Asks Mesquite about the contents of a project.  Not all elements listed yet
getProjectContents <- function(project){
	taxaBlocks <- .jcall(.mesquite(), "[S", "projectContents", project)
	
	taxaBlocks
	
}

#==== Asks Mesquite to show the contents of a project.  Not all elements listed yet
showProjectContents <- function(project){
	c <- getProjectContents(project)
	cat(c,sep="\n")
}

#==== Gets taxa (OTU) blocks in project in Mesquite
getTaxaBlocks <- function(project){
	taxaBlocks <- .jcall(.mesquite(), "[Lmesquite/lib/Taxa;", "getTaxaBlocks", project)
	taxaBlocks
	
}

#==== Gets number of taxa (OTUs) in Mesquite taxa block
getNumberOfTaxa <- function(taxaBlock){
	num <- .jcall(taxaBlock, "I", "getNumTaxa")
	num
}

#==== Doesn't do anything yet
getTaxonNames <- function(taxaBlock){
	
}

#==== Gets tree vectors available for the taxa block in Mesquite
getTreeVectors <- function(taxaBlock){
	treeVectors <- .jcall(.mesquite(), "[Lmesquite/lib/TreeVector;", "getTreeVectors", taxaBlock)
	treeVectors
}

#==== Gets number of trees in Mesquite tree vector
getNumberOfTrees <- function(treeVector){
	num <- .jcall(treeVector, "I", "getNumberOfTrees")
	num
}

#==== Gets tree #treeIndex from Mesquite tree vector and returns as phylo object
getPhyloTreeFromVector <- function(treeVector, treeIndex){
	treeString <- .jcall(.mesquite(), "S", "getTree", treeVector, as.integer(treeIndex))
	eval(parse(text = paste("tree <- ", treeString, sep="")))
	tree
}


#==== Gets a list of Continuous matrices in Mesquite
getContinuousMatrices <- function(taxaBlock){
	#Hilmar: to be cleaned
	matrices <- .jcall(.mesquite(), "[Lmesquite/cont/lib/ContinuousData;", "getContinuousMatrices", taxaBlock)
	matrices
}

#==== Gets a list of Categorical matrices in Mesquite
getCategoricalMatrices <- function(taxaBlock){
	#Hilmar: to be cleaned
	matrices <- .jcall(.mesquite(), "[Lmesquite/categ/lib/CategoricalData;", "getCategoricalMatrices", taxaBlock)
	matrices
}

#==== Gets a list of DNA matrices in Mesquite
getDNAMatrices <- function(taxaBlock){
	#Hilmar: to be cleaned
	matrices <- .jcall(.mesquite(), "[Lmesquite/categ/lib/DNAData;", "getDNAMatrices", taxaBlock)
	matrices
}

#==== Gets number of characters in Mesquite matrix
getNumberOfCharacters <- function(mesqMatrix){
	#Hilmar: to be cleaned
	num <- .jcall(mesqMatrix, "I", "getNumChars")
	num
}

#==== Gets character names from Mesquite matrix
getColumnNames <- function(mesqMatrix){
	#Hilmar: to be cleaned
	str <- .jcall(.mesquite(), "[S", "getColumnNames", .jcast(mesqMatrix, new.class = "mesquite/lib/characters/CharacterData"))
	str
}

#==== Gets taxon names from Mesquite matrix
getRowNames <- function(mesqMatrix){
	#Hilmar: to be cleaned
	str <- .jcall(.mesquite(), "[S", "getRowNames", .jcast(mesqMatrix, new.class = "mesquite/lib/characters/CharacterData"))
	str
}

#================== Converting types from and to Mesquite ==================

.jclassOf <- function(obj,package.path=TRUE) {
  cl <- .jcall(obj,"Ljava/lang/Class;","getClass");
  cl.name <- .jcall(cl,"Ljava/lang/String;","getName");
  if (!package.path) {
    cl.name <- sub(".*\\.","",cl.name);
  }
  cl.name
}

from.RNumericMatrix <- function(obj) {
  if (class(obj) != "jobjRef") {
    stop("need to pass java object reference, not ",class(obj));
  }
  col.names <- .jcall(obj, "[Ljava/lang/String;","getColumnNames");
  row.names <- .jcall(obj, "[Ljava/lang/String;","getRowNames");
  vals <- .jcall(obj, "[[Lmesquite/lib/MesquiteNumber;","getValues");
  vals <- sapply(vals,
                 function(col) sapply(.jevalArray(col),
                                      function(obj) .jcall(obj,
                                                           "D",
                                                           "getDoubleValue")));
  if (length(row.names) < 2) {
    ans <- vals;
    names(ans) <- col.names;
    return(ans);
  }
  ans <- matrix(vals, nrow=length(row.names), byrow=FALSE);
  if (!all(is.na(row.names))) {
    rownames(ans) <- row.names;
  }
  if (!all(is.na(col.names))) {
    colnames(ans) <- col.names;
  }
  ans
}

from.CharacterMatrix <- function(obj,
                                 class.name=.jclassOf(obj,package.path=FALSE)) {
  if (class(obj) != "jobjRef") {
    stop("need to pass java object reference, not ",class(obj));
  }
  charM <- .jnew("mesquite/R/common/RCharacterData",
                 .jcast(obj,"mesquite/lib/characters/CharacterData"));
  col.names <- .jcall(charM, "[Ljava/lang/String;","getColumnNames");
  row.names <- .jcall(charM, "[Ljava/lang/String;","getRowNames");
  states <- vector();
  if (class.name == "ContinuousData") {
    states <- .jcall(charM, "[D","asDoubleMatrix");
  } 
   else if (class.name == "MeristicData") {
    states <- .jcall(charM, "[D","asDoubleMatrix");
  } else {
    states <- .jcall(charM, "[Ljava/lang/String;","asStringMatrix");
  }
  ans <- matrix(states, nrow=length(row.names), byrow=TRUE);
  if (!all(is.na(row.names))) {
    rownames(ans) <- row.names;
  }
  if (!all(is.na(col.names))) {
    colnames(ans) <- col.names;
  }
  ans  
}

as.matrix.jobjRef <- function(x, ...) {
  if (class(x) != "jobjRef") {
    stop("need to pass java object reference, not ",class(x));
  }
  cl.name <- .jclassOf(x,package.path=FALSE);
  if (cl.name == "RNumericMatrix") {
    return(from.RNumericMatrix(x));
  }
  if (cl.name %in% c("CategoricalData","ContinuousData","DNAData","MeristicData")) {
    return(from.CharacterMatrix(x,class.name=cl.name));
  }
  stop("currently not supported for objects of class ",.jclassOf(x));
}

as.phylo.jobjRef <- function(x, ...) {
  if (.jclassOf(x,package.path=FALSE) != "MesquiteTree") {
    stop("can't coerce Java object of type ",.jclassOf(x)," to type phylo");
  }
  mRoot <- .jcall(x,"I","getRoot");
  numNodes <- .jcall(x,"I","numberOfNodesInClade",mRoot);
  numTerminals <- .jcall(x,"I","numberOfTerminalsInClade",mRoot);
  mAPE <- .jnew("mesquite/R/common/APETree",
                .jcast(x,"mesquite/lib/Tree"));
  edge.matrix <- .jcall(mAPE,"[[I","getEdgeMatrix");
  phylo <- list(edge=matrix(
                  c(.jevalArray(edge.matrix[[1]]),
                    .jevalArray(edge.matrix[[2]])),
                  ncol=2),
                edge.length=.jcall(mAPE,"[D","getEdgeLengths"),
                tip.label=.jcall(mAPE,"[Ljava/lang/String;","getTipLabels"),
                Nnode=numNodes-numTerminals);
  class(phylo) <- "phylo";
  phylo
}

## Initial suggestion (hack) by Ben Bolker for converting to
## phylo4. We wait with this until we are comfortable with having a
## dependency on phylobase.
##
## setAs("jobjRef","phylo4",
##       function(from,to) {
##           if (.jclassOf(from,package.path=FALSE) != "MesquiteTree") {
##               stop("can't coerce Java object of type ",
##                    .jclassOf(from)," to type phylo4");
##           }
##           mRoot <- .jcall(from,"I","getRoot");
##           numNodes <- .jcall(from,"I","numberOfNodesInClade",mRoot);
##           numTerminals <- .jcall(from,"I","numberOfTerminalsInClade",mRoot);
##           mAPE <- .jnew("mesquite/R/common/APETree",
##                         .jcast(from,"mesquite/lib/Tree"));
##           edge.matrix <- .jcall(trApe,"[[I","getEdgeMatrix");
##           phylo4(edge=matrix(
##                    c(.jevalArray(edge.matrix[[1]]),
##                      .jevalArray(edge.matrix[[2]])),
##                    ncol=2),
##                  edge.length=.jcall(mAPE,"[D","getEdgeLengths"),
##                  tip.label=.jcall(mAPE,
##                    "[Ljava/lang/String;","getTipLabels"),
##                  ## don't know whether any of these three elements
##                  ## can be pulled out of a jobjRef or not
##                  node.label=NULL,
##                  edge.label=NULL,
##                  root.edge=NA
##                  )
##       });

#========================== Giving Data To Mesquite ========================

# ==== Creates taxa block in Mesquite with taxon names as indicated by
# the array
mesquiteTaxaBlock <- function(mesquite=.mesquite(),
                              nameArray=NULL,
                              blockName=NULL){
  if (is.null(blockName)) {
    blockName <- paste(".block.",as.integer(runif(1,min=1,max=2^31)),sep="");
  }
  taxa <- .jcall(mesquite,
                 "Lmesquite/lib/Taxa;",
                 "loadTaxaBlock",
                 blockName,
                 nameArray);
  taxa
}

# ==== Creates categorical matrix in Mesquite.
mesquiteCategoricalMatrix <- function(mesquite=.mesquite(),
                                      charMatrix,
                                      matrixName=NULL,
                                      numCols=if (is.matrix(charMatrix)) dim(charMatrix)[2] else 1,
                                      taxaBlock,
                                      blockName=NULL) {
  if (is.character(taxaBlock)) {
    taxaBlock <- mesquiteTaxaBlock(mesquite,
                                   nameArray=taxaBlock, blockName=blockName);
  }
  if (is.null(matrixName)) {
    matrixName <- paste(".matrix.",as.integer(runif(1,min=1,max=2^31)),sep="");
  }
  catMatrix <- .jcall(mesquite,
                      "Lmesquite/categ/lib/CategoricalData;",
                      "loadCategoricalMatrix",
                      .jcast(taxaBlock, new.class="mesquite/lib/Taxa"),
                      matrixName,
                      as.integer(numCols),
                      as.integer(charMatrix));
  catMatrix
}

# ==== Creates tree in Mesquite from newick string or from phylo object
mesquiteTree <- function(mesquite=.mesquite(),
                         tree,
                         treeName=NULL,
                         taxaBlock=NULL,
                         blockName=NULL){
  if (is.character(tree)) {
    tr <- read.tree(text=tree);
    if (is.null(tr)) {
      # would be really nice if APE gave us an error message rather than NULL
      stop("character string \"",tree,"\" failed to parse using APE\n");
    }
    tree <- tr;
  }
  if (class(tree) != "phylo") {
    stop("tree argument must be string or class phylo, not ",class(tree),"\n");
  }
  if (is.null(taxaBlock)) {
    taxaBlock <- tree$tip.label;
  }
  if (is.character(taxaBlock)) {
    taxaBlock <- mesquiteTaxaBlock(mesquite,
                                   nameArray=taxaBlock, blockName=blockName);
  }
  if (is.null(treeName)) {
    treeName <- paste(".tree.",as.integer(runif(1,min=1,max=2^31)),sep="");
  }
  tree <- .jcall(mesquite,
                 "Lmesquite/lib/MesquiteTree;",
                 "loadTree",
                 taxaBlock,
                 treeName,
                 paste(write.tree(tree),collapse=""));
  tree
}

