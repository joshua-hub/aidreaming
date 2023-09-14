import os
import time

log_directory = "/app/outputs/"

def check_log_directory():
    modified_files = []
    for root, dirs, files in os.walk(log_directory):
        for file in files:
            file_path = os.path.join(root, file)
            modified_time = os.path.getmtime(file_path)
            current_time = time.time()
            if current_time - modified_time > 3600:
                modified_files.append(file)

    if modified_files:
        print("The following file(s) haven't been changed in the last hour:")
        for file in modified_files:
            print(file)
    else:
        print("All files have been changed recently")

while True:
    check_log_directory()
    time.sleep(60)  # Sleep for 1 minute before chaching again