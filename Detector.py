from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import face_recognition
import os

app = Flask(__name__)
CORS(app)

# Cargar las imágenes de referencia y extraer sus características
reference_folder = "C:\\Users\\manuc\\Universidad\\IOTRobotica\\Recognition-Face\\Imagenes"
known_encodings = []
known_labels = []

def preprocess_image(image):
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return gray_image

def extract_features(image):
    rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    boxes = face_recognition.face_locations(rgb_image, model="hog")
    if len(boxes) > 0:
        return face_recognition.face_encodings(rgb_image, known_face_locations=boxes)[0]
    else:
        return None

for filename in os.listdir(reference_folder):
    reference_image = cv2.imread(os.path.join(reference_folder, filename))
    if reference_image is not None:
        encoding = extract_features(reference_image)
        if encoding is not None:
            known_encodings.append(encoding)
            known_labels.append(os.path.splitext(filename)[0])
    else:
        print(f"Failed to load image: {filename}")

@app.route('/check_face', methods=['POST'])
def check_face():
    try:
        file = request.files['image']
        image = face_recognition.load_image_file(file)
        face_encodings = face_recognition.face_encodings(image)

        if len(face_encodings) > 0:
            face_encoding = face_encodings[0]
            distances = face_recognition.face_distance(known_encodings, face_encoding)
            recognized = np.any(distances <= 0.6)
            if recognized:
                best_match_index = np.argmin(distances)
                recognized_name = known_labels[best_match_index]
                return jsonify({"success": True, "message": "User found", "name": recognized_name})
            else:
                return jsonify({"success": False, "message": "User not found"})
        else:
            return jsonify({"success": False, "message": "No face detected"})
    except Exception as e:
        return jsonify({"success": False, "message": f"Error processing image: {str(e)}"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
