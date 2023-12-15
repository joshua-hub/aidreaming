import os
import time

log_directory = "/app/outputs/"

def check_log_directory():
    changes_made = False
    for root, dirs, files in os.walk(log_directory):
        for file in files:
            file_path = os.path.join(root, file)
            modified_time = os.path.getmtime(file_path)
            current_time = time.time()
            if current_time - modified_time > 3600:
                changes_made = True

    if not changes_made:
        # Here I want a kubectl command to delete this deployment and service
        print("No changes in the last hour")

while True:
    check_log_directory()
    time.sleep(60)  # Sleep for 1 minute before chaching again