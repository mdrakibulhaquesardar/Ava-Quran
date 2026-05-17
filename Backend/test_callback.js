const https = require('https');

// The deployed backend URL
const targetUrl = 'https://avaqurania.mvp.bd/auth/quran/callback?code=fake_test_code_12345';

console.log(`Testing callback URL: ${targetUrl}...`);

https.get(targetUrl, (res) => {
  let data = '';

  console.log(`Status Code: ${res.statusCode}`);
  
  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('Response Body:');
    try {
      const jsonResponse = JSON.parse(data);
      console.log(JSON.stringify(jsonResponse, null, 2));
    } catch (e) {
      console.log(data);
    }
    
    if (res.statusCode >= 200 && res.statusCode < 300) {
      console.log('\n✅ Success! The endpoint is reachable and returning a valid HTTP status.');
    } else if (res.statusCode === 400 || res.statusCode === 500) {
      console.log('\n✅ The endpoint is reachable! (It rejected the fake code as expected because it is invalid)');
    } else if (res.statusCode === 404) {
      console.log('\n❌ Error: The endpoint was not found (404). Is the server running and accessible?');
    } else {
      console.log('\n⚠️ Reached the server, but got an unexpected status code.');
    }
  });

}).on('error', (err) => {
  console.error('\n❌ Network Error: Could not reach the server.');
  console.error(err.message);
});
