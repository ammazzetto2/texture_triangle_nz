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
