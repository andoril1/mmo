import manage
import sys
import protocol
from twisted.python import log
from twisted.internet import reactor, task, ssl
from autobahn.twisted.websocket import WebSocketServerFactory


class GameFactory(WebSocketServerFactory):
    def __init__(self, hostname: str, port: int):
        self.protocol = protocol.GameServerProtocol
        super().__init__(f"wss://{hostname}:{port}")

        self.players: set[protocol.GameServerProtocol] = set()
        self.tickrate: int = 20
        tickloop = task.LoopingCall(self.tick)
        tickloop.start(1 / self.tickrate)  # 20 times per second

    def tick(self):
        for p in self.players:
            p.tick()

    # Override
    def buildProtocol(self, addr):
        p = super().buildProtocol(addr)
        self.players.add(p)
        return p


if __name__ == '__main__':
    log.startLogging(sys.stdout)

    certs_dir: str = f"{sys.path[0]}/certs/"
    contextFactory = ssl.DefaultOpenSSLContextFactory(certs_dir + "server.key", certs_dir + "server.crt")

    PORT: int = 8081
    factory = GameFactory('0.0.0.0', PORT)

    reactor.listenSSL(PORT, factory, contextFactory)
    reactor.run()
