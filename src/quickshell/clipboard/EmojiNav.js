.pragma library

// Keyboard navigation for the clipboard's emoji grid.

var COLUMNS = 5;

// Index after moving one step in direction ("left", "right", "up", "down"), clamped to the grid.
// Moving down from a row above a shorter last row lands on the last item. -1 when the grid is empty.
function moveIndex(index, direction, count, columns) {
    if (count <= 0) return -1;
    var cols = columns > 0 ? columns : COLUMNS;
    var i = Math.min(Math.max(index, 0), count - 1);
    if (direction === "left") return Math.max(i - 1, 0);
    if (direction === "right") return Math.min(i + 1, count - 1);
    if (direction === "up") return i - cols >= 0 ? i - cols : i;
    if (direction === "down") {
        if (i + cols < count) return i + cols;
        var lastRow = Math.floor((count - 1) / cols);
        return Math.floor(i / cols) < lastRow ? count - 1 : i;
    }
    return i;
}
