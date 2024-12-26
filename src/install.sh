APP_FOLDER="/opt/oss"

echo "OSS installation script started"

# Check if we are root
if [ "$UID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Switching the working directory to the location of this script. On error stay in current path.
cd "$(dirname "$(realpath "$0")")" ||

# Update local sources
apt update -y we are root

# Check if Docker is installed, if not install it.
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Installing Docker..."

  apt install docker -y

  echo "Docker has been successfully installed."
else
  echo "Docker is already installed."
fi

# Check if Docker is enabled for automatic start
if ! systemctl is-enabled docker &> /dev/null; then
  echo "Docker is not enabled to start on boot. Enabling it now..."
  systemctl enable docker
  echo "Docker has been enabled to start on boot."
else
  echo "Docker is already enabled to start on boot."
fi

# Check if APP_FOLDER contains files or folders, if so rename it to a backup
if [ -d "$APP_FOLDER" ] && [ "$(ls -A "$APP_FOLDER")" ]; then
  # Generate a timestamp (e.g., 20231105_150230 for YYYYMMDD_HHMMSS)
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

  # Move the existing folder to a new name with the timestamp
  NEW_FOLDER_NAME="${APP_FOLDER}_${TIMESTAMP}_BACKUP"
  echo "Folder $APP_FOLDER is not empty. Renaming it to $NEW_FOLDER_NAME."
  mv "$APP_FOLDER" "$NEW_FOLDER_NAME"
fi

# Check if there is an application folder in APP_FOLDER, if not create it
if [ ! -d "$APP_FOLDER" ]; then
  echo "Folder $APP_FOLDER does not exist. Creating it now..."
  mkdir -p "$APP_FOLDER"
  echo "Folder $APP_FOLDER has been created."
else
  echo "Folder $APP_FOLDER already exists."
fi

# Now copy this folder
