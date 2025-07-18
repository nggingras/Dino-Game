#pragma once

#include <winsock2.h>
#include <ws2tcpip.h>
#include <wincrypt.h>
#include <string>
#include <vector>
#include <functional>

#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "crypt32.lib")

class SimpleWebSocketServer {
private:
    SOCKET serverSocket;
    std::function<void(const std::string&)> messageCallback;
    std::function<void()> connectCallback;
    std::function<void()> disconnectCallback;
    bool running;

    // Base64 encoding
    std::string base64Encode(const unsigned char* data, size_t length) {
        const std::string base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        std::string result;
        int i = 0;
        int j = 0;
        unsigned char char_array_3[3];
        unsigned char char_array_4[4];
        
        while (length--) {
            char_array_3[i++] = *(data++);
            if (i == 3) {
                char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
                char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
                char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
                char_array_4[3] = char_array_3[2] & 0x3f;
                
                for (i = 0; i < 4; i++)
                    result += base64_chars[char_array_4[i]];
                i = 0;
            }
        }
        
        if (i) {
            for (j = i; j < 3; j++)
                char_array_3[j] = '\0';
            
            char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
            char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
            char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
            char_array_4[3] = char_array_3[2] & 0x3f;
            
            for (j = 0; j < i + 1; j++)
                result += base64_chars[char_array_4[j]];
            
            while ((i++ < 3))
                result += '=';
        }
        
        return result;
    }

    // SHA1 using Windows CryptoAPI
    std::string calculateSHA1(const std::string& input) {
        HCRYPTPROV hProv = 0;
        HCRYPTHASH hHash = 0;
        BYTE hash[20];
        DWORD hashLen = 20;
        
        if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT)) {
            return "";
        }
        
        if (!CryptCreateHash(hProv, CALG_SHA1, 0, 0, &hHash)) {
            CryptReleaseContext(hProv, 0);
            return "";
        }
        
        if (!CryptHashData(hHash, (BYTE*)input.c_str(), (DWORD)input.length(), 0)) {
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            return "";
        }
        
        if (!CryptGetHashParam(hHash, HP_HASHVAL, hash, &hashLen, 0)) {
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            return "";
        }
        
        CryptDestroyHash(hHash);
        CryptReleaseContext(hProv, 0);
        
        return base64Encode(hash, hashLen);
    }

    // Parse HTTP headers
    std::string getHeaderValue(const std::string& request, const std::string& header) {
        size_t pos = request.find(header + ": ");
        if (pos == std::string::npos) return "";
        
        pos += header.length() + 2;
        size_t end = request.find("\r\n", pos);
        if (end == std::string::npos) return "";
        
        return request.substr(pos, end - pos);
    }

    // Handle WebSocket handshake
    bool handleHandshake(SOCKET clientSocket, const std::string& request) {
        std::string key = getHeaderValue(request, "Sec-WebSocket-Key");
        if (key.empty()) return false;
        
        std::string acceptKey = key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
        std::string acceptValue = calculateSHA1(acceptKey);
        
        std::string response = 
            "HTTP/1.1 101 Switching Protocols\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            "Sec-WebSocket-Accept: " + acceptValue + "\r\n"
            "\r\n";
        
        return send(clientSocket, response.c_str(), (int)response.length(), 0) != SOCKET_ERROR;
    }

    // Send WebSocket frame
    bool sendFrame(SOCKET socket, const std::string& message, int opcode = 0x01) {
        std::vector<uint8_t> frame;
        
        // FIN + opcode
        frame.push_back(0x80 | opcode);
        
        // Payload length
        if (message.length() < 126) {
            frame.push_back(message.length());
        } else if (message.length() < 65536) {
            frame.push_back(126);
            frame.push_back((message.length() >> 8) & 0xFF);
            frame.push_back(message.length() & 0xFF);
        } else {
            frame.push_back(127);
            for (int i = 7; i >= 0; i--) {
                frame.push_back((message.length() >> (i * 8)) & 0xFF);
            }
        }
        
        // Payload
        frame.insert(frame.end(), message.begin(), message.end());
        
        return send(socket, (char*)frame.data(), (int)frame.size(), 0) != SOCKET_ERROR;
    }

    // Parse WebSocket frame
    struct WebSocketFrame {
        bool fin;
        int opcode;
        bool masked;
        uint64_t payloadLength;
        std::vector<uint8_t> payload;
    };

    WebSocketFrame parseFrame(const std::vector<uint8_t>& data) {
        WebSocketFrame frame;
        if (data.size() < 2) return frame;
        
        frame.fin = (data[0] & 0x80) != 0;
        frame.opcode = data[0] & 0x0F;
        frame.masked = (data[1] & 0x80) != 0;
        
        uint64_t payloadLength = data[1] & 0x7F;
        int headerSize = 2;
        
        if (payloadLength == 126) {
            if (data.size() < 4) return frame;
            payloadLength = (data[2] << 8) | data[3];
            headerSize = 4;
        } else if (payloadLength == 127) {
            if (data.size() < 10) return frame;
            payloadLength = 0;
            for (int i = 0; i < 8; i++) {
                payloadLength = (payloadLength << 8) | data[2 + i];
            }
            headerSize = 10;
        }
        
        if (frame.masked) {
            if (data.size() < headerSize + 4 + payloadLength) return frame;
            uint8_t mask[4] = {data[headerSize], data[headerSize + 1], data[headerSize + 2], data[headerSize + 3]};
            headerSize += 4;
            
            frame.payload.resize(payloadLength);
            for (uint64_t i = 0; i < payloadLength; i++) {
                frame.payload[i] = data[headerSize + i] ^ mask[i % 4];
            }
        } else {
            if (data.size() < headerSize + payloadLength) return frame;
            frame.payload.assign(data.begin() + headerSize, data.begin() + headerSize + payloadLength);
        }
        
        return frame;
    }

    // Handle client connection
    void handleClient(SOCKET clientSocket) {
        char buffer[4096];
        std::vector<uint8_t> messageBuffer;
        bool handshakeCompleted = false;
        
        while (running) {
            int bytesReceived = recv(clientSocket, buffer, sizeof(buffer), 0);
            if (bytesReceived <= 0) break;
            
            if (!handshakeCompleted) {
                std::string request(buffer, bytesReceived);
                if (request.find("GET /") == 0 && request.find("Upgrade: websocket") != std::string::npos) {
                    if (handleHandshake(clientSocket, request)) {
                        handshakeCompleted = true;
                        if (connectCallback) connectCallback();
                        continue;
                    } else {
                        break;
                    }
                }
            } else {
                messageBuffer.insert(messageBuffer.end(), buffer, buffer + bytesReceived);
                
                while (messageBuffer.size() >= 2) {
                    WebSocketFrame frame = parseFrame(messageBuffer);
                    if (frame.payload.empty()) break;
                    
                    // Remove processed frame from buffer
                    size_t frameSize = 2;
                    if (frame.masked) frameSize += 4;
                    if (frame.payload.size() < 126) {
                        frameSize += frame.payload.size();
                    } else if (frame.payload.size() < 65536) {
                        frameSize += 2 + frame.payload.size();
                    } else {
                        frameSize += 8 + frame.payload.size();
                    }
                    
                    if (messageBuffer.size() < frameSize) break;
                    messageBuffer.erase(messageBuffer.begin(), messageBuffer.begin() + frameSize);
                    
                    // Handle message
                    if (frame.opcode == 0x01) { // Text frame
                        std::string message(frame.payload.begin(), frame.payload.end());
                        if (messageCallback) messageCallback(message);
                    } else if (frame.opcode == 0x08) { // Close frame
                        sendFrame(clientSocket, "", 0x08);
                        goto cleanup;
                    } else if (frame.opcode == 0x09) { // Ping frame
                        sendFrame(clientSocket, "", 0x0A); // Send pong
                    }
                }
            }
        }
        
    cleanup:
        closesocket(clientSocket);
        if (disconnectCallback) disconnectCallback();
    }

public:
    SimpleWebSocketServer() : serverSocket(INVALID_SOCKET), running(false) {}
    
    ~SimpleWebSocketServer() {
        stop();
    }
    
    bool start(int port, const std::string& host = "127.0.0.1") {
        WSADATA wsaData;
        if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) return false;
        
        serverSocket = socket(AF_INET, SOCK_STREAM, 0);
        if (serverSocket == INVALID_SOCKET) {
            WSACleanup();
            return false;
        }
        
        int opt = 1;
        setsockopt(serverSocket, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt));
        
        sockaddr_in serverAddr;
        serverAddr.sin_family = AF_INET;
        serverAddr.sin_addr.s_addr = inet_addr(host.c_str());
        serverAddr.sin_port = htons(port);
        
        if (bind(serverSocket, (sockaddr*)&serverAddr, sizeof(serverAddr)) == SOCKET_ERROR) {
            closesocket(serverSocket);
            WSACleanup();
            return false;
        }
        
        if (listen(serverSocket, SOMAXCONN) == SOCKET_ERROR) {
            closesocket(serverSocket);
            WSACleanup();
            return false;
        }
        
        running = true;
        
        // Accept connections in a separate thread
        std::thread([this]() {
            while (running) {
                sockaddr_in clientAddr;
                int clientAddrSize = sizeof(clientAddr);
                SOCKET clientSocket = accept(serverSocket, (sockaddr*)&clientAddr, &clientAddrSize);
                
                if (clientSocket != INVALID_SOCKET) {
                    std::thread(&SimpleWebSocketServer::handleClient, this, clientSocket).detach();
                }
            }
        }).detach();
        
        return true;
    }
    
    void stop() {
        running = false;
        if (serverSocket != INVALID_SOCKET) {
            closesocket(serverSocket);
            serverSocket = INVALID_SOCKET;
        }
        WSACleanup();
    }
    
    void setMessageCallback(std::function<void(const std::string&)> callback) {
        messageCallback = callback;
    }
    
    void setConnectCallback(std::function<void()> callback) {
        connectCallback = callback;
    }
    
    void setDisconnectCallback(std::function<void()> callback) {
        disconnectCallback = callback;
    }
    
    bool sendMessage(const std::string& message) {
        // This would need to be implemented to send to the current client
        // For simplicity, we'll store the client socket and send to it
        return true;
    }
}; 