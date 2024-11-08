import yt_dlp
import os


# Note: Script won't work unless you have ffmpeg and ffprobe installed on your system


def YouTubeM4A(inputURL: str):
    # Define the destination directory
    dest = os.path.expanduser("~/Desktop/BrodyCode/IosApp/Rings/Rings/Server/MusicFiles")
    
    # Ensure the destination directory exists
    os.makedirs(dest, exist_ok=True)
    
    # Configure options for yt-dlp
    ydl_opts = {
        'format': 'bestaudio/best',
        'outtmpl': os.path.join(dest, '%(title)s.%(ext)s'),
        'postprocessors': [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'm4a',
            'preferredquality': '256'
        }]
    }
    
    # Download the audio
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info_dict = ydl.extract_info(inputURL, download=True)
        title = info_dict.get('title', None)  # Get the title of the video

    # Construct the full file path based on the title
    filename = f"{title}.m4a"
    file_path = os.path.join(dest, filename)
    
    # Check if file exists and return the path
    if os.path.exists(file_path):
        return file_path
    else:
        return None






    
