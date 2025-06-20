# TaskTrek - Recurring Task Management System

A lightweight, bash-based task management system with support for recurring tasks (daily, weekly, monthly).

## Features

- ✅ **Basic Task Management**: Add, list, complete, delete tasks
- 🔄 **Recurring Tasks**: Automatic regeneration with daily, weekly, monthly schedules  
- 📅 **Next Occurrence Display**: Shows when recurring tasks will appear next
- 💾 **JSON Storage**: Structured data storage with robust schema
- 🚀 **Lightweight**: Pure bash with minimal dependencies (just `jq`)

## Quick Start

```bash
# Clone and install
git clone <repository-url>
cd tasktrek
chmod +x install.sh
./install.sh

# Add some tasks
./tasktrek add "Daily standup" "Team meeting" --recur daily
./tasktrek add "Weekly review" --recur weekly
./tasktrek add "Fix bug #123" "Non-recurring task"

# List tasks
./tasktrek list

# Complete a task
./tasktrek complete 1

# Get help
./tasktrek help
```

## Commands

### Add Tasks
```bash
# Basic task
./tasktrek add "Task title" "Optional description"

# Recurring tasks
./tasktrek add "Daily backup" --recur daily
./tasktrek add "Team meeting" --recur weekly  
./tasktrek add "Monthly report" --recur monthly
```

### List Tasks
```bash
# Show pending tasks only
./tasktrek list

# Show all tasks (including completed)
./tasktrek list --all
```

### Complete Tasks
```bash
# Complete task by ID (auto-regenerates if recurring)
./tasktrek complete 1
```

### Delete Tasks
```bash
# Permanently delete task by ID
./tasktrek delete 1
```

## Recurring Task Behavior

When you complete a recurring task:
1. The current instance is marked as completed
2. A new instance is automatically created with the next occurrence date
3. The new task gets a fresh ID and "pending" status

**Recurrence Rules:**
- **Daily**: Regenerates every day at the same time
- **Weekly**: Regenerates every 7 days  
- **Monthly**: Regenerates on the same day of the next month

## Data Storage

Tasks are stored in `data/tasks.json` with this schema:

```json
{
  "tasks": [
    {
      "id": 1,
      "title": "Daily standup",
      "description": "Team sync meeting", 
      "status": "pending",
      "created": "2025-06-20T09:00:00Z",
      "due": null,
      "recurring": {
        "enabled": true,
        "frequency": "daily",
        "interval": 1,
        "next_occurrence": "2025-06-21T09:00:00Z"
      }
    }
  ],
  "next_id": 2
}
```

## Requirements

- **Bash 4.0+**: For associative arrays and modern features
- **jq**: JSON processor for data manipulation
- **date**: GNU date for timestamp calculations

### Install jq:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL  
sudo yum install jq

# macOS
brew install jq
```

## Project Structure

```
tasktrek/
├── tasktrek                    # Main executable
├── tasktrek-lib.sh            # Core library functions  
├── data/
│   └── tasks.json            # Task storage
├── tests/                    # Test scripts
├── docs/                     # Documentation
├── README.md                 # This file
└── install.sh               # Installation script
```

## Development

The codebase is split into two main files:

- **`tasktrek`**: CLI interface and argument parsing
- **`tasktrek-lib.sh`**: Core functionality and task operations

Key functions in the library:
- `add_task()`: Creates new tasks with optional recurrence
- `complete_task()`: Marks tasks complete and handles regeneration
- `list_tasks()`: Displays tasks with recurrence info
- `regenerate_recurring_tasks()`: Auto-regenerates overdue recurring tasks

## Troubleshooting

**"jq: command not found"**
- Install jq using your package manager (see Requirements)

**Permission denied**
- Run `chmod +x tasktrek tasktrek-lib.sh` to make scripts executable

**Tasks not regenerating**
- Check that completed recurring tasks have proper JSON structure
- Verify `next_occurrence` dates are correctly formatted

## License

MIT License - feel free to modify and distribute.

## Contributing

1. Fork the repository
2. Create a feature branch  
3. Add tests for new functionality
4. Submit a pull request

For bug reports or feature requests, please open an issue.