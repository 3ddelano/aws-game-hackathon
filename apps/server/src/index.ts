import express from "express";
import { createServer } from "node:http";
import * as socketio from "socket.io";

  const app = express();
  const httpServer = createServer(app);
  const io = new socketio.Server(httpServer, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"],
    },
  });

io.on("connection", (socket) => {
  console.log(`New client connected ${socket.id}`);
  socket.on("disconnect", () => {
    console.log("Client disconnected");
  });
});

const PORT = process.env.SERVER_PORT ?? 3000;
httpServer.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
