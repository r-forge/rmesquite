#========================== Basic Mesquite functions =========================

#==== Trying to determine the location of Mesquite
mesquite.classpath <- function() {
  # default location is $HOME/Mesquite_Support_Files
  home.dir <- if (.Platform$OS.type == "windows")
    Sys.getenv("HOMEPATH") else Sys.getenv("HOME");
  mesqu.prefs.dir <- paste(home.dir,
                           .Platform$file.sep,"Mesquite_Support_Files",
                           .Platform$file.sep,"Mesquite_Prefs",
                           sep="");
  # for now the only place we have to look into is the Mesquite log,
  # so it has to have been fired up at least once, and it must have
  # been the headless version that was fired up last.
  con <- file(paste(mesqu.prefs.dir,.Platform$file.sep,"Mesquite.xml",sep=""),
              open="r");
  l <- readLines(con,n=1);
  while((length(l) > 0) && (length(grep("<mesquiteHeadlessPath>",l)) == 0)) {
    l <- readLines(con,n=1);
  }
  close(con);
  if (length(l) > 0) {
    p <- sub(".*<mesquiteHeadlessPath>([^<]+)</mesquiteHeadlessPath>.*",
             "\\1",
             l);
    return(sub("\\./","",p));
  }
  character(0);
}

# ==== Starts up Mesquite.  Expensive; should be done once before
# calling Mesquite functions.
startMesquite <- function(cp){
  if (missing(cp)) {
    cp <- mesquite.classpath();
  }
  if ((!is.null(cp)) && length(cp) > 0) {
    .jaddClassPath(cp);
  }
  mesquite.Runner <- .jnew("mesquite/rmLink/rCallsM/MesquiteRunner");
  assign(".mesquite.Runner",mesquite.Runner,pos="package:RMesquite");
  invisible(.jcall(mesquite.Runner, "Lmesquite/Mesquite;", "startMesquite"));
}

# ==== Returns the passed variable if provided and not null, and
# otherwise returns the cached instance of the Mesquite runner
.mesquite <- function(mesquite) {
  if (missing(mesquite) || is.null(mesquite))
    RMesquite::.mesquite.Runner
  else
    mesquite;
}

# ==== Starts Mesquite module of given class.  E.g.,
# mesquite.diverse.BiSSELikelihood should be indicated by
# #BiSSELikelihood or #mesquite.diverse.BiSSELikelihood. This module
# itself may hire other modules and so forth.  The script passed can
# control the parameters of this module as well as the hiring of this
# module/s employee modules
startMesquiteModule <- function(className, script=NULL){
  if (is.null(script)) {
    script <- .jnull(class="java/lang/String");
  }
  module <- .jcall(.mesquite(),
                   "Lmesquite/lib/MesquiteModule;",
                   "startModule",
                   className,
                   script);
  module
}

# ==== Stops Mesquite module.  Should be called when a module is no
# longer needed.
stopMesquiteModule <- function(module){
  .jcall(.mesquite(),
         "V",
         "stopModule",
         module);
}

#==== Gets from Mesquite a list of modules available for a particular duty
availableMesquiteModules <- function(dutyName){
  moduleList <- .jcall(.mesquite(),
                     "[S",
                     "modulesWithDuty",
                     dutyName);
  moduleList
}

#==== Shows the list of module names with explanations
showModules <- function(category){
	if (is.character(category)){
		category <- availableMesquiteModules(category)
	}
 for (i in 1:length(category))
  {
    module <- category[[i]]
    name <- .jcall(.mesquite(), "S", "getName", module)
    className <- .jcall(.mesquite(), "S", "getClassName", module)
    explanation <- .jcall(.mesquite(), "S", "getExplanation", module)
    result <- paste(name, " -- ", explanation, " (Class name: ", className, ")")
    show(result)
  }
}
#==== Shows the list of module names with explanations
showDuties <- function(){
  dutyList <- .jcall(.mesquite(),
                     "[S",
                     "dutyClasses");
  dutyList
}

#==== Returns commands of a particular module
getCommands <- function(module){
  com <- .jcall(.mesquite(),
                     "[S",
                     "commandsOfModule",
                     module);
  com
}

#==== Shows commands of a particular module
showCommands <- function(module){
	c <- getCommands(module)
	cat(c,sep="\n")
}

