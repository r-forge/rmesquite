#========================== Basic Mesquite functions =========================

#==== Trying to determine the location of Mesquite
#Behaviour should be (but isn't yet) as follows:
# If headless is not specified, then look to <mesquitePath> in the preferences file.  
#      If this mesquitePath is blank, then use mesquiteHeadlessPath instead
# If headless is false, then use mesquitePath
# otherwise use mesquiteHeadlessPath 
mesquite.classpath <- function(headless = FALSE) {
  # default location is $HOME/Mesquite_Support_Files
  home.dir <- if (.Platform$OS.type == "windows")
    Sys.getenv("HOMEPATH") else Sys.getenv("HOME");
  mesqu.prefs.dir <- paste(home.dir,
                           .Platform$file.sep,"Mesquite_Support_Files",
                           .Platform$file.sep,"Mesquite_Prefs",
                           sep="");
  # for now the only place we have to look into is the Mesquite preferences file,
  # so it has to have been fired up at least once.
  con <- file(paste(mesqu.prefs.dir,.Platform$file.sep,"Mesquite.xml",sep=""),
              open="r");
  l <- readLines(con,n=1);
  if (headless){
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
  }
  else {
   while((length(l) > 0) && (length(grep("<mesquitePath>",l)) == 0)) {
    l <- readLines(con,n=1);
  }
  close(con);
  if (length(l) > 0) {
    p <- sub(".*<mesquitePath>([^<]+)</mesquitePath>.*",
             "\\1",
             l);
    return(sub("\\./","",p));
  }
  }
  character(0);
}


# ==== Starts up Mesquite.  Expensive; should be done once before 
# calling Mesquite functions.
startMesquite <- function(cp, showWindows = TRUE, headless = FALSE){
  	assign(".mesquite.GUIAvailable",showWindows && !headless,pos="package:RMesquite");
  if (!headless && !(exists(".jgr.works") && .jgr.works) && (.Platform$OS.type == "unix" && system("uname",intern=TRUE) == "Darwin")){
 	print("If the version of Mesquite you are attempting to start is the normal graphical version, this command will not work. On Mac OS X, you cannot run the graphical version of Mesquite when running R from the normal GUI R app or the Terminal.  You need to use JGR to run R, or you need to use the headless version of Mesquite."); 
  
  }
  if (is.null(.mesquite.Runner)) {
 	 if (missing(cp)) {
 	   cp <- mesquite.classpath(headless);
 	 }
 	 if ((!is.null(cp)) && length(cp) > 0) {
  	  .jaddClassPath(cp);
  	}
 	# .jpackage("mesquite.R")
  	print("Starting Mesquite.  If any problems arise please see help file or http://mesquiteproject.org/packages/Mesquite.R/RMesquite.html");
  	print(cp);
  	tryCatch ({
  	mesquite.Runner <- .jnew("mesquite/R/RCallsMesquite/lib/MesquiteRunner")
  	}, finally = {
  	if (is.null(mesquite.Runner)) print("NOTE: Make sure you have started a copy of Mesquite previously, and that the last copy started has Mesquite.R installed.  Also, if using Mac OS X, either use JGR for running R, or use a headless version of Mesquite.")
  	});
  	assign(".mesquite.Runner",mesquite.Runner,pos="package:RMesquite");

	invisible(.jcall(mesquite.Runner, "Lmesquite/Mesquite;", "startMesquite", showWindows));
		
  }
  else {
  	print("Mesquite already started");
  }
 }

# ==== Returns the passed variable if provided and not null, and
# otherwise returns the cached instance of the Mesquite runner
.mesquite <- function(mesquite) {
  if (missing(mesquite) || is.null(mesquite))
    RMesquite::.mesquite.Runner
  else
    mesquite;
}

# ==== Stops Mesquite 
stopMesquite <- function(){
  .jcall(.mesquite(),
                   "V",
                   "stopMesquite");
  assign(".mesquite.Runner",NULL,pos="package:RMesquite");
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
# ==== Starts Mesquite module of given duty class.  E.g.,
# a number for character and tree should be indicated by
# "NumberForCharAndTree". This module
# itself may hire other modules and so forth. 
# The expectation is that Mesquite's UI will decide what module to hire
startMesquiteModuleOfDutyClass <- function(dutyClass, constraint){
  module <- .jcall(.mesquite(),
                   "Lmesquite/lib/MesquiteModule;",
                   "startModuleOfDutyClass",
                   dutyClass, constraint);
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

#==== Sets Mesquite to interactive mode
setInteractive <- function(interactive){
  com <- .jcall(.mesquite(),
				"V", 
				"setInteractive",
				interactive);

  com
}

