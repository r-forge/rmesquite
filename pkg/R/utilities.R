#==== Shows tree in Mesquite to be edited by hand.  Accepts either phylo or MesquiteTree, and
# returns same type as given
editTree <- function(tree){
  	if (!.mesquite.GUIAvailable){
  		print("To show a tree, you need to have called startMesquite requesting the graphical version of Mesquite.");
  	}
  	else {
	wasMesquiteTree = TRUE;
  	if (class(tree) != "jobjRef") {
   	 tree <- mesquiteTree(tree=tree);
   	 wasMesquiteTree = FALSE;
  	}
	returnedTree <- .jcall(.mesquite(), "Lmesquite/lib/MesquiteTree;", "editTree", tree);
	if (!wasMesquiteTree)
		returnedTree <- as.phylo(returnedTree)
	returnedTree
	}
}

#==== Shows tree in Mesquite.  Reuses previously used window if available
showTree <- function(tree){
  	if (!.mesquite.GUIAvailable){
  		print("To show a tree, you need to have called startMesquite requesting the graphical version of Mesquite.");
  	}
  	else {
  	if (class(tree) != "jobjRef") {
   	 	tree <- mesquiteTree(tree=tree);
   	 }
	.jcall(.mesquite(), "V", "showTree", tree);
	}
}


#==== Gets tree in Tree Window in Mesquite that is in the foreground
getTreeInWindow <- function(){
	returnedTree <- .jcall(.mesquite(), "Lmesquite/lib/MesquiteTree;", "getTreeInWindow");
	returnedTree
}

#==== Gets matrix in Character Matrix Editor window in Mesquite that is in the foreground
getMatrixInWindow <- function(){
	returnedMatrix <- .jcall(.mesquite(), "Lmesquite/lib/characters/CharacterData;", "getMatrixInWindow");
	returnedMatrix
}
