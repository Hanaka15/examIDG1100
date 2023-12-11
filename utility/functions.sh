spacer() {
    echo "===================================="
    echo "$1"
    echo "------------------------------------"
}

command_exists() {
    command -v "$1" > /dev/null
}

add_hosts() {
  local ip_address="$1"
  local hostname="$2"
  if [[ -z "$ip_address" || -z "$hostname" ]]; then
    echo "Usage: add_to_hosts ip_address hostname"
    return 1
  fi

  if ! grep -q "$ip_address $hostname" /etc/hosts; then
    echo "$ip_address $hostname" | sudo tee -a /etc/hosts > /dev/null
    echo "Added $hostname with IP $ip_address to /etc/hosts."
  else
    echo "Entry $hostname with IP $ip_address already exists in /etc/hosts."
  fi
}

add_cron_job() {
  local cron_command="$1"
  local job_description="$2"

  if [[ -z "$cron_command" || -z "$job_description" ]]; then
    echo "Usage: add_cron_job cron_command job_description"
    return 1
  fi

  # Check if the cron job already exists to avoid duplicates
  if crontab -l | grep -q "$cron_command"; then
    echo "Cron job already exists: $job_description"
  else
    # Add the cron job and display a message
    (crontab -l 2>/dev/null; echo "$cron_command") | crontab -
    echo "Added cron job: $job_description"
  fi
}