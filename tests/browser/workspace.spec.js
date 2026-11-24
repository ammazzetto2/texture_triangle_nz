import { test, expect } from "playwright/test";

async function openWorkspace(page) {
  await page.goto("/");
  await expect(page.locator("#compositionTotal")).toContainText("100%");
  await expect(page.locator("#ternaryPlot img")).toBeVisible();
  await expect(page.getByRole("tab", { name: "Triangle", exact: true })).toHaveAttribute("aria-selected", "true");
}
async function addSample(page, name) {
  await page.locator("#sampleName").fill(name);
  await page.getByRole("button", { name: "Add sample", exact: true }).click();
  await expect(page.locator("#sampleFeedback")).toHaveText(`Added ${name}`);
}

test("fresh sessions open on Triangle and keyboard entry reaches Results", async ({ page }) => {
  await openWorkspace(page);
  await page.keyboard.press("Tab");
  await expect(page.getByRole("link", { name: "Skip to texture workspace" })).toBeFocused();
  await page.keyboard.press("Enter");
  await expect(page.locator("#classification-workspace")).toBeFocused();
  await page.locator("#sampleName").focus();
  await page.keyboard.type("Keyboard sample");
  for (const value of ["50", "25", "25"]) {
    await page.keyboard.press("Tab");
    await page.keyboard.press("ControlOrMeta+A");
    await page.keyboard.type(value);
  }
  await page.keyboard.press("Tab");
  await expect(page.getByText("Calculate a remaining percentage", { exact: true })).toBeFocused();
  await page.keyboard.press("Tab");
  await expect(page.getByRole("button", { name: "Add sample", exact: true })).toBeFocused();
  await page.keyboard.press("Enter");
  await expect(page.locator("#sampleFeedback")).toHaveText("Added Keyboard sample");
  await page.getByRole("button", { name: "Show all 1 samples", exact: true }).click();
  await expect(page.getByRole("tab", { name: "Results", exact: true })).toHaveAttribute("aria-selected", "true");
  await expect(page.locator(".sample-results tbody tr")).toHaveCount(1);
  await expect(page.locator(".sample-results")).toContainText("Keyboard sample");
});

test("CSV mapping blocks invalid data and imports reviewed rows", async ({ page }) => {
  await openWorkspace(page);
  await page.getByRole("tab", { name: "CSV upload", exact: true }).click();
  await page.locator("#fileUpload").setInputFiles({
    name: "mapped.csv", mimeType: "text/csv",
    buffer: Buffer.from("Name,Sand,Silt,Wrong,Clay\n001,50,25,20,25\nField B,90,5,10,5\n"),
  });
  await page.locator("#map_soil").selectOption("Name");
  await page.locator("#map_clay").selectOption("Wrong");
  await expect(page.locator("#uploadStatus")).toContainText("Rows needing correction: 2 of 2");
  await expect(page.locator("#confirmImportBtn")).toBeDisabled();
  await page.locator("#map_clay").selectOption("Clay");
  await expect(page.locator("#uploadStatus")).toHaveText("2 rows are ready to import.");
  await expect(page.locator("#confirmImportBtn")).toBeEnabled();
  await page.locator("#confirmImportBtn").click();
  await expect(page.locator("#sampleFeedback")).toContainText("Imported 2 sample(s)");
  await page.getByRole("tab", { name: "Results", exact: true }).click();
  await expect(page.locator(".sample-results tbody tr")).toHaveCount(2);
  await expect(page.locator(".sample-results")).toContainText("001");
  await expect(page.locator(".sample-results")).toContainText("Field B");
});

test("editing saves results and returns keyboard focus to the row", async ({ page }) => {
  await openWorkspace(page);
  await addSample(page, "Original");
  await page.getByRole("tab", { name: "Results", exact: true }).click();
  await page.getByRole("button", { name: "Edit sample 1 Original", exact: true }).click();
  await expect(page.locator("#editSampleName")).toBeFocused();
  await page.locator("#editSampleName").fill("Renamed");
  await page.locator("#editSand").fill("40");
  await page.locator("#editSilt").fill("35");
  await page.getByRole("button", { name: "Save changes", exact: true }).click();
  await expect(page.locator("#editSampleName")).toBeHidden();
  await expect(page.locator(".sample-results")).toContainText("Renamed");
  await expect(page.locator(".sample-results tbody tr").first()).toContainText("40");
  await expect(page.getByRole("button", { name: "Edit sample 1 Renamed", exact: true })).toBeFocused();
});

test("320px workspace has usable controls and no page overflow", async ({ page }) => {
  await page.setViewportSize({ width: 320, height: 640 });
  await openWorkspace(page);
  await addSample(page, "Mobile sample");
  await page.getByRole("link", { name: "View results", exact: true }).click();
  await expect(page.getByRole("tab", { name: "Results", exact: true })).toHaveAttribute("aria-selected", "true");
  await expect(page.locator(".sample-results")).toContainText("Mobile sample");
  await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
  await page.getByRole("link", { name: "Add samples", exact: true }).click();
  await expect(page.locator("#sampleName")).toBeInViewport();
  const logo = await page.locator(".sidebar-logo").boundingBox();
  expect(logo.width).toBeGreaterThan(0);
  expect(logo.x + logo.width).toBeLessThanOrEqual(320);
});

test("shared positions expose every sample name", async ({ page }) => {
  await openWorkspace(page);
  await addSample(page, "First");
  await addSample(page, "Second");
  await expect(page.getByRole("button", { name: "Shared positions 1", exact: true })).toBeVisible();
  await page.locator("#showSampleLabels").uncheck();
  await page.getByRole("button", { name: "Shared positions 1", exact: true }).click();
  await expect(page.locator("#coincidentGroup")).toContainText("2 samples");
  await expect(page.locator("#coincidentSamples")).toContainText("First");
  await expect(page.locator("#coincidentSamples")).toContainText("Second");
  await page.getByRole("button", { name: "Close", exact: true }).click();
  await expect(page.locator("#coincidentGroup")).toBeHidden();
  await page.screenshot({ path: "/tmp/soil-shared-positions.png" });
});

test("nearby samples and long names render with arranged labels", async ({ page }) => {
  await openWorkspace(page);
  const longName = "A very long sample name near the sand corner of the triangle";
  await page.getByRole("tab", { name: "CSV upload", exact: true }).click();
  await page.locator("#fileUpload").setInputFiles({
    name: "nearby.csv", mimeType: "text/csv",
    buffer: Buffer.from(`soil,sand,silt,clay\nField A,50,25,25\nField B,51,24,25\nField C,49,26,25\n${longName},99,0,1\n`),
  });
  await expect(page.locator("#uploadStatus")).toHaveText("4 rows are ready to import.");
  await page.locator("#confirmImportBtn").click();
  await expect(page.locator("#sampleFeedback")).toContainText("Imported 4 sample(s)");
  await page.getByRole("tab", { name: "Results", exact: true }).click();
  await page.getByRole("button", { name: `View sample 4 ${longName}`, exact: true }).click();
  await expect(page.locator("#plotSelection")).toContainText(longName);
  await expect(page.getByLabel("Arrange sample labels", { exact: true })).toBeChecked();
  const chart = page.locator("#ternaryPlot img");
  await expect(chart).toHaveAttribute("alt", /with 4 sample points/);
  await expect.poll(() => chart.evaluate(image => image.complete && image.naturalWidth > 0)).toBe(true);
  await page.locator("#ternaryPlot").screenshot({ path: "/tmp/soil-arranged-desktop.png" });
  const desktopSource = await chart.getAttribute("src");
  await page.setViewportSize({ width: 320, height: 640 });
  await expect(chart).not.toHaveAttribute("src", desktopSource);
  await expect.poll(() => chart.evaluate(image => image.complete && image.naturalWidth > 0)).toBe(true);
  await expect(page.locator(".shiny-output-error")).toHaveCount(0);
  await expect(page.locator("#plotSelection")).toContainText(longName);
  await page.locator("#ternaryPlot").screenshot({ path: "/tmp/soil-arranged-mobile.png" });
});

test("saved workspace restores a fresh session and supports full undo", async ({ page, context }, testInfo) => {
  await openWorkspace(page);
  await addSample(page, "Saved sample");
  await page.locator("#dataset").selectOption("USDA");
  await page.locator("#showSampleLabels").uncheck();
  await page.locator("#avoidLabelOverlap").uncheck();
  await page.getByRole("tab", { name: "Results", exact: true }).click();
  await page.getByRole("button", { name: "View sample 1 Saved sample", exact: true }).click();
  await expect(page.locator("#plotSelection")).toContainText("Saved sample");
  await page.getByRole("button", { name: "Workspace", exact: true }).click();
  const downloadReady = page.waitForEvent("download");
  await page.locator("#downloadWorkspace").click();
  const saved = testInfo.outputPath("workspace.json");
  await (await downloadReady).saveAs(saved);

  const restored = await context.newPage();
  await openWorkspace(restored);
  await addSample(restored, "Previous sample");
  await restored.getByRole("button", { name: "Workspace", exact: true }).click();
  await restored.locator("#workspaceUpload").setInputFiles(saved);
  await expect(restored.locator("#workspacePreview")).toContainText("1 sample(s)");
  await restored.getByRole("button", { name: "Restore workspace", exact: true }).click();
  await expect(restored.locator("#workspaceUpload")).toBeHidden();
  await expect(restored.locator("#dataset")).toHaveValue("USDA");
  await expect(restored.locator("#showSampleLabels")).not.toBeChecked();
  await expect(restored.locator("#avoidLabelOverlap")).not.toBeChecked();
  await expect(restored.locator("#plotSelection")).toContainText("Saved sample");
  await restored.getByRole("tab", { name: "Results", exact: true }).click();
  await expect(restored.locator(".sample-results")).toContainText("Saved sample");
  await expect(restored.locator(".sample-results")).not.toContainText("Previous sample");

  await restored.locator("#undoDataBtn").click();
  await expect(restored.locator("#dataset")).toHaveValue("New Zealand");
  await expect(restored.locator("#showSampleLabels")).toBeChecked();
  await expect(restored.locator("#avoidLabelOverlap")).toBeChecked();
  await expect(restored.locator(".sample-results")).toContainText("Previous sample");
  await restored.setViewportSize({ width: 320, height: 640 });
  await restored.getByRole("button", { name: "Workspace", exact: true }).click();
  await expect(restored.locator("#workspaceUpload")).toBeAttached();
  await expect.poll(() => restored.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
  await restored.locator("#workspaceUpload").setInputFiles({
    name: "broken.json", mimeType: "application/json", buffer: Buffer.from("{broken"),
  });
  await expect(restored.locator("#workspaceError")).toContainText("Could not read");
  await expect(restored.locator("#restoreWorkspace")).toHaveCount(0);
  await restored.getByRole("button", { name: "Close", exact: true }).click();
  await expect(restored.locator(".sample-results")).toContainText("Previous sample");
  await restored.close();
});
