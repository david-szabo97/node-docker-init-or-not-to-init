const cp = require("child_process");
const path = require("path");

// Create an interval to keep the process running.
const interval = setInterval(() => {}, 1000);

// Start the child process.
cp.fork(path.join(__dirname, "child.js"), {
  stdio: "inherit",
});

// Handle SIGTERM signal. This ensures that the application gracefully shuts down.
// Therefore Docker doesn't need to wait 10 seconds to kill the process.
process.on("SIGTERM", () => {
  console.log("[Main] SIGTERM signal received");
  clearInterval(interval);
});

console.log("[Main] Running...");
