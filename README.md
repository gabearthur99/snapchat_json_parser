# HOW TO RUN THE IMAGE PROCESSING SCRIPT ON A MAC

These instructions are written for someone who has never used Terminal before.
Follow the steps exactly, in order.


## WHAT THIS SCRIPT DOES

- Reads a JSON file you already have
- Downloads images and videos listed in the JSON
- If an item is a ZIP:
  - Uses the JPG inside as the base image
  - Applies the PNG overlays inside the same ZIP
- Saves the finished media to a folder on your Mac
- Adds date and location metadata to images

## WHAT YOU NEED

- A Mac
- An internet connection
- Your JSON file (for example: saved_media.json)
- The script file: parse_snap_json.sh

## STEP 1: OPEN TERMINAL

1. Open Finder
2. Go to Applications
3. Open Utilities
4. Double-click Terminal

A window with text will open.

## STEP 2: INSTALL HOMEBREW (ONE TIME ONLY)

Copy and paste this entire line into Terminal, then press Enter:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Follow the on-screen instructions.


STEP 3: INSTALL REQUIRED TOOLS (ONE TIME ONLY)

After Homebrew finishes installing, copy and paste this line and press Enter:

brew install jq exiftool imagemagick

This may take a few minutes.


## STEP 4: PUT THE FILES IN ONE FOLDER

1. Open Finder
2. Go to your Desktop
3. Create a new folder named:

image_script

4. Put BOTH of these files into that folder:
- Your JSON file (example: saved_media.json)
- The script file (parse_snap_json.sh)


STEP 5: GO TO THE FOLDER IN TERMINAL

Copy and paste this line into Terminal and press Enter:

cd ~/Desktop/image_script


## STEP 6: ALLOW THE SCRIPT TO RUN

Copy and paste this line and press Enter:

chmod +x parse_snap_json.sh

This only needs to be done once.


## STEP 7: RUN THE SCRIPT

Copy and paste this line and press Enter:

./parse_snap_json.sh saved_media.json

If your JSON file has a different name, replace saved_media.json with the correct name.


## STEP 8: FIND YOUR IMAGES

1. Open the image_script folder on your Desktop
2. A new folder called:

downloaded_media

will appear
3. Your images and videos are inside this folder


## HOW TO KNOW IT WORKED

You should see messages in Terminal like:

Saved image: downloaded_media/image_2025-08-19__15_37_58.jpg

If you see messages like this, the script ran successfully.


# COMMON PROBLEMS AND FIXES

## "command not found"
- Make sure you copied the command exactly
- Make sure you pressed Enter

"permission denied"
Run this again:

chmod +x parse_snap_json.sh

## Nothing downloads
Check that:
- You are connected to the internet
- The JSON file name matches exactly
- The JSON file is in the same folder as the script


## WHAT NOT TO DO

- Do not rename the script file
- Do not open the script in Word or Pages
- Do not move files while the script is running


## RUNNING THE SCRIPT AGAIN

After everything is set up, you only need to run:

cd ~/Desktop/image_script
./parse_snap_json.sh saved_media.json