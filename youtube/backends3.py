from flask import Flask, jsonify, request
from flask_cors import CORS
import boto3
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)
CORS(app)  # Allow cross-origin requests

# ---------------- AWS CONFIG ----------------
AWS_ACCESS_KEY_ID = ""      # your access key
AWS_SECRET_ACCESS_KEY = ""  # your secret key
AWS_REGION = "us-east-1"                        # your AWS region
BUCKET_NAME = ""     # your bucket name
PREFIX = "song/"                                # folder/prefix inside the bucket

# ---------------- BOTO3 CLIENT ----------------
s3 = boto3.client(
    "s3",
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_REGION,
)

# ---------------- ROUTES ----------------
@app.route("/videos", methods=["GET"])
def get_videos():
    """
    Fetch video files from S3 and return signed URLs
    """
    try:
        response = s3.list_objects_v2(Bucket=BUCKET_NAME, Prefix=PREFIX)

        if "Contents" not in response:
            return jsonify({"message": "No videos found"}), 404

        video_urls = []
        for obj in response["Contents"]:
            key = obj["Key"]

            if key.lower().endswith((".mp4", ".webm", ".mov")):
                url = s3.generate_presigned_url(
                    "get_object",
                    Params={"Bucket": BUCKET_NAME, "Key": key},
                    ExpiresIn=3600,  # URL expires in 1 hour
                )
                video_urls.append({"file": key, "url": url})

        return jsonify(video_urls), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/upload", methods=["POST"])
def upload_video():
    """
    Upload a new video file to S3
    """
    try:
        if "file" not in request.files:
            return jsonify({"error": "No file part in request"}), 400

        file = request.files["file"]

        if file.filename == "":
            return jsonify({"error": "No file selected"}), 400

        filename = secure_filename(file.filename)
        s3_key = PREFIX + filename

        # Upload directly from memory
        s3.upload_fileobj(file, BUCKET_NAME, s3_key)

        return jsonify({"message": f"Uploaded {filename} successfully"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ---------------- MAIN ----------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
