const axios = require('axios');
const axiosRetry = require('axios-retry');

console.log('axiosRetry:', axiosRetry);
try {
  axiosRetry(axios, { retries: 3 });
  console.log('axiosRetry initialized successfully');
} catch (error) {
  console.error('Error initializing axiosRetry:', error.message);
}