// Start the app locally, then run: node benchmarks/shared_worker.mjs PORT
// Requires Node 22+ and a direct connection to a single Shiny worker.
import assert from "node:assert/strict";

const port = Number(process.argv[2]);
assert(Number.isInteger(port) && port > 0 && port <= 65535, "Supply the local Shiny port");
const base = new URL(`http://127.0.0.1:${port}/`);
const sockets = [];
const seconds = ms => (ms / 1000).toFixed(3);

async function session() {
  const socket = new WebSocket(`ws://127.0.0.1:${port}/websocket/`);
  sockets.push(socket);
  const send = message => socket.send(JSON.stringify(message));
  const pending = new Set();
  function waitFor(matches) {
    return new Promise((resolve, reject) => {
      const listener = message => {
        if (matches(message)) {
          clearTimeout(timer);
          pending.delete(listener);
          resolve(message);
        }
      };
      const timer = setTimeout(() => {
        pending.delete(listener);
        reject(new Error("Timed out waiting for Shiny: " + matches));
      }, 60000);
      pending.add(listener);
    });
  }
  socket.addEventListener("message", event => {
    const message = JSON.parse(event.data);
    for (const listener of pending) listener(message);
  });
  await new Promise((resolve, reject) => {
    socket.onopen = resolve;
    socket.onerror = () => reject(new Error("Cannot connect to " + base));
  });
  const ready = waitFor(message => message.values?.sampleFeedback === "");
  send({method: "init", data: {
    dataset: "New Zealand", csvFormat: "samples", importAction: "append",
    "confirmImportBtn:shiny.action": 0, "addManualDataBtn:shiny.action": 0,
    ".clientdata_output_workspaceStats_hidden": false,
    ".clientdata_output_sampleFeedback_hidden": false,
    ".clientdata_output_uploadStatus_hidden": false
  }});
  await ready;
  return {send, waitFor, update: data => send({method: "update", data})};
}

async function addSample(client, index) {
  const name = "Latency sample " + index;
  const feedback = client.waitFor(msg => msg.values?.sampleFeedback === "Added " + name);
  const start = performance.now();
  client.update({sampleName: name, sandValue: 50, siltValue: 25, clayValue: 25,
    "addManualDataBtn:shiny.action": index});
  await feedback;
  return performance.now() - start;
}

async function request(client, method, args, tag) {
  const reply = client.waitFor(msg => msg.response?.tag === tag);
  client.send({method, args, tag});
  const {response} = await reply;
  if (response.error) throw new Error(String(response.error));
  return response.value;
}

try {
  const importer = await session();
  const observer = await session();
  const idle = await addSample(observer, 1);
  const rows = 25000;
  const lines = ["soil,sand,silt,clay"];
  for (let i = 0; i < rows; i++) {
    const sand = i % 101;
    const clay = Math.floor(i / 101) % (101 - sand);
    lines.push(`Paddock ${i},${sand},${100 - sand - clay},${clay}`);
  }
  const file = Buffer.from(lines.join("\n") + "\n");
  const job = await request(importer, "uploadInit",
    [[{name: "paddocks.csv", size: file.length, type: "text/csv"}]], 1);
  const upload = await fetch(new URL(job.uploadUrl, base), {method: "POST", body: file});
  assert(upload.ok, `Upload returned HTTP ${upload.status}`);
  const preview = importer.waitFor(msg => msg.values?.uploadStatus === `${rows} rows are ready to import.`);
  await request(importer, "uploadEnd", [job.jobId, "fileUpload"], 2);
  await preview;
  const classified = importer.waitFor(msg => msg.values?.workspaceStats?.html?.includes("<strong>25000</strong>"));
  const start = performance.now();
  const importDuration = classified.then(() => performance.now() - start);
  importer.update({"confirmImportBtn:shiny.action": 1});
  await new Promise(resolve => setTimeout(resolve, 10));
  const sentAt = performance.now() - start;
  const [busy, duration] = await Promise.all([
    addSample(observer, 2), importDuration
  ]);
  assert(sentAt < duration, "The second interaction missed the import window");
  console.log(`Session B add, idle: ${seconds(idle)} s\nSession B add, during import: ${seconds(busy)} s`);
  console.log(`Session A confirm to classified count: ${seconds(duration)} s (${rows} rows)`);
  console.log(`Session B sent its add ${seconds(sentAt)} s after confirmation.`);
} finally {
  for (const socket of sockets) socket.close();
}
