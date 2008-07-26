.First.lib <- function(lib,pkg) {
  require(rJava);
  op <- options();
  options(java.parameters=c("-Djava.awt.headless=true",op$java.parameters));
  .jpackage(pkg);
  options(op); # restore what we found
}

## Ideally we would want to clean up behind ourselves on exit, but at
## present there doesn't seem to be a good way to da this. Instead, we
## strongly recommend to initialize the JVM with forcing
## re-initialization, to startup with a clean environment.
