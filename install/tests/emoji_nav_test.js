#!/usr/bin/env node
// Tests for src/quickshell/clipboard/EmojiNav.js
// Run: node install/tests/emoji_nav_test.js
"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const file = path.resolve(__dirname, "../../src/quickshell/clipboard/EmojiNav.js");
const source = fs.readFileSync(file, "utf8").replace(/^\s*\.pragma library\s*$/m, "");
const nav = {};
vm.runInNewContext(source, nav);

const tests = {
    moves_by_one_and_by_row() {
        assert.equal(nav.moveIndex(0, "right", 20, 5), 1);
        assert.equal(nav.moveIndex(7, "down", 20, 5), 12);
        assert.equal(nav.moveIndex(7, "up", 20, 5), 2);
        assert.equal(nav.moveIndex(7, "left", 20, 5), 6);
    },
    stays_in_bounds() {
        assert.equal(nav.moveIndex(0, "left", 20, 5), 0);
        assert.equal(nav.moveIndex(2, "up", 20, 5), 2);
        assert.equal(nav.moveIndex(19, "right", 20, 5), 19);
        assert.equal(nav.moveIndex(17, "down", 20, 5), 17);
    },
    down_on_last_partial_row_goes_to_last_item() {
        assert.equal(nav.moveIndex(14, "down", 17, 5), 16);
    },
    empty_grid() {
        assert.equal(nav.moveIndex(0, "down", 0, 5), -1);
    },
    default_columns() {
        assert.equal(nav.COLUMNS, 5);
    },
};

let failed = 0;
for (const [name, fn] of Object.entries(tests)) {
    try {
        fn();
    } catch (e) {
        failed++;
        console.error(`FAIL ${name}: ${e.message}`);
    }
}
if (failed) process.exit(1);
console.log("ok");
