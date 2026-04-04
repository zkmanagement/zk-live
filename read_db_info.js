const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const dbPath = path.join(__dirname, 'db', 'streamflow.db');
const db = new sqlite3.Database(dbPath);

console.log('--- START DATA ---');
db.all('SELECT channel_name FROM youtube_channels', (err, rows) => {
  if (err) {
    console.error('Error channels:', err);
  } else {
    console.log('Channels:', rows.map(r => r.channel_name).join(', '));
  }
  
  db.all('SELECT username FROM users', (err, users) => {
    if (err) {
      console.error('Error users:', err);
    } else {
      console.log('Users:', users.map(u => u.username).join(', '));
    }
    console.log('--- END DATA ---');
    db.close();
  });
});
