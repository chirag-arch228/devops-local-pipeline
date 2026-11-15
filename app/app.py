from http.server import HTTPServer, BaseHTTPRequestHandler

REQUEST_COUNT = 0

class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        global REQUEST_COUNT
        if self.path == '/':
            REQUEST_COUNT += 1
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b"Hello from Local DevOps Pipeline! Status: Healthy\n")
        elif self.path == '/metrics':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            metrics = f"""# HELP http_requests_total Total HTTP requests handled
# TYPE http_requests_total counter
http_requests_total {REQUEST_COUNT}
# HELP app_up Application status indicator
# TYPE app_up gauge
app_up 1
"""
            self.wfile.write(metrics.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found\n")

    def log_message(self, format, *args):
        return

def run(server_class=HTTPServer, handler_class=MetricsHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Starting local metrics web server on port {port}...")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()

if __name__ == '__main__':
    run()
