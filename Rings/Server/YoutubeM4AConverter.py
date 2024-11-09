import yt_dlp
import os
import urllib3


def YouTubeM4A(inputURL: str):
    # Disable urllib3 warnings
    urllib3.disable_warnings()

    # Define the destination directory
    dest = os.path.expanduser("~/Desktop/BrodyCode/IosApp/Rings/Rings/Server/MusicFiles")
    os.makedirs(dest, exist_ok=True)  # Ensure the directory exists

    # Configure yt-dlp options
    ydl_opts = {
        'format': 'bestaudio/best',
        'outtmpl': os.path.join(dest, '%(title)s.%(ext)s'),
        'postprocessors': [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'm4a',
            'preferredquality': '256'
        }]
    }

    try:
        # Download the audio and extract metadata
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info_dict = ydl.extract_info(inputURL, download=True)
            file_path = ydl.prepare_filename(info_dict).replace('.webm', '.m4a')
            print("File path generated:", file_path)

        # Verify the file exists
        if os.path.exists(file_path):
            print("File successfully created:", file_path)
            return file_path
        else:
            print("File does not exist after processing.")
            return None

    except Exception as e:
        print(f"Error occurred: {e}")
        return None

