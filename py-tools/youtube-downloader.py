import yt_dlp

url = input("Enter video rul: ")
ydl_opts = {}
with yt_dlp.YoutubeDL(ydl_opts) as ydl:
    ydl.download([url])
print("download finished")
