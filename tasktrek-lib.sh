#!/bin/bash

# Configuration
DATA_DIR="$(dirname "$0")/data"
CONFIG_DIR="$(dirname "$0")/config"
TASKS_FILE="$DATA_DIR/tasks.json"
CONFIG_FILE="$CONFIG_DIR/settings.cfg"

# Initialize TaskTrek
init_tasktrek() {
    # Create directories if needed
    mkdir -p "$DATA_DIR"
    mkdir -p "$CONFIG_DIR"
    
    # Create files if needed
    [ -f "$TASKS_FILE" ] || echo "[]" > "$TASKS_FILE"
    [ -f "$CONFIG_FILE" ] || {
        echo "# TaskTrek Configuration" > "$CONFIG_FILE"
        echo "priority_colors=true" >> "$CONFIG_FILE"
        echo "date_format=%Y-%m-%d" >> "$CONFIG_FILE"
    }
    
    # Load configuration
    source "$CONFIG_FILE"
}

# Add a new task
add_task() {
    local description=""
    local priority="medium"
    local due_date=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --priority)
                priority="$2"
                shift 2
                ;;
            --due)
                due_date="$2"
                shift 2
                ;;
            *)
                description="$1"
                shift
                ;;
        esac
    done
    
    # Validate input
    if [ -z "$description" ]; then
        echo "Error: Task description is required"
        exit 1
    fi
    
    # Create task object
    local task_id=$(date +%s)
    local task_json=$(jq -n \
        --arg id "$task_id" \
        --arg desc "$description" \
        --arg pri "$priority" \
        --arg due "$due_date" \
        --arg status "pending" \
        --arg created "$(date +"$date_format")" \
        '{id: $id, description: $desc, priority: $pri, due_date: $due, status: $status, created: $created}')
    
    # Add to tasks file
    local tasks=$(cat "$TASKS_FILE")
    echo "$tasks" | jq --argjson task "$task_json" '. += [$task]' > "$TASKS_FILE"
    
    echo "✅ Task added with ID: $task_id"
}

# List tasks
list_tasks() {
    local filter="all"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --priority)
                filter="priority"
                priority_filter="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Load tasks
    local tasks=$(cat "$TASKS_FILE")
    
    # Apply filter
    case $filter in
        all)
            filtered_tasks="$tasks"
            ;;
        priority)
            filtered_tasks=$(echo "$tasks" | jq --arg pri "$priority_filter" 'map(select(.priority == $pri))')
            ;;
    esac
    
    # Format output
    echo "$filtered_tasks" | jq -r '.[] | 
        "\(.id) | \(.description) | Priority: \(.priority) | Due: \(.due_date) | Status: \(.status)"'
}

# Complete a task
complete_task() {
    local task_id="$1"
    
    if [ -z "$task_id" ]; then
        echo "Error: Task ID is required"
        exit 1
    fi
    
    # Update task status
    local tasks=$(cat "$TASKS_FILE")
    local updated_tasks=$(echo "$tasks" | jq --arg id "$task_id" '
        map(if .id == $id then .status = "completed" else . end)')
    
    echo "$updated_tasks" > "$TASKS_FILE"
    echo "✅ Task $task_id marked as completed"
}

# Show summary
show_summary() {
    local tasks=$(cat "$TASKS_FILE")
    
    # Count tasks
    local total=$(echo "$tasks" | jq 'length')
    local completed=$(echo "$tasks" | jq 'map(select(.status == "completed")) | length')
    local pending=$(echo "$tasks" | jq 'map(select(.status == "pending")) | length')
    
    # Today's tasks
    local today=$(date +"$date_format")
    local today_tasks=$(echo "$tasks" | jq --arg today "$today" '
        map(select(.due_date == $today and .status == "pending")) | length')
    
    # Print summary
    echo "📊 TaskTrek Summary"
    echo "-------------------"
    echo "Total tasks: $total"
    echo "Completed: $completed"
    echo "Pending: $pending"
    echo "Due today: $today_tasks"
    echo ""
    echo "🚀 Keep going! You've got this!"
}

# Show help
show_help() {
    echo "TaskTrek - CLI Task Manager"
    echo "Usage:"
    echo "  tasktrek add \"<description>\" [--priority <high|medium|low>] [--due <YYYY-MM-DD>]"
    echo "  tasktrek list [--priority <high|medium|low>]"
    echo "  tasktrek complete <task_id>"
    echo "  tasktrek summary"
    echo ""
    echo "Examples:"
    echo "  tasktrek add \"Fix login bug\" --priority high"
    echo "  tasktrek list --priority high"
    echo "  tasktrek complete 1234567890"
}