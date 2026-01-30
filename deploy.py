import ftplib
import os
import traceback

# FTP Connection Settings
FTP_HOST = "ftpupload.net"
FTP_USER = "if0_40917433"
FTP_PASS = "cjdtlqkf"

def upload_directory(ftp, local_dir, remote_dir):
    try:
        ftp.mkd(remote_dir)
        print(f"Created directory: {remote_dir}")
    except ftplib.error_perm:
        pass
    
    ftp.cwd(remote_dir)
    
    for filename in os.listdir(local_dir):
        local_path = os.path.join(local_dir, filename)
        if os.path.isfile(local_path):
            with open(local_path, "rb") as f:
                print(f"Uploading {filename} to {remote_dir}...")
                ftp.storbinary(f"STOR {filename}", f)
        elif os.path.isdir(local_path):
            upload_directory(ftp, local_path, filename)
            ftp.cwd("..")

def main():
    try:
        print(f"Connecting to {FTP_HOST}...")
        ftp = ftplib.FTP(FTP_HOST)
        ftp.login(FTP_USER, FTP_PASS)
        print("Login successful!")

        try:
            ftp.cwd("htdocs")
            print("Moved to htdocs directory.")
        except ftplib.error_perm:
            print("htdocs directory not found, staying in root.")

        local_base_path = r"c:\Users\차지희\Desktop\gma"
        
        for filename in ["index.html", "style.css"]:
            local_path = os.path.join(local_base_path, filename)
            if os.path.exists(local_path):
                with open(local_path, "rb") as f:
                    print(f"Uploading {filename}...")
                    ftp.storbinary(f"STOR {filename}", f)

        assets_local = os.path.join(local_base_path, "assets")
        if os.path.exists(assets_local):
            upload_directory(ftp, assets_local, "assets")

        ftp.quit()
        print("Deployment completed successfully!")
        
    except Exception as e:
        print(f"An error occurred: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    main()
