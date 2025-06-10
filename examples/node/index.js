const net = require('net');
const readline = require('readline');

const HOST = process.env.AT_EMULATOR_HOST || 'localhost';
const PORT = parseInt(process.env.AT_EMULATOR_PORT || '8000');

console.log(`Connecting to AT Emulator at ${HOST}:${PORT}...`);

const client = new net.Socket();
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  prompt: '>> '
});

// Connect to the AT Emulator
client.connect(PORT, HOST, () => {
  console.log('Connected to AT Emulator');
  rl.prompt();
  
  // Send initial AT command
  client.write('AT\r\n');
  console.log('>> AT');
});

// Handle incoming data
client.on('data', (data) => {
  const response = data.toString().trim();
  if (response) {
    console.log(`<< ${response}`);
    
    // Example: Send AT+CGMI after receiving OK from AT
    if (response.includes('OK')) {
      setTimeout(() => {
        client.write('AT+CGMI\r\n');
        console.log('>> AT+CGMI');
      }, 1000);
    }
  }
});

// Handle connection close
client.on('close', () => {
  console.log('Connection closed');
  process.exit(0);
});

// Handle errors
client.on('error', (err) => {
  console.error('Connection error:', err.message);
  process.exit(1);
});

// Read commands from console and send to emulator
rl.on('line', (line) => {
  if (line.trim().toLowerCase() === 'exit') {
    client.end();
    rl.close();
  } else {
    client.write(`${line}\r\n`);
    console.log(`>> ${line}`);
    rl.prompt();
  }
}).on('close', () => {
  console.log('Exiting...');
  client.end();
  process.exit(0);
});

// Handle process termination
process.on('SIGINT', () => {
  console.log('\nDisconnecting...');
  client.end();
  rl.close();
});
