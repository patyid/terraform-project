#!/bin/bash

# === Load .env Configurations ===
if [ -f .env ]; then
    source .env
else
    echo "❌ .env file not found. Please create one with the necessary configuration."
    exit 1
fi

if [[ -z "$ACCOUNT_ID" || -z "$IAM_USER" || -z "$ROLE_NAME" ]]; then
    echo "❌ Missing configuration in .env. Ensure ACCOUNT_ID, IAM_USER, and ROLE_NAME are set."
    exit 1
fi

MFA_DEVICE_ARN="arn:aws:iam::$ACCOUNT_ID:mfa/$IAM_USER"
ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

read -p "Enter MFA Code for $IAM_USER: " MFA_CODE

# === Detect and use AWS_PROFILE if provided ===
if [[ -n "$AWS_PROFILE" ]]; then
    echo "📌 Using AWS_PROFILE=$AWS_PROFILE for initial session-token request"
    AWS_CLI_PROFILE_ARGS=(--profile "$AWS_PROFILE")
else
    AWS_CLI_PROFILE_ARGS=()
fi

# === Get temporary session token ===
echo "🔐 Getting temporary session token..."
SESSION_JSON=$(aws sts get-session-token \
    "${AWS_CLI_PROFILE_ARGS[@]}" \
    --serial-number "$MFA_DEVICE_ARN" \
    --token-code "$MFA_CODE" \
    --duration-seconds "$SESSION_DURATION")

if [ $? -ne 0 ]; then
    echo "❌ Failed to get session token. Check MFA code and configuration."
    exit 1
fi

AWS_ACCESS_KEY_ID=$(echo "$SESSION_JSON" | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$SESSION_JSON" | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "$SESSION_JSON" | jq -r '.Credentials.SessionToken')

# === Assume Role ===
echo "🍭 Assuming role $ROLE_ARN..."
ROLE_SESSION_JSON=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
    aws sts assume-role \
    --role-arn "$ROLE_ARN" \
    --role-session-name "${IAM_USER}_session")

if [ $? -ne 0 ]; then
    echo "❌ Failed to assume role."
    exit 1
fi

FINAL_ACCESS_KEY_ID=$(echo "$ROLE_SESSION_JSON" | jq -r '.Credentials.AccessKeyId')
FINAL_SECRET_ACCESS_KEY=$(echo "$ROLE_SESSION_JSON" | jq -r '.Credentials.SecretAccessKey')
FINAL_SESSION_TOKEN=$(echo "$ROLE_SESSION_JSON" | jq -r '.Credentials.SessionToken')

# === Save to profile or export to shell ===
if [[ "$AUTO_SAVE_PROFILE" == "true" ]]; then
    PROFILE_NAME=${DEFAULT_PROFILE_NAME:-temp_profile}

    # Clean up old config blocks
    sed -i "/^\[$PROFILE_NAME\]/,/^$/d" ~/.aws/credentials 2>/dev/null
    sed -i "/^\[profile $PROFILE_NAME\]/,/^$/d" ~/.aws/config 2>/dev/null

    aws configure set aws_access_key_id "$FINAL_ACCESS_KEY_ID" --profile "$PROFILE_NAME"
    aws configure set aws_secret_access_key "$FINAL_SECRET_ACCESS_KEY" --profile "$PROFILE_NAME"
    aws configure set aws_session_token "$FINAL_SESSION_TOKEN" --profile "$PROFILE_NAME"

    echo "[profile $PROFILE_NAME]" >> ~/.aws/config
    echo "region = ${AWS_DEFAULT_REGION:-us-east-1}" >> ~/.aws/config
    echo "output = json" >> ~/.aws/config

    CLEANUP_CMD="aws configure unset aws_access_key_id --profile $PROFILE_NAME; \
aws configure unset aws_secret_access_key --profile $PROFILE_NAME; \
aws configure unset aws_session_token --profile $PROFILE_NAME; \
echo '🧹 Cleaned up expired credentials from profile [$PROFILE_NAME].'"

    if command -v at &>/dev/null; then
        echo "$CLEANUP_CMD" | at now +$((SESSION_DURATION / 60)) minutes
        echo "🗓️ Cleanup scheduled using 'at'."
    else
        (sleep "$SESSION_DURATION" && eval "$CLEANUP_CMD") &
        echo "🗓️ Cleanup scheduled in background using 'sleep'."
    fi
else
    read -p "Do you want to [E]xport credentials to the current shell or [S]ave to a named AWS profile? (E/S): " CHOICE
    if [[ "$CHOICE" =~ ^[Ss]$ ]]; then
        read -p "Enter the profile name to save credentials: " PROFILE_NAME

        sed -i "/^\[$PROFILE_NAME\]/,/^$/d" ~/.aws/credentials 2>/dev/null
        sed -i "/^\[profile $PROFILE_NAME\]/,/^$/d" ~/.aws/config 2>/dev/null

        aws configure set aws_access_key_id "$FINAL_ACCESS_KEY_ID" --profile "$PROFILE_NAME"
        aws configure set aws_secret_access_key "$FINAL_SECRET_ACCESS_KEY" --profile "$PROFILE_NAME"
        aws configure set aws_session_token "$FINAL_SESSION_TOKEN" --profile "$PROFILE_NAME"

        echo "[profile $PROFILE_NAME]" >> ~/.aws/config
        echo "region = ${AWS_DEFAULT_REGION:-us-east-1}" >> ~/.aws/config
        echo "output = json" >> ~/.aws/config

        echo "✅ Temporary credentials saved to profile [$PROFILE_NAME]."
        echo "⏰ They will expire in approximately $((SESSION_DURATION / 60)) minutes."
    else
        export AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY
        export AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN
        echo "✅ Temporary AWS credentials exported to the current shell session."
        echo "⏰ They will expire in approximately $((SESSION_DURATION / 60)) minutes."
    fi
fi

# === Save Temporary Credentials to Log File ===
CREDENTIALS_LOG="./temporary_credentials.log"
echo "🔐 Saving temporary credentials to $CREDENTIALS_LOG"
echo "AWS_ACCESS_KEY_ID=$FINAL_ACCESS_KEY_ID" > $CREDENTIALS_LOG
echo "AWS_SECRET_ACCESS_KEY=$FINAL_SECRET_ACCESS_KEY" >> $CREDENTIALS_LOG
echo "AWS_SESSION_TOKEN=$FINAL_SESSION_TOKEN" >> $CREDENTIALS_LOG
echo "EXPIRATION_TIME=$(date -d "+$((SESSION_DURATION / 60)) minutes")" >> $CREDENTIALS_LOG

# === Print saved profile info ===
echo ""
echo "📂 ~/.aws/credentials (bloco [$PROFILE_NAME]):"
grep -A 2 "^\[$PROFILE_NAME\]" ~/.aws/credentials || echo "❌ Não encontrado."

echo ""
echo "📂 ~/.aws/config (bloco [profile $PROFILE_NAME]):"
grep -A 2 "^\[profile $PROFILE_NAME\]" ~/.aws/config || echo "❌ Não encontrado."