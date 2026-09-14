import http.server
import functools

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

handler = functools.partial(CORSRequestHandler, directory='docs')
http.server.test(HandlerClass=handler, port=8743)
