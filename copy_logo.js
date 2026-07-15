const fs = require('fs');
const path = require('path');

const src = "C:\\Users\\MAHIR\\.gemini\\antigravity-ide\\brain\\977fd3f2-2fca-4755-bfab-241f00da8ce3\\media__1781775761129.jpg";
const destJpg = "c:\\RR CREATION\\giftswaleApp\\assets\\images\\logo.jpg";
const destPng = "c:\\RR CREATION\\giftswaleApp\\assets\\images\\logo.png";

try {
  fs.copyFileSync(src, destJpg);
  console.log('Successfully copied to logo.jpg');
  fs.copyFileSync(src, destPng);
  console.log('Successfully copied to logo.png');
} catch (err) {
  console.error('Error copying file:', err);
}
