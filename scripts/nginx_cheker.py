import os

nginx_dir = '/etc/nginx/conf.d/'
ssl_settings = {}

for file in os.listdir(nginx_dir):
    if file.endswith('.conf'):
        with open(os.path.join(nginx_dir, file), 'r') as f:
            content = f.read()
            # Look for ssl_certificate and ssl_certificate_key
            cert_line = [line for line in content.split('\n') if 'ssl_certificate' in line]
            key_line = [line for line in content.split('\n') if 'ssl_certificate_key' in line]
            if cert_line or key_line:
                print(f"SSL settings found in {file}:")
                print(cert_line + key_line)
                print("--------------------")
