# IronClaw Custom Railway Template (Nvidia NIM & OpenRouter Destekli)

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/SLQJV1?referralCode=V-zTuH)

Bu proje, orijinal [nearai/ironclaw](https://github.com/nearai/ironclaw) tabanlı görev yöneticisi, yapay zeka asistanı ve bellek sistemini **Railway üzerinde tek tıkla çalışabilen profesyonel bir şablona (template)** dönüştürmek amacıyla oluşturulmuştur.

Özellikle **Nvidia NIM (Minimax) gibi harici LLM sağlayıcılarını** ve **OpenRouter üzerinden Failover (Yedek) LLM rotalamasını** sorunsuzca destekleyecek şekilde altyapısı özelleştirilmiştir.

---

## 🚀 Proje Nedir ve Ne İşe Yarar?

IronClaw; içerisinde chat, gelişmiş görev hafızası (memory), arka plan iş listeleri (jobs) ve otomasyon rutinleri barındıran kompleks bir yapay zeka asistanıdır. Normal şartlarda kendi donanımınızda veya lokal bir makinede çalışması için tasarlanmış olan bu sistem, doğrudan bulut servislerine (PaaS) deploy edilmek istendiğinde çeşitli port çakışmaları, interaktif kurulum (onboarding) hataları ve ağ iletişim sorunları çıkarır.

Bu proje (**ironclaw-custom-railway**), bu engellerin tamamını ortadan kaldırır. 
- Araya bir Caddy sunucu katmanı ekleyerek port sorunlarını çözer.
- Veritabanı ve uygulama arasına özel bir iç ağ kurar.
- **Nvidia NIM** gibi hızlı ve uygun maliyetli LLM hizmetlerini uygulamanın yerleşik OpenAI katmanlarına tüneleyerek muazzam bir esneklik sunar.

---

## 🛠 Neler Yaptık ve Sistemi Nasıl Geliştirdik?

Proje geliştirme sürecinde aşağıdaki devasa altyapı modifikasyonları gerçekleştirildi:

### 1. Özel LLM Sağlayıcı Entegrasyonu (Model Tiering)
Normalde IronClaw, standart API'lara bağımlıdır. Biz, özel çevre değişkenleri çevirici (`docker-entrypoint.sh`) katmanımız sayesinde, Railway üzerinden girilen **Nvidia NIM API** altyapısını (`integrate.api.nvidia.com`) ve Minimax modellerini tamamen doğal bir OpenAI sunucusuymuş gibi sisteme tanıttık. 
Ayrıca, birincil modelde hata veya kopma olursa sistemin saniyeler içinde doğrudan diğer modele geçmesini sağlayan **OpenRouter Failover** desteğini aktive ettik. 

### 2. Infrastructure as Code (railway.json)
Eskiden manuel olarak veritabanı kurup bağlamak gerekirken, repoya tam teşekküllü bir `railway.json` entegre ettik.
- Uygulama ayağa kalkarken otomatik olarak `pgvector` eklentisine sahip bir PostgreSQL sunucusu oluşturulur.
- İki konteyner birbiriyle dış dünyadan izole bir iç ağda (`postgres.railway.internal`) SSL sertifikası maliyeti olmadan süper hızlı haberleşir.
- Görev hafızası (vektörler) **PostgreSQL volume'üne** güvenli şekilde kaydedilir. IronClaw sunucusunun kendi kalıcı depolama yükü (volume) tamamen silinerek uygulama sıfır durumlu (stateless) hale getirilmiş, hız artırılmıştır.

### 3. Otomatik Şifre ve Güvenlik Yönetimi
IronClaw arayüz token'ı (`GATEWAY_AUTH_TOKEN`), sistemin veritabanı şifreleme anahtarı (`SECRETS_MASTER_KEY`) ve webhook entegrasyonu güvenliği (`HTTP_WEBHOOK_SECRET`) normalde kullanıcıyı zorlayan tanımlamalardır. Kurduğumuz Railway şablon mimarisi sayesinde uygulama yayınlandığı anda **tamamen rastgele ve kırılması imkansız 32-64 haneli şifreler otomatik olarak** generate edilir.

### 4. Non-Interactive Boot (Kendi Kendine Kurulum)
Kullanıcının terminalden onaylaması gereken `ONBOARD_COMPLETED=true` gibi işlemler sisteme gömüldü. Sistemin Public HTTP arayüzüne (8080) ve arka plan iş ağlarına (8081) portları ayrı ayrı bind edildi.

---

## 📖 Nasıl Kullanılır ve Deploy Edilir?

Projeyi çalıştırmak ve kullanmak son derece basittir:

### Adım 1: Railway Üzerinde Başlatma
1. Sayfanın en üstündeki **Deploy on Railway** butonuna tıklayın (veya projenin GitHub adresini manual olarak Railway üzerinden Deploy olarak seçin).
2. Railway sizden sadece API anahtarlarını isteyecektir. Diğer tüm karmaşık anahtarlar otomatik oluşturulur.

### Adım 2: Ortam Değişkenleri (Environment Variables)
Railway arayüzündeki Variables (Değişkenler) kısmındaki `Raw Editor` alanıyla direkt olarak aşağıdaki değerlerle düzenleyebilirsiniz: 

```env
DATABASE_URL=postgresql://${{postgres.POSTGRES_USER}}:${{postgres.POSTGRES_PASSWORD}}@postgres.railway.internal:5432/${{postgres.POSTGRES_DB}}?sslmode=disable
LLM_BACKEND=openai
OPENAI_API_BASE=https://integrate.api.nvidia.com/v1
OPENAI_MODEL_ID=minimaxai/minimax-m2.5
OPENAI_API_KEY=nvapi-(NVIDIA_API_ANAHTARINIZ)
LLM_FAILOVER_BACKEND=openai
LLM_FAILOVER_API_KEY=sk-or-(OPENROUTER_API_ANAHTARINIZ)
GATEWAY_AUTH_TOKEN=${{ secret(32) }}
SECRETS_MASTER_KEY=${{ secret(64) }}
HTTP_WEBHOOK_SECRET=${{ secret(32) }}
ONBOARD_COMPLETED=true
SANDBOX_ENABLED=false
PORT=8080
HTTP_HOST=0.0.0.0
HTTP_PORT=8081
```
*(Gerekli tüm `${{ secret }}` alanları deploy esnasında Railway tarafından otomatik şifrelere dönüştürülür.)*

### Adım 3: Kullanım
* Deploy işlemi onaylandıktan sonra Railway size bir domain atayacaktır.
* Bu domaine tıkladığınızda karşınıza IronClaw Portal ekranı gelir.
* Şifre kısmına, Railway arayüzünde otomatik oluşturulan **GATEWAY_AUTH_TOKEN** değerini kopyalayıp yapıştırabilirsiniz.
* Ve artık kendi vektör belleği olan, asistan yetenekli, yüksek performanslı ve Nvidia NIM hızlandırıcı desteli sisteminiz kullanıma hazırdır!

---

## 🏛️ Mimari Özet

* **Caddy Reverse Proxy:** Gelen http trafiklerini karşılayıp doğru IronClaw portlarına (UI/Webhook) yönlendirir.
* **docker-entrypoint.sh:** Uygulama başlamadan önce çalışıp sistemi yapılandırır ve UI'dan gelen `OPENAI_API_BASE` isteğini uygulamanın beklediği `OPENAI_BASE_URL` yapısına dinamik olarak adapte eder.
* **PostgreSQL (pgvector):** Railway iç ağında çalışan, kalıcı depolama sunan birincil hafıza merkezidir.

## Emeği Geçen / Referans
- Base Project: [nearai/ironclaw](https://github.com/nearai/ironclaw)
- Railway Optimizer & Documentation: [@algorytma](https://github.com/algorytma)
