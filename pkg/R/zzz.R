.First.lib <- function(lib,pkg) {
  require(rJava);
  require(ape);
  assign(".mesquite.Runner",NULL,pos="package:RMesquite");
  op <- options();
  options(java.parameters=c("",op$java.parameters));
  .jpackage(pkg);
  options(op); # restore what we found
}

## Ideally we would want to clean up behind ourselves on exit, but at
## present there doesn't seem to be a good way to da this. Instead, we
## strongly recommend to initialize the JVM with forcing
## re-initialization, to startup with a clean environment.
