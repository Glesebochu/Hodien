# 😄 Hodien (ሆዴን) – Your Personalized Humor Feed

Welcome to **Hodien** (*ሆዴን*) — a smart, multilingual humor retrieval system that learns what *you* find funny and delivers it straight to your feed. We blend the best of **NLP**, **Information Retrieval**, and **personalization** to bring you genuinely funny content from across social media 💬😂.

---

## 📱 What is Hodien?

**Hodien (ሆዴን)** is a mobile app powered by a smart backend that:

- 🤖 **Classifies** posts and comments as humorous or not
- 🧠 Builds your **humor profile** based on what *you* laugh at
- 🔍 Supports **keyword-based humor search**
- 📰 Generates a **personalized humor feed**
- 🎯 Updates itself with every reaction you give!

Built with ❤️ using **Flutter**, **Firebase**, and **Python**.


## 🧩 Project Structure

```plaintext
hodien/
├── frontend/          # Flutter app (Dart)
├── backend/           # Python modules (NLP, Search, Personalization)
│   ├── nlp_pipeline/              
│   ├── search_engine/             
│   ├── personalization/           
│   └── shared_utils/              
├── firebase/          # Firebase configs
├── docs/              # Diagrams, planning docs
├── README.md
└── .gitignore
```

Each backend module is fully isolated and owned by a dedicated team member:
- `nlp_pipeline/` – Humor classification and content filtering
- `search_engine/` – Custom-built inverted index & retrieval
- `personalization/` – Humor profile updates + feed re-ranking
- `shared_utils/` – Shared models, constants, helpers

---

## 🚀 Features

✨ Powered by:
- 🧠 Humor classifier (NLP)
- 🔎 Custom IR system (inverted index)
- ❤️ Personalized feed ranking
- 🌐 Firebase Authentication
- 🌍 Supports Amharic and English input
- 📤 Reactions and feedback-driven learning loop

## 🛠️ Tech Stack

| Layer        | Tech |
|--------------|------|
| **Frontend** | Flutter (Dart) |
| **Backend**  | Python 3.10 |
| **Auth & DB**| Firebase (Firestore + Auth) |
| **IR Engine**| Custom-built (Python) |
| **Data**     | Twitter & Facebook (scraped + filtered) |

## 🧪 How to Run Locally

### 📱 Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

### 🧠 Backend (Python)
```bash
cd backend/nlp_pipeline
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt

# Run full pipeline
python scripts/run_pipeline.py
```

---

## 👨‍👩‍👧‍👦 Team Members

This project is proudly built by a 4-person student team:

- 🧠 NLP & Humor Classifier – *Zelalem Amare*
- 🔍 IR & Search – *Yanet Abraham*
- 🎯 Personalization & Feed – *Intisar Mohammed*
- 📱 UI & User System – *Dawit Nebretu*

---

## 📄 License

This project is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).  
You are free to use, modify, and distribute this project with proper attribution.  
Please cite or reference the project if you build upon it. 🙏


## 🌟 Show Some Love

If you like this project, star it ⭐, fork it 🍴, or give it a shoutout!

---

**Built with laughter, data, and good vibes 🤝**  
**– The Hodien (ሆዴን) Team**
