#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <strings.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>

#define MY_PORT     9999
#define MAX_BUF     1024

int main() {
    int sockfd, clientfd;
    struct sockaddr_in self, client_addr;
    socklen_t addrlen = sizeof(client_addr);
    char buffer[MAX_BUF];

    // To create a socket for networking communication.
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1) {
        perror("Error creating socket");
        exit(EXIT_FAILURE);
    }

    // Initialize address/port structure
    bzero(&self, sizeof(self));
    self.sin_family = AF_INET;
    self.sin_port = htons(MY_PORT);
    self.sin_addr.s_addr = INADDR_ANY;

    // Bind the socket
    if (bind(sockfd, (struct sockaddr*)&self, sizeof(self)) == -1) {
        perror("Error binding");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    // Listen for incoming connections
    if (listen(sockfd, 40) == -1) {
        perror("Error listening");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    // Server runs continuously
    while (1) {
        // Accept an incoming connection
        clientfd = accept(sockfd, (struct sockaddr*)&client_addr, &addrlen);
        if (clientfd == -1) {
            perror("Error accepting connection");
            continue;  // Try accepting the next connection
        }

        printf("%s:%d connected\n", inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));

        // Print the received data from the client
        ssize_t read_bytes = read(clientfd, buffer, MAX_BUF);
        if (read_bytes == -1) {
            perror("Error reading from client");
        } else {
            printf("Got client message: %.*s\n", (int)read_bytes, buffer);
            // Send the same data back to the client
            if (write(clientfd, buffer, read_bytes) == -1) {
                perror("Error writing to client");
            }
        }

        // Close the data connection
        close(clientfd);
    }

    // Clean up
    close(sockfd);
    return 0;
}
