
import os
import yt_dlp

from flask import Flask, request, send_file, jsonify
from YoutubeMP3Converter import YouTubeMP3


app = Flask(__name__)

@app.route('/convert', methods=['POST'])
def convert_to_mp3():
    print("called on convert branch of url")
    try:
        data = request.get_json()
        video_url = data.get('url')
        
        # Check if URL was provided
        if not video_url:
            return jsonify({"error": "No URL provided"}), 400

        # Call YouTubeMP3 function to download and convert
        filename = YouTubeMP3(inputURL=video_url)
        
        # Check if YouTubeMP3 returned a valid filename
        if not filename:
            return jsonify({"error": "Failed to retrieve filename from YouTubeMP3 function"}), 500
        
        # Check if file was successfully created
        if not os.path.exists(filename):
            return jsonify({"error": "File not found after conversion"}), 500
        
        # Send the MP3 file as an attachment if everything is successful
        print("\n\nabout to send file back to IPhone\n\n")
        return send_file(filename, as_attachment=True)

    except ValueError as e:
        # Handle cases where YouTubeMP3 throws a ValueError, e.g., invalid URL format
        return jsonify({"error": f"Invalid URL: {str(e)}"}), 400

    except Exception as e:
        # Generic error handling for unexpected issues
        return jsonify({"error": f"An unexpected error occurred: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
