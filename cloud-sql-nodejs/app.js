require('dotenv').config();
const mysql = require('mysql2');
const pool = require('./db');
const { encrypt, decrypt } = require('./encryption');

const connection = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
});

module.exports = connection;

const storeData = async (data) => {
    const connection = await pool.getConnection();
    try {
        const { encryptedData, iv } = encrypt(data);
        const query = 'INSERT INTO secure_table (encrypted_data, iv) VALUES (?, ?)';
        await connection.execute(query, [encryptedData, iv]);
        console.log('Data stored securely.');
    } catch (err) {
        console.error('Error storing data:', err);
    } finally {
        connection.release();
    }
};

const fetchData = async (id) => {
    const connection = await pool.getConnection();
    try {
        const query = 'SELECT encrypted_data, iv FROM secure_table WHERE id = ?';
        const [rows] = await connection.execute(query, [id]);

        if (rows.length > 0) {
            const { encrypted_data, iv } = rows[0];
            const decryptedData = decrypt(encrypted_data, iv);
            console.log('Decrypted Data:', decryptedData);
        } else {
            console.log('No data found.');
        }
    } catch (err) {
        console.error('Error fetching data:', err);
    } finally {
        connection.release();
    }
};

(async () => {
    await storeData('Sensitive Information');
    await fetchData(1);
})();

const { Logging } = require('@google-cloud/logging');
const logging = new Logging();

const log = logging.log('my-app-log');
const metadata = { resource: { type: 'global' } };

function logInfo(message) {
    const entry = log.entry(metadata, { message });
    log.write(entry).catch(console.error);
}

logInfo('App started');

// Write Queries: Use the primary pool.
// Read Queries: Use the replica pool.
const primaryPool = mysql.createPool({
  host: '34.71.6.59', 
  user: 'root',
  password: 'password',
  database: 'security_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

const replicaPool = mysql.createPool({
  host: '34.134.162.64', 
  user: 'root',
  password: 'password',
  database: 'security_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

function executeWriteQuery(query, params) {
  return new Promise((resolve, reject) => {
    primaryPool.query(query, params, (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
}

function executeReadQuery(query, params) {
  return new Promise((resolve, reject) => {
    replicaPool.query(query, params, (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
}

// Example Write Read Usage
async function exampleWriteReadQuery() {
  try {
    // Write operation
    await executeWriteQuery('INSERT INTO secure_table (encrypted_data, iv) VALUES (?, ?)', ['data', 'iv1234']);
    console.log('Write query executed.');

    // Read operation
    const rows = await executeReadQuery('SELECT * FROM secure_table');
    console.log('Read query results:', rows);
  } catch (err) {
    console.error('Error executing query:', err);
  }
}

exampleWriteReadQuery();
