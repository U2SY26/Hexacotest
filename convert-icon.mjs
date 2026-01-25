import sharp from 'sharp';
import fs from 'fs';
import path from 'path';

const svgPath = 'hexaco-icon-wire.svg';
const outputPath = 'hexaco_mobile/assets/branding/app_icon.png';

// Read SVG and convert to PNG at 1024x1024 for high quality
const svgBuffer = fs.readFileSync(svgPath);

await sharp(svgBuffer)
  .resize(1024, 1024)
  .png()
  .toFile(outputPath);

console.log(`Converted ${svgPath} to ${outputPath}`);

// Also create splash version
const splashPath = 'hexaco_mobile/assets/branding/splash.png';
await sharp(svgBuffer)
  .resize(512, 512)
  .png()
  .toFile(splashPath);

console.log(`Created splash: ${splashPath}`);
