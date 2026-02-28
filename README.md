# KALOR.AI: BMI & Healthy Lifestyle App 🥗🏃‍♂️

**KALOR.AI** is a Flutter-based mobile application designed to promote healthier living through AI-driven insights. The app combines face-based BMI estimation, calorie tracking from food photos, and personalized healthy recipe generation into a single, seamless platform.

---

## 🚀 Key Features

* **BMI Estimation via Face Photos:** Uses a CNN model to predict BMI from face images preprocessed with OpenCV.
* **Image-to-Calorie Estimation:** Estimates calorie values directly from food photos to simplify meal tracking.
* **Healthy Recipe Generator:** Provides nutritious and balanced meal suggestions to support healthier eating habits.
* **Mobile Optimization:** Powered by **TensorFlow Lite (TFLite)** for high performance and fast inference on mobile devices.
* **User History & Profile:** Tracks consumption history and provides personalized daily calorie goals.

---

## 🛠️ Technical Architecture



The application is built with a clear separation of concerns between the UI and backend logic:

* **Frontend:** Flutter (Compatible with Android & iOS).
* **Business Logic:** Dart Backend.
* **Machine Learning:** TensorFlow Lite (TFLite) for BMI and Calorie models.
* **Image Processing:** OpenCV.
* **Local Storage:** SharedPreferences for saving user data and history.

---

## 📊 Performance & Results

* **BMI Estimation Accuracy:** Achieved ~**92%** on Training and ~**89%** on Validation sets.
* **Inference Speed:** Fast processing at **200-300 ms** per photo.
* **User Feedback:** Users found the interface simple, fast, and effective for mindful eating.

---

## ⚙️ Setup & Configuration

To run this project locally, please note the following requirements:

1.  **Firebase Integration:** You must connect the app to your own Firebase instance.
2.  **API Keys:** * Create `/lib/api_key.dart` and `/lib/firebase_options.dart`.
    * You **must** add your own API keys to these files; otherwise, the app will not function correctly.
3.  **Dependencies:**
    ```bash
    flutter pub get
    ```

---

## 🎥 Demo & Links

* **Demo Video:** [Watch on YouTube](https://youtu.be/XOhhvTfEeAE)
* **Source Code:** [GitHub Repository](https://github.com/tucagg/kalori_app_flutter)
