import { writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { FontAssetType, generateFonts } from "fantasticon";

const toolDir = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(toolDir, "../..");
const fontsDir = resolve(rootDir, "assets/fonts");

const result = await generateFonts({
  inputDir: resolve(rootDir, "assets/icons"),
  outputDir: fontsDir,
  name: "Icons",
  fontTypes: [FontAssetType.TTF],
  assetTypes: [],
});

const icons = Object.fromEntries(
  Object.entries(result.codepoints).map(([name, codepoint]) => [
    name,
    String.fromCodePoint(codepoint),
  ]),
);

// TODO change it to update qml file to decrease fileload dependancy uptime

const json = JSON.stringify(icons, null, 2).replace(
  /[\uE000-\uF8FF]/g,
  (character) => `\\u${character.codePointAt(0)!.toString(16).toUpperCase().padStart(4, "0")}`,
);

await writeFile(resolve(fontsDir, "Icons.json"), `${json}\n`);

console.log(
  `Generated ${Object.keys(result.codepoints).length} icons in assets/fonts/Icons.ttf and assets/fonts/Icons.json`,
);
