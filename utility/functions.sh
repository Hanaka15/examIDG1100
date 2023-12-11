# Verry not needed but used to make the output in console cleaner
# Used as a replacement for ECHO to divide output into sections.
spacer() {
    echo "===================================="
    echo "$1"
    echo "------------------------------------"
}

# Used to determin if python exists or needs to be installed.
command_exists() {
    command -v "$1" > /dev/null
}

# Add an entry to /etc/hosts file if it doesn't exist
# moved it here as a function to try to clean up the Deployment Script
add_hosts() {
  local ip_address="$1"
  local hostname="$2"
  # Checks if the arguments are empty.
  if [[ -z "$ip_address" || -z "$hostname" ]]; then
    echo "Usage: add_to_hosts ip_address hostname"
    return 1
  fi
  # Checks if the entry already exists.
  if ! grep -q "$ip_address $hostname" /etc/hosts; then
    echo "$ip_address $hostname" | sudo tee -a /etc/hosts > /dev/null
    echo "Added $hostname with IP $ip_address to /etc/hosts."
  else
    echo "Entry $hostname with IP $ip_address already exists in /etc/hosts."
  fi
}

# Same as the hosts one but adds cron jobs. 
# Its basically a copy of the hosts function
add_cron_job() {
  local cron_command="$1"
  local job_description="$2"
  # Checks if the arguments are empty.
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