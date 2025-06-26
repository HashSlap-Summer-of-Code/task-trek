# TaskTrek - Time Tracking System

A Pomodoro-style time tracking extension for TaskTrek task management.

## 📁 Folder Structure

```
tasktrek/
├── README.md                 # This file
├── tasktrek                  # Main executable script
├── lib/
│   ├── tasktrek-lib.sh      # Core library functions
│   └── time-tracking.sh     # Time tracking module
├── data/
│   ├── tasks.json           # Task storage
│   └── time-logs.json       # Time tracking data
├── tmp/
│   └── .timer_*             # Active timer files
└── docs/
    └── TIME_TRACKING.md     # Time tracking documentation
```

## 🚀 Features

- **Pomodoro Timer**: Start/stop timers for specific tasks
- **Live Display**: Real-time elapsed time updates
- **Automatic Logging**: Time entries automatically saved
- **Weekly Reports**: Comprehensive time analysis
- **Background Processing**: Non-blocking timer operation
- **Data Persistence**: JSON-based storage system

## ⚡ Quick Start

```bash
# Make scripts executable
chmod +x tasktrek
chmod +x lib/*.sh

# Create a task
./tasktrek add "Complete project documentation"

# Start timer for task ID 1
./tasktrek start 1

# Check timer status
./tasktrek status

# Stop timer
./tasktrek stop

# View weekly report
./tasktrek report weekly
```

## 📋 Commands

### Basic Commands
- `tasktrek add "<description>"` - Add new task
- `tasktrek list` - Show all tasks
- `tasktrek complete <id>` - Mark task complete

### Time Tracking Commands
- `tasktrek start <task_id>` - Start Pomodoro timer
- `tasktrek stop [task_id]` - Stop active timer
- `tasktrek status` - Show timer status
- `tasktrek pause <task_id>` - Pause timer
- `tasktrek resume <task_id>` - Resume paused timer

### Reporting Commands
- `tasktrek report daily` - Today's time summary
- `tasktrek report weekly` - Weekly time report
- `tasktrek report task <task_id>` - Time spent on specific task
- `tasktrek logs [date]` - View time logs

## 🔧 Installation

1. Clone or download the TaskTrek files
2. Make the main script executable:
   ```bash
   chmod +x tasktrek
   chmod +x lib/*.sh
   ```
3. Optionally, add to your PATH:
   ```bash
   sudo ln -s $(pwd)/tasktrek /usr/local/bin/tasktrek
   ```

## 📊 Data Storage

- **tasks.json**: Stores task information
- **time-logs.json**: Stores all time tracking entries
- **tmp/.timer_***: Temporary files for active timers

## 🎯 Usage Examples

```bash
# Start a work session
./tasktrek start 1
# Timer started for task: "Complete documentation"
# Press Ctrl+C to stop timer

# Check what's running
./tasktrek status
# Task #1: Complete documentation
# Time: 00:15:32 (running)

# View weekly summary
./tasktrek report weekly
# Weekly Time Report (Jun 14-20, 2025)
# Total time: 8h 45m
# Tasks worked on: 3

# Delete a task by ID
./tasktrek delete 1
# ✅ Task with ID '1' deleted successfully
# If no ID is provided
./tasktrek delete
# ❌ Please provide a task ID.
# If the task ID doesn't exist
./tasktrek delete abc123
# ❌ Task ID 'abc123' does not exist.

```

## 🔄 Timer Features

- **Live Updates**: Terminal display updates every second
- **Background Operation**: Timers run independently
- **Interrupt Handling**: Graceful shutdown on Ctrl+C
- **Auto-save**: Time logged automatically on stop
- **Multiple Timers**: Support for concurrent task timers

## 📈 Reporting

The system provides detailed reporting:
- Daily summaries
- Weekly overviews
- Per-task breakdowns
- Time trend analysis

## 🛠️ Requirements

- Bash 4.0+
- Standard Unix utilities (date, sleep, kill, ps)
- JSON processing capabilities (jq recommended)

## 🤝 Contributing

Feel free to extend the system with additional features:
- Pomodoro break reminders
- Time goal tracking
- Export to other formats
- Integration with calendar systems

## 📝 License

MIT License - Feel free to modify and distribute.

---

**Happy time tracking! 🍅⏰**# ⏱️ TaskTrek

<p align="center">
  <img src="https://img.shields.io/github/license/HashSlap-Summer-of-Code/task-trek?color=brightgreen&style=flat-square" />
  <img src="https://img.shields.io/github/stars/HashSlap-Summer-of-Code/task-trek?style=flat-square&color=blue" />
  <img src="https://img.shields.io/github/forks/HashSlap-Summer-of-Code/task-trek?style=flat-square&color=gray" />
  <img src="https://img.shields.io/github/issues/HashSlap-Summer-of-Code/task-trek?style=flat-square&color=green" />
  <img src="https://img.shields.io/github/issues-pr/HashSlap-Summer-of-Code/task-trek?style=flat-square&color=gold" />
</p>

---

## 🧭 Overview

**TaskTrek** is a sleek, terminal-based **Windows CLI** tool designed for developers and minimalist productivity enthusiasts. It allows you to **add**, **prioritize**, **track**, and **organize tasks** effortlessly — right from your terminal.

> Think of it as your personal command-line productivity assistant.

---

## ⚙️ Features

* ✅ Simple task creation with `--priority` flags
* 📋 View task lists by priority or due date
* 📆 Daily summaries with highlights
* ⏰ Notification hooks for upcoming or overdue tasks
* 📁 JSON-based local storage (easy to migrate or backup)

---

## 🚀 Quick Commands

```bash
tasktrek add "Fix login bug" --priority high
tasktrek list
tasktrek complete 2
tasktrek summary --today
```

---

## 📂 Project Structure

```
.
├── tasktrek/
│   ├── __init__.py
│   ├── core.py
│   ├── cli.py
│   └── utils.py
├── snippets/
├── tests/
├── README.md
└── requirements.txt
```

---

## 👥 Contributing

We’re building this project together, and we want you!
If you're looking for a beginner-friendly CLI tool to contribute to:

1. ⭐ Star this repo
2. 🍴 Fork it
3. 🔧 Pick or open an issue
4. 🔁 Open your first pull request

---

## 📌 Contribution Guidelines

* Use clean Python3+ code
* Write clear commit messages
* Include docstrings for your functions
* Run tests before pushing

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

