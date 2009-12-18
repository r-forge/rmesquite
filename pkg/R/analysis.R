#========================== Calling Analyses in Mesquite =====================
# NOTE: most of these can be called with either headless or GUI Mesquite; some only with GUI

# ==== Calls a Mesquite module that returns values for a tree and
# character.  Requires that the module be of java subclass
# NumberForTreeAndCharacter. Does NOT require that the module has already been
# started.  However, this means that a module is started for each
# request.
# NOTE: perhaps we should pass a boolean to Mesquite to indicate whether it is to shut down the module, or return it for reuse
# Returning it would require Mesquite to pass back a more complex object consisting of result + module
mesquiteApply.TreeAndCategChar <- function(mesquite=.mesquite(),
                                           module,
                                           dutyClass,
                                           tree,
                                           categMatrix,
                                           charIndex=1,
                                           runnerMethod,
                                           returnType="mesquite.R.lib.RNumericMatrix",
                                           castMatrixType=NULL,
                                           taxaBlock=NULL,
                                           module.script=NULL) {
  if (class(tree) != "jobjRef") {
    tree <- mesquiteTree(mesquite, tree=tree, taxaBlock=taxaBlock);
  }
  if (class(categMatrix) != "jobjRef") {
    if (is.null(taxaBlock) || (class(taxaBlock) != "jobjRef")) {
      taxaBlock <- tree$getTaxa();
    }
    categMatrix <- mesquiteCategoricalMatrix(mesquite,
                                             charMatrix=categMatrix,
                                             taxaBlock=taxaBlock);
  }
  need.stop <- FALSE;
  if (is.character(module)) {
    module <- startMesquiteModule(module,script=module.script);
    need.stop <- TRUE;
  }
  else if (is.character(dutyClass)) {
    constraint <- .jcast(categMatrix,new.class="java/lang/Object")
    module <- startMesquiteModuleOfDutyClass(dutyClass = dutyClass, constraint = constraint);
    need.stop <- TRUE;
  }
  if (length(grep("\\.",returnType)) > 0) {
    returnType <- paste("L",gsub("\\.","/",returnType),";",sep="");
  }
  result <- .jcall(.mesquite(),
                   returnType,
                   runnerMethod,
                   module,
                   tree,
                   if (is.null(castMatrixType)) {
                     categMatrix
                   } else {
                     .jcast(categMatrix,new.class=castMatrixType)
                   },
                   as.integer(charIndex));
  if (need.stop) stopMesquiteModule(module);
  from.RNumericMatrix(result);
}

mesquiteApply.NumberForTreeAndCategChar <- function(mesquite=.mesquite(),
                                                    module,
                                                    tree,
                                                    categMatrix,
                                                    charIndex=1,
                                                    taxaBlock=NULL,
                                                    module.script=NULL) {
  mesquiteApply.TreeAndCategChar(mesquite,
                                 module=module,
                                 tree=tree,
                                 categMatrix=categMatrix,
                                 charIndex=charIndex,
                                 taxaBlock=taxaBlock,
                                 runnerMethod="numberForTreeAndCharacter",
                                 castMatrixType="mesquite/lib/characters/CharacterData",
                                 module.script=module.script);
}

mesquiteApply.AncestralStateCategChar <- function(mesquite=.mesquite(),
                                                  module,
                                                  tree,
                                                  categMatrix,
                                                  charIndex=1,
                                                  taxaBlock=NULL,
                                                  module.script=NULL) {
  mesquiteApply.TreeAndCategChar(mesquite,
                                 module=module,
                                 tree=tree,
                                 categMatrix=categMatrix,
                                 charIndex=charIndex,
                                 taxaBlock=taxaBlock,
                                 runnerMethod="ancestralStatesCategorical",
                                 castMatrixType="mesquite/categ/lib/CategoricalData",
                                 module.script=module.script);
}

#====  Calls a Mesquite function that calculates a number for a character and tree; Mesquite chooses which  
# TO BE CALLED ONLY WITH GUI MESQUITE
evaluateTreeAndCharacter <-  function(tree,
                             categMatrix,
                             charIndex=1,
                             taxaBlock=NULL,
                             script=NULL){
  result <- mesquiteApply.TreeAndCategChar(module=NULL,
  										   dutyClass = "mesquite.lib.duties.NumberForCharAndTree",
                                           tree=tree,
                                           categMatrix=categMatrix,
                                           charIndex=charIndex,
                                           taxaBlock=taxaBlock,
                                           runnerMethod="numberForTreeAndCharacter",
                                           castMatrixType="mesquite/lib/characters/CharacterData",
                                           module.script=script);
  result
}
#====  Calls Mesquite's BiSSE likelihood function.  
bisseLikelihood <-  function(tree,
                             categMatrix,
                             charIndex=1,
                             taxaBlock=NULL,
                             script=NULL){
  result <- mesquiteApply.TreeAndCategChar(module="#BiSSELikelihood",
                                           tree=tree,
                                           categMatrix=categMatrix,
                                           charIndex=charIndex,
                                           taxaBlock=taxaBlock,
                                           runnerMethod="numberForTreeAndCharacter",
                                           castMatrixType="mesquite/lib/characters/CharacterData",
                                           module.script=script);
  result
}

# ==== Call's one of Mesquite's ancestral state reconstruction methods
# for categorical matrices
ancestralStatesCategorical <-  function(tree,
                                        categMatrix,
                                        method="ML",
                                        charIndex=1,
                                        taxaBlock=NULL,
                                        script=NULL) {
  methods <- c("#MargProbAncStates","#ParsAncestralStates");
  m.short <- c("ML","Parsimony");
  i <- charmatch(method,m.short,nomatch=0);
  if (i > 0) method <- methods[i];
  result <- mesquiteApply.TreeAndCategChar(module=method,
                                           tree=tree,
                                           categMatrix=categMatrix,
                                           charIndex=charIndex,
                                           taxaBlock=taxaBlock,
                                           runnerMethod="ancestralStatesCategorical",

                                           module.script=script);
  result
}

