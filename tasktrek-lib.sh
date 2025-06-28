#!/bin/bash

# TaskTrek Library - Core functions for task management
# This file contains all the core functionality

# Configuration
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DATA_DIR="$SCRIPT_DIR/data"
TASKS_FILE="$DATA_DIR/tasks.json"
CONFIG_DIR="$SCRIPT_DIR/config"
CONFIG_FILE="$CONFIG_DIR/settings.cfg"

# Load or initialize configuration
load_config() {
    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" <<EOF
priority_colors=true
date_format="%Y-%m-%d %H:%M"
EOF
    fi
    source "$CONFIG_FILE"
}

# Initialize data file
init_data_file() {
    mkdir -p "$DATA_DIR"
    if [[ ! -f "$TASKS_FILE" ]]; then
        echo '{"tasks": [], "next_id": 1}' > "$TASKS_FILE"
    fi
}

# Get current timestamp in ISO 8601 format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Calculate next occurrence based on frequency
calculate_next_occurrence() {
    local frequency="$1"
    local current_date="$2"
    
    case "$frequency" in
        "daily")
            date -d "$current_date + 1 day" -u +"%Y-%m-%dT%H:%M:%SZ"
            ;;
        "weekly")
            date -d "$current_date + 1 week" -u +"%Y-%m-%dT%H:%M:%SZ"
            ;;
        "monthly")
            date -d "$current_date + 1 month" -u +"%Y-%m-%dT%H:%M:%SZ"
            ;;
        *)
            echo "$current_date"
            ;;
    esac
}

# Get next ID from JSON
get_next_id() {
    jq -r '.next_id' "$TASKS_FILE"
}

# Add a new task
add_task() {
    local title="$1"
    local description="$2"
    local recur_freq="$3"
    local priority="${4:-medium}"  # Default to medium priority
    
    local task_id=$(get_next_id)
    local timestamp=$(get_timestamp)
    local temp_file=$(mktemp)
    
    # Create task object
    local task_json="{
        \"id\": $task_id,
        \"title\": \"$title\",
        \"description\": \"$description\",
        \"priority\": \"$priority\",
        \"status\": \"pending\",
        \"created\": \"$timestamp\",
        \"due\": null"
    
    # Add recurring properties if specified
    if [[ -n "$recur_freq" ]]; then
        local next_occurrence=$(calculate_next_occurrence "$recur_freq" "$timestamp")
        task_json="$task_json,
        \"recurring\": {
            \"enabled\": true,
            \"frequency\": \"$recur_freq\",
            \"interval\": 1,
            \"next_occurrence\": \"$next_occurrence\"
        }"
    else
        task_json="$task_json,
        \"recurring\": {
            \"enabled\": false
        }"
    fi
    
    task_json="$task_json}"
    
    # Add task to JSON and update next_id
    jq ".tasks += [$task_json] | .next_id = $((task_id + 1))" "$TASKS_FILE" > "$temp_file"
    mv "$temp_file" "$TASKS_FILE"
    
    echo "✅ Task added: #$task_id - $title"
    echo "  Priority: $priority"
    if [[ -n "$recur_freq" ]]; then
        echo "  Recurrence: $recur_freq"
    fi
}

# Get ANSI color code for priority
get_priority_color() {
    local priority="$1"
    case $priority in
        high|High)
            echo -e "\033[0;31m"  # Red
            ;;
        medium|Medium)
            echo -e "\033[0;33m"  # Yellow
            ;;
        low|Low)
            echo -e "\033[0;32m"  # Green
            ;;
        *)
            echo -e "\033[0m"     # Default
            ;;
    esac
}

# List tasks with colored output
list_tasks() {
    local show_all="$1"
    local filter="pending"
    local color_reset="\033[0m"
    
    if [[ "$show_all" == "true" ]]; then
        filter=""
    fi
    
    echo "📋 TaskTrek - Task List"
    echo "======================="
    
    local tasks_found=false
    
    # Get tasks based on filter
    if [[ -z "$filter" ]]; then
        task_data=$(jq -r '.tasks[] | "\(.id)|\(.title)|\(.description)|\(.priority)|\(.status)|\(.recurring.enabled)|\(.recurring.frequency // "none")|\(.recurring.next_occurrence // "")"' "$TASKS_FILE")
    else
        task_data=$(jq -r ".tasks[] | select(.status == \"$filter\") | \"\(.id)|\(.title)|\(.description)|\(.priority)|\(.status)|\(.recurring.enabled)|\(.recurring.frequency // \"none\")|\(.recurring.next_occurrence // \"\")\"" "$TASKS_FILE")
    fi
    
    while IFS='|' read -r id title desc priority status is_recurring freq next_occur; do
        tasks_found=true
        color_code=$(get_priority_color "$priority")
        
        echo ""
        echo -e "${color_code}[$id] $title${color_reset}"
        if [[ -n "$desc" && "$desc" != "null" ]]; then
            echo -e "  ${color_code}Description: $desc${color_reset}"
        fi
        echo -e "  ${color_code}Priority: $priority${color_reset}"
        echo -e "  ${color_code}Status: $status${color_reset}"
        
        if [[ "$is_recurring" == "true" ]]; then
            echo -e "  ${color_code}Recurring: $freq${color_reset}"
            if [[ -n "$next_occur" && "$next_occur" != "null" ]]; then
                local formatted_date=$(date -d "$next_occur" +"$date_format" 2>/dev/null || echo "$next_occur")
                echo -e "  ${color_code}Next occurrence: $formatted_date${color_reset}"
            fi
        fi
    done <<< "$task_data"

    if [[ "$tasks_found" != "true" ]]; then
        echo ""
        echo "No tasks found. Enjoy your free time! 🎉"
    fi
}

# Complete a task
complete_task() {
    local task_id="$1"
    local temp_file=$(mktemp)
    
    # Check if task exists
    local task_exists=$(jq -r ".tasks[] | select(.id == $task_id) | .id" "$TASKS_FILE")
    if [[ -z "$task_exists" ]]; then
        echo "❌ Error: Task #$task_id not found"
        return 1
    fi
    
    # Get task details for recurring check
    local is_recurring=$(jq -r ".tasks[] | select(.id == $task_id) | .recurring.enabled" "$TASKS_FILE")
    local frequency=$(jq -r ".tasks[] | select(.id == $task_id) | .recurring.frequency" "$TASKS_FILE")
    local title=$(jq -r ".tasks[] | select(.id == $task_id) | .title" "$TASKS_FILE")
    local description=$(jq -r ".tasks[] | select(.id == $task_id) | .description" "$TASKS_FILE")
    local priority=$(jq -r ".tasks[] | select(.id == $task_id) | .priority" "$TASKS_FILE")
    
    # Mark task as completed
    jq "(.tasks[] | select(.id == $task_id) | .status) = \"completed\"" "$TASKS_FILE" > "$temp_file"
    mv "$temp_file" "$TASKS_FILE"
    
    echo "✅ Task #$task_id completed: $title"
    
    # If recurring, create new instance
    if [[ "$is_recurring" == "true" && "$frequency" != "null" ]]; then
        echo "🔄 Regenerating recurring task..."
        add_task "$title" "$description" "$frequency" "$priority"
    fi
}

# Delete a task
delete_task() {
    local task_id="$1"
    
    if [[ -z "$task_id" ]]; then
        echo "❌ Error: Please provide a task ID."
        return 1
    fi

    local temp_file=$(mktemp)

    # Check if task exists
    local task_exists=$(jq -r ".tasks[] | select(.id == $task_id) | .id" "$TASKS_FILE")
    if [[ -z "$task_exists" ]]; then
        echo "❌ Error: Task ID '$task_id' does not exist."
        return 1
    fi

    local title=$(jq -r ".tasks[] | select(.id == $task_id) | .title" "$TASKS_FILE")

    # Remove task from JSON
    jq "del(.tasks[] | select(.id == $task_id))" "$TASKS_FILE" > "$temp_file"
    mv "$temp_file" "$TASKS_FILE"

    echo "✅ Task #$task_id deleted: \"$title\""
}

# Main initialization
load_config
init_data_file

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is required but not installed. Please install jq to use TaskTrek."
    echo "  On Ubuntu/Debian: sudo apt-get install jq"
    echo "  On macOS: brew install jq"
    echo "  On Fedora: sudo dnf install jq"
    exit 1
fi