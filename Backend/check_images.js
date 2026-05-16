const fs = require('fs');
const https = require('https');

const filePath = 'src/feed/feed.service.ts';
const content = fs.readFileSync(filePath, 'utf-8');

// Regex to find unsplash URLs
const regex = /https:\/\/images\.unsplash\.com\/photo-[a-zA-Z0-9-]+/g;
const urls = [...new Set(content.match(regex))];

console.log(`Found ${urls.length} unique image URLs to check...`);

let invalidUrls = [];
let checked = 0;

function checkUrl(url) {
  return new Promise((resolve) => {
    https.get(url, (res) => {
      // Unsplash might redirect or return 200
      if (res.statusCode >= 200 && res.statusCode < 400) {
        resolve({ url, valid: true });
      } else {
        resolve({ url, valid: false, status: res.statusCode });
      }
    }).on('error', (e) => {
      resolve({ url, valid: false, status: e.message });
    });
  });
}

async function run() {
  for (const url of urls) {
    const result = await checkUrl(url);
    checked++;
    process.stdout.write(`\rChecking ${checked}/${urls.length}... `);
    if (!result.valid) {
      console.log(`\n❌ Invalid: ${result.url} (Status: ${result.status})`);
      invalidUrls.push(result.url);
    }
  }
  
  console.log('\n--- Final Report ---');
  if (invalidUrls.length === 0) {
    console.log('✅ All image links are valid!');
  } else {
    console.log(`❌ Found ${invalidUrls.length} invalid links:`);
    invalidUrls.forEach(url => console.log(url));
  }
}

run();
