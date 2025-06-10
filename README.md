# AT-Emulator Docker

[![Docker Build](https://github.com/ioleksiy/docker-at-emulator/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ioleksiy/docker-at-emulator/actions/workflows/docker-build.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/ioleksiy/at-emulator)](https://hub.docker.com/r/ioleksiy/at-emulator)

Docker container for [AT-Emulator](https://github.com/celersms/AT-Emulator) - A virtual AT command emulator for testing and development of applications that use AT commands.

## Features

- Multi-architecture support (linux/amd64, linux/arm64, linux/arm/v7)
- Configurable via environment variables
- Easy to use with various clients (minicom, nodejs, java, etc.)
- Automatic builds on GitHub Actions

## Quick Start

```bash
docker run -d -p 8000:8000 --name at-emulator yourusername/at-emulator
```

## Configuration

Environment variables:

- `PORT`: Port to listen on (default: 8000)
- `WORKERS`: Number of worker threads (default: 4, max: 99)
- `MAX_CONNECTIONS`: Maximum number of concurrent connections (default: 10, 0 for unlimited)

## Examples

### Using telnet

```bash
# Connect to the emulator using telnet
telnet localhost 8000

# Or using netcat
nc localhost 8000
```

### Using Node.js

```javascript
const net = require('net');

const HOST = process.env.AT_EMULATOR_HOST || 'localhost';
const PORT = process.env.AT_EMULATOR_PORT || 8000;

console.log(`Connecting to AT Emulator at ${HOST}:${PORT}...`);

const client = new net.Socket();

client.connect(PORT, HOST, () => {
  console.log('Connected to AT Emulator');
  
  // Send AT command
  client.write('AT\r\n');
});

client.on('data', (data) => {
  console.log(`<< ${data.toString().trim()}`);
  
  // Example: Send another command after receiving response
  if (data.toString().includes('OK')) {
    setTimeout(() => {
      console.log('>> AT+CGMI');
      client.write('AT+CGMI\r\n');
    }, 1000);
    return console.log('Error on write: ', err.message);
  }
  console.log('AT command sent');
});
```

### Using Java (with jSerialComm)

```java
import java.io.*;
import java.net.*;

public class ATEmulatorTest {
    public static void main(String[] args) {
        String host = System.getenv().getOrDefault("AT_EMULATOR_HOST", "localhost");
        int port = Integer.parseInt(System.getenv().getOrDefault("AT_EMULATOR_PORT", "8000"));
        
        try (Socket socket = new Socket(host, port);
             PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
             BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
             BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in))) {
            
            System.out.println("Connected to AT Emulator at " + host + ":" + port);
            
            // Start a thread to read responses
            new Thread(() -> {
                try {
                    String response;
                    while ((response = in.readLine()) != null) {
                        System.out.println("<< " + response);
                    }
                } catch (IOException e) {
                    System.err.println("Error reading from server: " + e.getMessage());
                }
            }).start();
            
            // Read commands from console and send to emulator
            String userInput;
            System.out.print(">> ");
            while ((userInput = stdIn.readLine()) != null) {
                out.println(userInput);
                System.out.print(">> ");
            }
            
        } catch (UnknownHostException e) {
            System.err.println("Don't know about host " + host);
            System.exit(1);
        } catch (IOException e) {
            System.err.println("Couldn't get I/O for the connection to " + host);
            System.exit(1);
        }
    }
}
```

## Building Locally

```bash
# Build for current architecture
docker build -t at-emulator .

# Build for multiple architectures
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t yourusername/at-emulator:latest --push .

# Run the container
docker run -d -p 8000:8000 --name at-emulator at-emulator

# Test with telnet
telnet localhost 8000
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [AT-Emulator](https://github.com/celersms/AT-Emulator) - The original AT command emulator created by [Victor Celer](https://www.celersms.com/org/vceler.htm)
- [Docker Multi-Arch Builds](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/)

## Maintainer

- Oleksii Dmytryk ([@ioleksiy](https://github.com/ioleksiy))
