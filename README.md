# ⏱️ TaskTrek

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

