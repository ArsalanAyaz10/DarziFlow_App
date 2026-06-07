const sharp = require('sharp');
const fs = require('fs');

async function convert() {
  try {
    await sharp('../assets/images/Darksplash.svg')
      .resize(1024, 1024, { fit: 'contain', background: { r: 255, g: 255, b: 255, alpha: 0 } })
      .png()
      .toFile('../assets/images/logo_converted.png');
    console.log('Successfully converted SVG to PNG');
  } catch (err) {
    console.error('Error converting SVG:', err);
  }
}

convert();
