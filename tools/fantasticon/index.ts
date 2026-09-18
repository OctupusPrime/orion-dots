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

const properties = Object.entries(result.codepoints).map(([name, codepoint]) => {
  const propertyName = name.replace(/-([a-z0-9])/g, (_, character: string) =>
    character.toUpperCase(),
  );
  const glyph = String.fromCodePoint(codepoint).replace(
    /[\s\S]/g,
    (character) => `\\u${character.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0")}`,
  );

  return `    readonly property string ${propertyName}: "${glyph}"`;
});

await writeFile(
  resolve(rootDir, "quickshell/common/Icons.qml"),
  `import QtQuick\n\nQtObject {\n${properties.join("\n")}\n}\n`,
);

console.log(
  `Generated ${properties.length} icons in assets/fonts/Icons.ttf and quickshell/common/Icons.qml`,
);
