// Attach to this dialog while it is open. Shiny removes it after it closes.
document.addEventListener("shown.bs.modal", event => {
  const modal = event.target;
  const title = modal.querySelector("#edit-sample-title");
  if (!title) return;

  modal.setAttribute("aria-labelledby", title.id);
  modal.querySelector("#editSampleName").focus();
  modal.addEventListener("hidden.bs.modal", () => {
    const table = document.querySelector(".results-table");
    // Saving can rebuild the table or move the edited row off the current page.
    const button = table.querySelector(`[data-action="edit"][data-row="${title.dataset.row}"]`);
    (button || table).focus();
  }, {once: true});
});
