const { setGlobalOptions, https } = require('firebase-functions/v2');
const axios = require('axios');
const axiosRetry = require('axios-retry').default;
const NodeCache = require('node-cache');
require('dotenv').config();

setGlobalOptions({ region: 'asia-south1' });

const cache = new NodeCache({ stdTTL: 600 });

axiosRetry(axios, {
  retries: 3,
  retryDelay: (retryCount) => retryCount * 1000,
  retryCondition: (error) => error.response?.status >= 500 || error.code === 'ECONNABORTED',
});

const OPENWEATHER_API_KEY = process.env.OPENWEATHER_API_KEY;
if (!OPENWEATHER_API_KEY) {
  console.error('OpenWeather API key is not configured. Set it in .env or using: firebase functions:config:set openweather.api_key="your-api-key"');
  throw new Error('OpenWeather API key is not configured');
}

const OPENWEATHER_GEOCODE_URL = 'https://api.openweathermap.org/geo/1.0/direct';
const OPENWEATHER_ONECALL_URL = 'https://api.openweathermap.org/data/3.0/onecall';
const OPENWEATHER_AIR_POLLUTION_URL = 'http://api.openweathermap.org/data/2.5/air_pollution';

exports.getWeather = https.onCall({ timeoutSeconds: 60 }, async (request) => {
  const city = request.data.city || 'Ghaziabad';
  const units = 'metric';
  const cacheKey = `${city}-${units}`;

  const cachedData = cache.get(cacheKey);
  if (cachedData) {
    console.log('Returning cached data for', cacheKey);
    return cachedData;
  }

  try {
    const geoResponse = await axios.get(OPENWEATHER_GEOCODE_URL, {
      params: {
        q: city,
        appid: OPENWEATHER_API_KEY,
        limit: 1,
      },
    });

    if (!geoResponse.data || geoResponse.data.length === 0) {
      throw new https.HttpsError('not-found', 'City not found');
    }

    const { lat, lon } = geoResponse.data[0];

    const weatherResponse = await axios.get(OPENWEATHER_ONECALL_URL, {
      params: {
        lat,
        lon,
        appid: OPENWEATHER_API_KEY,
        units,
        exclude: 'minutely',
      },
    });

    // Fetch air pollution data
    const airPollutionResponse = await axios.get(OPENWEATHER_AIR_POLLUTION_URL, {
      params: {
        lat,
        lon,
        appid: OPENWEATHER_API_KEY,
      },
    });

    const weatherData = weatherResponse.data;
    const airPollutionData = airPollutionResponse.data;
    const aqi = airPollutionData?.list?.[0]?.main?.aqi; // AQI value (1-5 scale)

    // Map AQI value to a descriptive category
    let aqiCategory;
    switch (aqi) {
      case 1:
        aqiCategory = 'Good';
        break;
      case 2:
        aqiCategory = 'Fair';
        break;
      case 3:
        aqiCategory = 'Moderate';
        break;
      case 4:
        aqiCategory = 'Poor';
        break;
      case 5:
        aqiCategory = 'Very Poor';
        break;
      default:
        aqiCategory = 'Unknown';
    }

    const result = {
      data: {
        ...weatherData,
        aqi: aqi, // Add AQI value
        aqiCategory: aqiCategory, // Add AQI category
      },
      error: null,
    };
    cache.set(cacheKey, result);
    return result;
  } catch (error) {
    console.error('Error fetching weather data for city', city, error.message, error.response?.data);
    throw new https.HttpsError('internal', `Failed to fetch weather data: ${error.message}`);
  }
});

exports.getMapTileUrls = https.onCall((request) => {
  return {
    wind: `http://tile.openweathermap.org/map/wind/{z}/{x}/{y}.png?appid=${OPENWEATHER_API_KEY}`,
    precipitation: `http://tile.openweathermap.org/map/precipitation/{z}/{x}/{y}.png?appid=${OPENWEATHER_API_KEY}`,
    temperature: `http://tile.openweathermap.org/map/temp/{z}/{x}/{y}.png?appid=${OPENWEATHER_API_KEY}`,
  };
});