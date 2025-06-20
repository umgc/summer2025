// db.js

const { Pool } = require('pg');


const pool = new Pool({
  user: 'postgres',
  host: 'careconnect-db.cbw6u68qs0cv.us-east-2.rds.amazonaws.com',
  database: 'careconnect',
  password: '828798boM',
  port: 5432,
  ssl: {
    rejectUnauthorized: false, // Allow self-signed certs if needed
  }
});

module.exports = pool;
