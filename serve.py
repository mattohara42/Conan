#!/usr/bin/env python3
"""Dev server that disables caching, so edits to config.js / modules show up on
every reload. Use this instead of `python3 -m http.server` while iterating:

    python3 serve.py           # serves ./ on http://localhost:8080
    python3 serve.py 9000      # custom port
"""
import http.server, socketserver, sys

port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080

class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, must-revalidate")
        super().end_headers()

with socketserver.TCPServer(("", port), NoCacheHandler) as httpd:
    print(f"Serving http://localhost:{port}  (no-cache)")
    httpd.serve_forever()
