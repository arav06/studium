from pymongo import MongoClient
from datetime import datetime
import os
import threading
import time
from json import dumps, loads
import requests
from flask import jsonify, Flask, request
from google import genai
from bson import ObjectId
from dotenv import load_dotenv
import os
from pathlib import Path

load_dotenv()

app = Flask(__name__)

client = MongoClient(f"mongodb+srv://{os.getenv("MONGO_USERNAME")}:{os.getenv("MONGO_PASSWORD")}@{os.getenv("MONGO_HOST")}/", tls=True, tlsAllowInvalidCertificates=True) 
gemini = genai.Client(api_key="AIzaSyDDHRyFZiUd4BUQV8fOXHy6PxYLF7CHlak")
db = client["dartmouth"]  
users_col = db["users"]
events_col = db["events"]
requests_collection = db["inviteRequests"]
sessions_collection = db["sessions"]

@app.route("/")
def main():
    return "up",200

@app.route("/add_user", methods=["POST"])
def add_user():
    data = request.json
    email = data.get("email")
    name = data.get("name")
    school = data.get("school")
    phone = data.get("phoneNumber")
    study = data.get("study")
    password = data.get("password")
    
    email = data["email"].strip().lower()

    if users_col.find_one({"email": email}):
        return jsonify({"error": "Email already registered"}), 403

    new_user = {
        "email": email,
        "name": data["name"].strip(),
        "school": data["school"].strip(),
        "phone": data.get("phoneNumber"),
        "study": data.get("study").strip(),
        "password":data.get("password").strip()
    }

    inserted_doc = users_col.insert_one(new_user)
    new_user["_id"] = str(inserted_doc.inserted_id)
    print(new_user)
    return jsonify({"message": "User added successfully", "user": new_user}), 201

@app.route("/add_study_event",methods=['POST'])
def add_study_event():
    data = request.json
    email = data.get("email")
    location = data.get("location")
    startTime = data.get("startTime")
    duration = data.get("duration")
    chapter = data.get("chapter")

    new_study_event = {
    "email": str(data.get("email", "")).strip(),
    "name": str(data.get("name", "")).strip(),
    "school": str(data.get("school", "")).strip(),
    "chapter": str(data.get("chapter", "")).strip(),
    "location": str(data.get("location", "")).strip(),
    "duration": str(data.get("duration", "")).strip(),
    "startTime": str(data.get("startTime", "")).strip()
      }

    inserted_doc = events_col.insert_one(new_study_event)
    new_study_event["sid"] = str(inserted_doc.inserted_id)
    print(new_study_event)
    return "added", 201

@app.route("/view_study_events",methods=['GET'])
def view_study_events():
    email = request.args.get("email")
    topic = request.args.get("topic")
    user_school = request.args.get("school")

    matching_docs = list(events_col.find({"school": user_school}))

    response = gemini.models.generate_content(model="gemini-2.0-flash", 
    contents=f"""
      {matching_docs}

      from this list, do any of the entries' study field seem related to {topic}. sort the list based on how closely the study field of each is related to {topic}

      dont gimme any code or anything. just the list. nothing else. GIMME THE LIST ONLY. USE DOUBLE QUOTES IN FOR THE KEYS AND VALUES. CHANGE THE OBJECT ID QUOTES TO DOUBLE QUOTES TOO. NOT SINGLE QUOTES
      
      CHANGE EVERYTHING TO DOUBLE QUOTES. NO SINGLE QUOTES ANYWHERE. CHANGE THE OBJECT ID FIELD TO DOUBLE QUOTES

      COMPLETELY ELIMINATE SINGLE QUOTES

      DONT USE MARKDOWN. ONLY THE ARRAY NOTHING ELSE AND ONLY DOUBLE QUOTES
      """)

    sorted_list = response.text

    return loads(sorted_list)

@app.route("/send_study_request", methods=["POST"])
def send_study_request():
    data = request.json
    email1 = data.get("fromEmail")
    email2 = data.get("toEmail")
    sid = data.get("sid")
    response = "n"
    new_request = {
    "fromEmail": str(data.get("fromEmail", "")).strip(),
    "toEmail": str(data.get("toEmail", "")).strip(),
    "sid": str(data.get("sid", "")).strip(),
    "response":"n"
    }
    inserted_doc = requests_collection.insert_one(new_request)
    return jsonify({"message": "Request added successfully"}), 201

@app.route("/view_invites", methods=["GET"])
def view_invites():
    email = request.args.get("email")

    if not email:
        return 404

    invite = requests_collection.find_one({"toEmail": email, "response": "n"}) 
    
    if not invite:
        return jsonify({"message": "No invites found for this email."}), 404

    from_email = invite.get("fromEmail")
    sid = invite.get("sid")

    user = users_col.find_one({"email": from_email})
    name = user.get("name")

    return jsonify({"fromEmail": from_email, "name": name, "sid": sid}), 200

@app.route("/accept_invite", methods=["GET"])
def accept_invite():
    sid = request.args.get("sid") 
    invite = requests_collection.find_one({"sid": sid})

    if not invite:
        return jsonify({"message": "Invite not found for this email and session ID."}), 404

    result = requests_collection.update_one(
        {"_id": invite["_id"]},
        {"$set": {"response": "y"}} 
    )

    if result.matched_count == 0:
        return jsonify({"message": "Failed to update the invite."}), 500

    return jsonify({"message": "Invite accepted successfully."}), 200

@app.route("/check_invite_status", methods=["GET"])
def check_invite_status():
    email = request.args.get("email")  
    invite = requests_collection.find_one({"fromEmail": email})

    if not invite:
        return jsonify({"message": "Invite not found."}), 404

    response = invite.get("response")
    
    if response == "y":
        sessions_collection.insert_one(invite)

    return jsonify({"response": response}), 200

@app.route("/retrieve_session", methods=["GET"])
def retrieve_session():
    email = request.args.get("email")

    query = {
    "$or": [
        {"toEmail": email},
        {"fromEmail": email}
        ]
    }
    result = sessions_collection.find_one(query)

    sid = ObjectId(result["sid"])

    query = {"_id": sid}    

    result = events_col.find_one(query)

    name1 = users_col.find_one({"email": email}, {"_id": 0, "name": 1})["name"]
    name2 = result["name"]

    location = result["location"]

    room = location.split(",")[0]
    loc = location.split(",")[1]

    return jsonify({
        "location":loc,
        "room":room,
        "topic":result["chapter"],
        "name1":name1,
        "name2":name2
    })

UPLOAD_FOLDER = Path("./uploads")
UPLOAD_FOLDER.mkdir(exist_ok=True)
@app.route('/upload_notes', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "No file part", 400

    file = request.files['file']

    if file.filename == '':
        return "No selected file", 400

    if file and file.filename.endswith('.pdf'):
        # Save to uploads directory
        filepath = UPLOAD_FOLDER / file.filename
        file.save(filepath)

        try:
            # Upload to Gemini
            sample_pdf = client.files.upload(file=filepath)
            response = client.models.generate_content(
                model="gemini-2.0-flash",
                contents=["Give me a summary of this pdf file.", sample_pdf],
            )
            summary = response.text
        finally:
            # Clean up the uploaded file
            os.remove(filepath)

        return summary, 200

if __name__ == "__main__":
    app.run(port=8000,debug=True)
