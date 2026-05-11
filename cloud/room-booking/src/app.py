from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        
        response = {
            "service": "room-booking",
            "version": os.getenv("APP_VERSION", "1.0.0"),
            "status": "healthy",
            "project": "Smart Office 2.0"
        }
        
        self.wfile.write(json.dumps(response).encode())
    
    def log_message(self, format, *args):
        pass  # Logs muted for demo

if __name__ == "__main__":
    print("🚀 Room Booking Service starting on port 8080...")
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
