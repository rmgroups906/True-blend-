# 🚀 Deployment Guide – Spring Boot + Python AI + Nginx

## 1. Upload Code to Server

From your **local machine** (Windows PowerShell or Git Bash):

```powershell
# Upload Java backend
scp -r "C:/Users/thevi/OneDrive/Documents/prj-true/True_blend-main/ai_analyzer" root@157.173.218.232:/root/

# Upload Python AI model
scp -r "C:/Users/thevi/OneDrive/Documents/prj-true/True_blend-main/ai_model_python" root@157.173.218.232:/root/

# Upload deployment scripts
scp "C:/Users/thevi/OneDrive/Documents/prj-true/True_blend-main/*.sh" root@157.173.218.232:/root/
```

---

## 2. Connect to Server

```bash
ssh root@157.173.218.232
```

---

## 3. Verify Files

Inside the server:

```bash
cd /root
ls
```

You should see:
```
ai_analyzer
ai_model_python
deploy-server.sh
deploy-app.sh
deploy-ai-model.sh
setup-nginx.sh
```

---

## 4. Make Scripts Executable

```bash
chmod +x *.sh
```

---

## 5. Run Deployment Steps

```bash
# Install system dependencies (Java, MySQL, Nginx, etc.)
./deploy-server.sh

# Deploy Spring Boot backend
./deploy-app.sh

# Deploy Python AI service
./deploy-ai-model.sh

# Configure reverse proxy with Nginx
./setup-nginx.sh
```

---

## 6. Configure Environment Variables

Edit `.env` file for AI service:

```bash
nano /root/ai_model_python/.env
```

Add your Gemini API Key:

```
GEMINI_API_KEY=your_actual_key_here
```

Save & exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

---

## 7. Restart AI Model Service

```bash
sudo systemctl restart ai-model
```

---

## 8. Verify Services

Check backend (Spring Boot):
```bash
sudo systemctl status ai-analyzer
```

Check AI model:
```bash
sudo systemctl status ai-model
```

Check Nginx:
```bash
sudo systemctl status nginx
```

---

## 9. Test Application

- Access your backend through the server IP:  
  ```
  http://157.173.218.232
  ```
- Or if a domain is mapped → `http://yourdomain.com`

---

## ✅ Done!  
Now your Spring Boot + Python AI + Nginx stack is live.
