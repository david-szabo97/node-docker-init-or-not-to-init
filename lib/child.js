const cp = require("child_process");
const path = require("path");

cp.fork(path.join(__dirname, "sub-child.js"), {
  stdio: "inherit",
});

console.log("[Child] Running...");

// This process doesn't terminate immediately because it's waiting for its child process to terminate.
