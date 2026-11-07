#!/usr/bin/env nix
/*
#!nix shell --ignore-environment .#cacert .#nodejs --command node
*/
// @ts-check
import assert from "node:assert/strict";
import * as crypto from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";

/** @typedef {"x86_64-linux" | "aarch64-linux"} Platform */
/** @typedef {{ version: string; sources: Record<Platform, { url: string; sha256: string; }> }} Information */

const manifestRes = await fetch("https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/manifest/latest-x64-linux.yml");
const manifestText = await manifestRes.text();

const version = /^version:\s*([\d.]+)/m.exec(manifestText)?.[1] ?? "";
assert(version !== "", `Could not parse Antigravity version from manifest:\n${manifestText}`);

const baseUrlMatch = /(https:\/\/storage\.googleapis\.com\/antigravity-public\/antigravity-hub\/[^/\s]+)\/linux-x64\//.exec(manifestText);
assert(baseUrlMatch !== null, `Could not parse base download URL from manifest:\n${manifestText}`);
const baseUrl = baseUrlMatch[1];

async function getSource(/** @type {"linux-x64" | "linux-arm"} */ targetArch) {
  const url = `${baseUrl}/${targetArch}/Antigravity.tar.gz`;
  const response = await fetch(url);
  assert(response.ok, `Failed to fetch ${url}: ${response.status} ${response.statusText}`);
  const buffer = Buffer.from(await response.arrayBuffer());
  const sha256 = crypto.createHash("sha256").update(buffer).digest("hex");
  return { url, sha256 };
}

/** @type {Information['sources']} */
const sources = {
  "x86_64-linux": await getSource("linux-x64"),
  "aarch64-linux": await getSource("linux-arm"),
};

/** @type {Information} */
const information = { version, sources };
fs.writeFileSync(path.join(import.meta.dirname, "./information.json"), JSON.stringify(information, null, 2) + "\n", "utf-8");
console.log(`[update] Updating Antigravity complete, version: ${version}`);

