import { defineConfig } from "playwright/test";

export default defineConfig({
  testDir: ".",
  testMatch: "*.spec.js",
  timeout: 60000,
  expect: { timeout: 15000 },
  workers: 1,
  use: {
    baseURL: "http://127.0.0.1:38765",
    browserName: "chromium",
    viewport: { width: 1440, height: 1000 },
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
  },
  webServer: {
    command: 'Rscript --vanilla -e \'source("R/dependencies.R"); ensure_project_dependencies(); shiny::runApp("soil_triangle.R", host="127.0.0.1", port=38765, launch.browser=FALSE)\'',
    cwd: "../..",
    url: "http://127.0.0.1:38765",
    timeout: 120000,
    reuseExistingServer: false,
  },
});
