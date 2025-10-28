# FastAPI Deployment on GCP VM (Debian)

## 1️⃣ Create the VM
- Use GCP Console → Compute Engine → Create instance  
- Choose **Debian** as the OS  
- Note **internal & external IPs**  

---

## 2️⃣ Connect via SSH
- Open SSH in browser or via `gcloud compute ssh <instance-name>`  
- Update system and install basics:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 git
```

## 3️⃣ Install Docker

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
```


## 4️⃣ (Optional) Nginx + SSL

Install Nginx and Certbot:

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
sudo systemctl status nginx
```

Create Nginx config /etc/nginx/sites-available/fastapi:

```bash
server {
    listen 80;
    server_name <YOUR_DOMAIN_OR_EXTERNAL_IP>;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable and test config:

```bash
sudo ln -s /etc/nginx/sites-available/fastapi /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

(Optional SSL) Get Let’s Encrypt certificate:

```bash
sudo certbot --nginx -d <YOUR_DOMAIN>
sudo certbot renew --dry-run
```

## 5️⃣ Deploy the FastAPI app

Clone your repository:

```bash
git clone <REPOSITORY_URL>
cd <project-folder>
```

Build Docker image and run the container:

```bash
docker build -t fastapi-app . 
docker build --no-cache -t fastapi-app . #(to avoid cached data in Docker)
docker run -d -p 8080:8080 fastapi-app

# Optional for Nginx/SSL
docker run -d --name fastapi-app -p 127.0.0.1:8080:8080 fastapi-app
```
Test locally inside VM:

```bash
curl http://localhost:8080/health
```

## 6️⃣ Open Firewall

In GCP Console or via Cloud Shell:

```bash
gcloud compute firewall-rules create allow-fastapi-8080 \
    --allow tcp:8080 \
    --target-tags fastapi-server \
    --description="Allow external access to FastAPI on port 8080"

gcloud compute instances add-tags <INSTANCE_NAME> --tags fastapi-server --zone <ZONE>
```

## 7️⃣ Access your API

```bash
# Without SSL:
http://<EXTERNAL_IP>:8080/health

# With SSL (requires domain & Let’s Encrypt):
https://<YOUR_DOMAIN>/health
```


