#!/usr/bin/env python3
import http.server
import socketserver
import json
import os
import urllib.parse
from http import HTTPStatus

PORT = 8000
KEY_FILE = os.path.expanduser("~/.gemini_key")
CONFIG_FILE = os.path.expanduser("~/c64-os/config.json")
COMMANDS_FILE = os.path.expanduser("~/c64-os/commands.json")

class C64RequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data.decode('utf-8'))
        except json.JSONDecodeError:
            self.send_error(HTTPStatus.BAD_REQUEST, "Invalid JSON")
            return

        parsed_path = urllib.parse.urlparse(self.path)
        
        if parsed_path.path == '/api/save_key':
            self.handle_save_key(data)
        elif parsed_path.path == '/api/save_config':
            self.handle_save_config(data)
        elif parsed_path.path == '/api/save_commands':
            self.handle_save_commands(data)
        elif parsed_path.path == '/api/exec':
            self.handle_exec(data)
        else:
            self.send_error(HTTPStatus.NOT_FOUND, "Endpoint not found")

    def do_GET(self):
        # Override to serve index.html for root, or specific API gets
        parsed_path = urllib.parse.urlparse(self.path)
        if parsed_path.path == '/api/commands':
             self.handle_get_commands()
             return
        
        super().do_GET()

    def handle_save_key(self, data):
        provider = data.get('provider', 'gemini')
        key = data.get('key', '')
        
        if not key:
            self.send_response(HTTPStatus.BAD_REQUEST)
            self.end_headers()
            return

        # Simple logic: Just save to the standard key file for now
        # Future: support multiple files based on provider
        if provider.lower() == 'gemini':
            with open(KEY_FILE, 'w') as f:
                f.write(key)
                
        self.send_response(HTTPStatus.OK)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok", "provider": provider}).encode())

    def handle_save_config(self, data):
        # Save theme or other settings
        os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
        with open(CONFIG_FILE, 'w') as f:
            json.dump(data, f)
        
        self.send_response(HTTPStatus.OK)
        self.end_headers()
        self.wfile.write(b'{"status": "saved"}')

    def handle_save_commands(self, data):
        os.makedirs(os.path.dirname(COMMANDS_FILE), exist_ok=True)
        with open(COMMANDS_FILE, 'w') as f:
            json.dump(data, f, indent=2)
            
        self.send_response(HTTPStatus.OK)
        self.end_headers()
        self.wfile.write(b'{"status": "saved"}')

    def handle_get_commands(self):
        if os.path.exists(COMMANDS_FILE):
             with open(COMMANDS_FILE, 'r') as f:
                 content = f.read()
        else:
             content = '[]'
        
        self.send_response(HTTPStatus.OK)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(content.encode())

    def handle_exec(self, data):
        # SECURITY WARNING: This allows executing arbitrary commands.
        # Strict validation or whitelisting should be added for production.
        cmd = data.get('cmd')
        if cmd:
            print(f"Executing: {cmd}")
            # subprocess.Popen(cmd, shell=True) # Uncomment to enable real execution
            
        self.send_response(HTTPStatus.OK)
        self.end_headers()
        self.wfile.write(b'{"status": "executed"}')

if __name__ == "__main__":
    # Ensure serving from the correct directory if running standalone
    # web_dir = os.path.expanduser("~/c64-os")
    # if os.path.exists(web_dir):
    #    os.chdir(web_dir)
        
    with socketserver.TCPServer(("", PORT), C64RequestHandler) as httpd:
        print(f"Serving c64-os Kiosk on port {PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            pass
