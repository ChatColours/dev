
#!/usr/bin/env python3
"""Serve a Luau project locally for rapid Roblox UI development."""

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


class DevHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def guess_type(self, path):
        if path.endswith((".luau", ".lua")):
            return "text/plain; charset=utf-8"
        return super().guess_type(path)


def main():
    parser = argparse.ArgumentParser(description="Serve an entire project folder over localhost")
    parser.add_argument("folder", nargs="?", default=".", help="Project folder (default: current folder)")
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()

    folder = Path(args.folder).expanduser().resolve()
    if not folder.is_dir():
        parser.error(f"Not a directory: {folder}")

    handler = partial(DevHandler, directory=str(folder))
    server = ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    print(f"Serving: {folder}")
    print(f"URL: http://127.0.0.1:{args.port}/")
    print("Press Ctrl+C to stop. Files are read fresh on every request.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server...")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()



# to use: python dev_server.py "C:\Users\You\MochaHub" --port 8000