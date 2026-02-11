#!/bin/bash

# 1. Variables
DATE=${1:-$(date +%Y%m%d)}
SERVER_NAME=$(hostname)

# 2. SMTP Configuration
SMTP_SERVER="mail.360.my" # SMTP server address
SMTP_PORT="587"           # SMTP server port
SMTP_USER="support@360.my" # SMTP username
SMTP_PASS='yihuai9908!6Interactivehuatah!' # SMTP password
RECIPIENT="smsalert@360.my" # Recipient email address

# 3. Email Body
BODY="Critical Temperature Alert Details:

Use this command to check temperature: 

> cd /home/markkhor/law/
> cat system_stats_$DATE.csv


detects that the server '$SERVER_NAME' has reached a critical temperature level on $DATE.
Please check the system immediately!"

# 4. Execute Sending (The Fixed Parts are Highlighted)ls
      # \ is like \n for continuing the command on the next line
swaks --to "$RECIPIENT" \ # Where is the email going?
      --from "$SMTP_USER" \  # Who is sending the email?
      --server "$SMTP_SERVER" \ # This is the address of the SMTP server
      --port "$SMTP_PORT" \ # This is the specific port to connect to
      --auth LOGIN \ # This is to tell the server I am not a stranger I have a login
      --auth-user "$SMTP_USER" \ # My login username
      --auth-password "$SMTP_PASS" \ # My login password
      --tls \ # Keeps the connection secure and \ is for 
      --helo "officer240140" \ # Identifies the sending server to the receiving server
      --header "Subject: Temperature Alert for $SERVER_NAME ($DATE)" \
      --body "$BODY"