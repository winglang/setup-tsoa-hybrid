bring util;

pub class Stack {
  protected stackName: str;
  protected root: str;
  /// Whether this stack should be considered external for the current compilation
  protected external: bool;

  new(stackName: str, root: str) {
    this.stackName = stackName;
    this.root = root;

    let isCurrent = nodeof(this).app.entrypointDir == root;
    this.external = !nodeof(this).app.isTestEnvironment && !isCurrent && util.tryEnv("ALL_STACKS") != "true";
  }
}