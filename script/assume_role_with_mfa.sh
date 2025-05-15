#!/bin/bash
# === Load .env Configurations ===
if [ -f .env ]; then
    source .env
else
    echo "❌ .env file not found. Please create one with the necessary configuration."
    exit 1

# === Save Temporary Credentials to Log File ===
CREDENTIALS_LOG="./temporary_credentials.log"
echo "🔐 Saving temporary credentials to $CREDENTIALS_LOG"
echo "AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID" > $CREDENTIALS_LOG
echo "AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY" >> $CREDENTIALS_LOG
echo "AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN" >> $CREDENTIALS_LOG
echo "EXPIRATION_TIME=$(date -d '+$((SESSION_DURATION / 60)) minutes')" >> $CREDENTIALS_LOG

fi

if [[ -z "$ACCOUNT_ID" || -z "$IAM_USER" || -z "$ROLE_NAME" ]]; then
    echo "❌ Missing configuration in .env. Ensure ACCOUNT_ID, IAM_USER, and ROLE_NAME are set."
    exit 1

# === Save Temporary Credentials to Log File ===
CREDENTIALS_LOG="./temporary_credentials.log"
echo "🔐 Saving temporary credentials to $CREDENTIALS_LOG"
echo "AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID" > $CREDENTIALS_LOG
echo "AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY" >> $CREDENTIALS_LOG
echo "AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN" >> $CREDENTIALS_LOG
echo "EXPIRATION_TIME=$(date -d '+$((SESSION_DURATION / 60)) minutes')" >> $CREDENTIALS_LOG

fi

MFA_DEVICE_ARN="arn:aws:iam::$ACCOUNT_ID:mfa/$IAM_USER"
ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

read -p "Enter MFA Code for $IAM_USER: " MFA_CODE

echo "🔐 Getting temporary session token..."
SESSION_JSON=$(aws sts get-session-token     --serial-number "$MFA_DEVICE_ARN"     --token-code "$MFA_CODE"     --duration-seconds "$SESSION_DURATION")

if [ $? -ne 0 ]; then
    echo "❌ Failed to get session token. Check MFA code and configuration."
    exit 1

# === Save Temporary Credentials to Log File ===
CREDENTIALS_LOG="./temporary_credentials.log"
echo "🔐 Saving temporary credentials to $CREDENTIALS_LOG"
echo "AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID" > $CREDENTIALS_LOG
echo "AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY" >> $CREDENTIALS_LOG
echo "AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN" >> $CREDENTIALS_LOG
echo "EXPIRATION_TIME=$(date -d '+$((SESSION_DURATION / 60)) minutes')" >> $CREDENTIALS_LOG

fi

AWS_ACCESS_KEY_ID=$(echo "$SESSION_JSON" | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$SESSION_JSON" | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "$SESSION_JSON" | jq -r '.Credentials.SessionToken')

echo "🎭 Assuming role $ROLE_ARN..."
ROLE_SESSION_JSON=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID     AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY     AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN     aws sts assume-role     --role-arn "$ROLE_ARN"     --role-session-name "${IAM_USER}_session")

if [ $? -ne 0 ]; then
    echo "❌ Failed to assume role."
    exit 1

# === Save Temporary Credentials to Log File ===
CREDENTIALS_LOG="./temporary_credentials.log"
echo "🔐 Saving temporary credentials to $CREDENTIALS_LOG"
echo "AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID" > $CREDENTIALS_LOG
echo "AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY" >> $CREDENTIALS_LOG
echo "AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN" >> $CREDENTIALS_LOG
echo "EXPIRATION_TIME=$(date -d '+$((SESSION_DURATION / 60)) minutes')" >> $CREDENTIALS_LOG

fi

FINAL_ACCESS_KEY_ID=$(echo "$ROLE_SESSION_JSON" | jq -r '.Credentials.AccessKeyId')
FINAL_SECRET_ACCESS_KEY=$(echo "$ROLE_SESSION_JSON" | jq -r '.Credentials.SecretAccessKey')
FINAL_SESSION_TOKEN=$(echo "$ROLE_SESSION_JSON" | jq -r '.Credentials.SessionToken')

if [[ "$AUTO_SAVE_PROFILE" == "true" ]]; then
    PROFILE_NAME=${DEFAULT_PROFILE_NAME:-temp_profile}
    aws configure set aws_access_key_id "$FINAL_ACCESS_KEY_ID" --profile "$PROFILE_NAME"
    aws configure set aws_secret_access_key "$FINAL_SECRET_ACCESS_KEY" --profile "$PROFILE_NAME"
    aws configure set aws_session_token "$FINAL_SESSION_TOKEN" --profile "$PROFILE_NAME"
   
    CLEANUP_CMD="aws configure unset aws_access_key_id --profile $PROFILE_NAME; aws configure unset aws_secret_access_key --profile $PROFILE_NAME; aws configure unset aws_session_token --profile $PROFILE_NAME; echo "🧹 Cleaned up expired credentials from profile [$PROFILE_NAME].""



    if command -v at &>/dev/null; then
        echo "$CLEANUP_CMD" | at now +$((SESSION_DURATION / 60)) minutes
        echo "🗓️ Cleanup scheduled using 'at'."
    else
        (sleep "$SESSION_DURATION" && eval "$CLEANUP_CMD") &
        echo "🗓️ Cleanup scheduled in background using 'sleep'."
    
# === Save Temporary Credentials to Log File ===
CREDENTIALS_LOG="./temporary_credentials.log"
echo "🔐 Saving temporary credentials to $CREDENTIALS_LOG"
echo "AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID" > $CREDENTIALS_LOG
echo "AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY" >> $CREDENTIALS_LOG
echo "AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN" >> $CREDENTIALS_LOG

fi

else
    read -p "Do you want to [E]xport credentials to the current shell or [S]ave to a named AWS profile? (E/S): " CHOICE
    if [[ "$CHOICE" =~ ^[Ss]$ ]]; then
        read -p "Enter the profile name to save credentials: " PROFILE_NAME
        aws configure set aws_access_key_id "$FINAL_ACCESS_KEY_ID" --profile "$PROFILE_NAME"
        aws configure set aws_secret_access_key "$FINAL_SECRET_ACCESS_KEY" --profile "$PROFILE_NAME"
        aws configure set aws_session_token "$FINAL_SESSION_TOKEN" --profile "$PROFILE_NAME"
        echo "✅ Temporary credentials saved to profile [$PROFILE_NAME]."
        echo "⏰ They will expire in approximately $((SESSION_DURATION / 60)) minutes."
    else
        export AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY
        export AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN
        echo "✅ Temporary AWS credentials exported to the current shell session."
        echo "⏰ They will expire in approximately $((SESSION_DURATION / 60)) minutes."
    
# === Save Temporary Credentials to Log File ===
CREDENTIALS_LOG="./temporary_credentials.log"
echo "🔐 Saving temporary credentials to $CREDENTIALS_LOG"
echo "AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID" > $CREDENTIALS_LOG
echo "AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY" >> $CREDENTIALS_LOG
echo "AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN" >> $CREDENTIALS_LOG
echo "EXPIRATION_TIME=$(date -d '+$((SESSION_DURATION / 60)) minutes')" >> $CREDENTIALS_LOG

fi

# === Save Temporary Credentials to Log File ===
CREDENTIALS_LOG="./temporary_credentials.log"
echo "🔐 Saving temporary credentials to $CREDENTIALS_LOG"
echo "AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID" > $CREDENTIALS_LOG
echo "AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY" >> $CREDENTIALS_LOG
echo "AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN" >> $CREDENTIALS_LOG
echo "EXPIRATION_TIME=$(date -d '+$((SESSION_DURATION / 60)) minutes')" >> $CREDENTIALS_LOG

fi