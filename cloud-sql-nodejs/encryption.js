const crypto = require('crypto');

const algorithm = 'aes-256-cbc';
const key = crypto.randomBytes(32); // Generate a secure key
const initVector = crypto.randomBytes(16);

const encrypt = (text) => {
    const cipher = crypto.createCipherinitVector(algorithm, key, initVector);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return { encryptedData: encrypted, initVector: initVector.toString('hex') };
};

const decrypt = (encryptedData, initVector) => {
    const decipher = crypto.createDecipherinitVector(algorithm, key, Buffer.from(initVector, 'hex'));
    let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
};

module.exports = { encrypt, decrypt };
