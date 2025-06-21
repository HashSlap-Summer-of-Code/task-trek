#!/bin/bash

# TaskTrek Library - Core functions for task management
# This file contains all the core functionality

# Configuration
DATA_DIR="$SCRIPT_DIR/data"
TASKS_FILE="$DATA_DIR/tasks.json"

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

# Update next ID in JSON
update_next_id() {
    local new_id="$1"
    local temp_file=$(mktemp)
    jq ".next_id = $new_id" "$TASKS_FILE" > "$temp_file"
    mv "$temp_file" "$TASKS_FILE"
}

# Add a new task
add_task() {
    local title="$1"
    local description="$2"
    local recur_freq="$3"
    
    local task_id=$(get_next_id)
    local timestamp=$(get_timestamp)
    local temp_file=$(mktemp)
    
    # Create task object
    local task_json="{
        \"id\": $task_id,
        \"title\": \"$title\",
        \"description\": \"$description\",
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
    
    echo "Task added: #$task_id - $title"
    if [[ -n "$recur_freq" ]]; then
        echo "  Recurrence: $recur_freq"
    fi
}

# List tasks
list_tasks() {
    local show_all="$1"
    local filter="pending"
    
    if [[ "$show_all" == "true" ]]; then
        filter=""
    fi
    
    echo "TaskTrek - Task List"
    echo "===================="
    
    local tasks_found=false
    
    # Get tasks based on filter
    if [[ -z "$filter" ]]; then
        jq -r '.tasks[] | "\(.id)|\(.title)|\(.description)|\(.status)|\(.recurring.enabled)|\(.recurring.frequency // "none")|\(.recurring.next_occurrence // "")"' "$TASKS_FILE"
    else
        jq -r ".tasks[] | select(.status == \"$filter\") | \"\(.id)|\(.title)|\(.description)|\(.status)|\(.recurring.enabled)|\(.recurring.frequency // \"none\")|\(.recurring.next_occurrence // \"\")\"" "$TASKS_FILE"
    fi | while IFS='|' read -r id title desc status is_recurring freq next_occur; do
        tasks_found=true
        
        # Format output
        echo ""
        echo "[$id] $title"
        if [[ -n "$desc" && "$desc" != "null" ]]; then
            echo "    Description: $desc"
        fi
        echo "    Status: $status"
        
        if [[ "$is_recurring" == "true" ]]; then
            echo "    Recurring: $freq"
            if [[ -n "$next_occur" && "$next_occur" != "null" ]]; then
                local formatted_date=$(date -d "$next_occur" +"%Y-%m-%d %H:%M" 2>/dev/null || echo "$next_occur")
                echo "    Next occurrence: $formatted_date"
            fi
        fi
    done
    
    if [[ "$tasks_found" == "false" ]]; then
        echo ""
        echo "No tasks found."
    fi
}

# Complete a task
complete_task() {
    local task_id="$1"
    local temp_file=$(mktemp)
    
    # Check if task exists
    local task_exists=$(jq -r ".tasks[] | select(.id == $task_id) | .id" "$TASKS_FILE")
    if [[ -z "$task_exists" ]]; then
        echo "Error: Task #$task_id not found"
        return 1
    fi
    
    # Get task details for recurring check
    local is_recurring=$(jq -r ".tasks[] | select(.id == $task_id) | .recurring.enabled" "$TASKS_FILE")
    local frequency=$(jq -r ".tasks[] | select(.id == $task_id) | .recurring.frequency" "$TASKS_FILE")
    local title=$(jq -r ".tasks[] | select(.id == $task_id) | .title" "$TASKS_FILE")
    local description=$(jq -r ".tasks[] | select(.id == $task_id) | .description" "$TASKS_FILE")
    
    # Mark task as completed
    jq "(.tasks[] | select(.id == $task_id) | .status) = \"completed\"" "$TASKS_FILE" > "$temp_file"
    mv "$temp_file" "$TASKS_FILE"
    
    echo "Task #$task_id completed: $title"
    
    # If recurring, create new instance
    if [[ "$is_recurring" == "true" && "$frequency" != "null" ]]; then
        echo "Regenerating recurring task..."
        add_task "$title" "$description" "$frequency"
    fi
}

# Delete a task
delete_task() {
    local task_id="$1"
    local temp_file=$(mktemp)
    
    # Check if task exists
    local task_exists=$(jq -r ".tasks[] | select(.id == $task_id) | .id" "$TASKS_FILE")
    if [[ -z "$task_exists" ]]; then
        echo "Error: Task #$task_id not found"
        return 1
    fi
    
    local title=$(jq -r ".tasks[] | select(.id == $task_id) | .title" "$TASKS_FILE")
    
    # Remove task from JSON
    jq "del(.tasks[] | select(.id == $task_id))" "$TASKS_FILE" > "$temp_file"
    mv "$temp_file" "$TASKS_FILE"
    
    echo "Task deleted: #$task_id - $title"
}

# Regenerate recurring tasks that are due
regenerate_recurring_tasks() {
    local current_time=$(get_timestamp)
    local temp_file=$(mktemp)
    local tasks_regenerated=false
    
    # Find completed recurring tasks that need regeneration
    jq -r '.tasks[] | select(.status == "completed" and .recurring.enabled == true) | "\(.id)|\(.title)|\(.description)|\(.recurring.frequency)"' "$TASKS_FILE" | while IFS='|' read -r id title desc freq; do
        if [[ -n "$id" ]]; then
            tasks_regenerated=true
            # Remove the completed task and add a new one
            jq "del(.tasks[] | select(.id == $id))" "$TASKS_FILE" > "$temp_file"
            mv "$temp_file" "$TASKS_FILE"
        fi
    done
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq to use TaskTrek."
    echo "On Ubuntu/Debian: sudo apt-get install jq"
    echo "On macOS: brew install jq"
    exit 1
fi