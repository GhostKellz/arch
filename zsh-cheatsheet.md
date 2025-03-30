# Zsh Cheatsheet

A quick reference guide to help with common Zsh commands, configuration, and plugins. Perfect for new users of Zsh or anyone looking to speed up their workflow.

---

## Basic Zsh Commands

- **Change directory**:
  ```bash
  cd ~       # Go to home directory
  cd -       # Go to previous directory
  ```
- **List files**:
  ```bash
  ls         # List directory contents
  ls -la     # List all files (including hidden)
  ```
- **Clear the screen**:
  ```bash
  clear      # Clear terminal screen
  ```

---

## Zsh Customization

- **Change prompt (simple example)**:
  ```bash
  PROMPT="%n@%m %~ %# "
  ```
- **Customize prompt color**:
  ```bash
  PROMPT="%F{blue}%n@%m%f %F{green}%~%f %# "
  ```

---

## Oh My Zsh Plugins

- **Enable plugins**:
  ```bash
  plugins=(git zsh-autosuggestions zsh-history-substring-search)
  ```
- **Use plugin commands**:
  ```bash
  git status  # oh-my-zsh Git plugin
  zsh-history-substring-search-up  # Search history with substring
  ```

---

## Advanced Zsh

- **Aliases**:
  ```bash
  alias gs='git status'  # Quick alias for git status
  alias ll='ls -lah'     # Alias for 'ls -lah'
  ```
- **Functions**:
  ```bash
  function greet() {
    echo "Hello, $1!"
  }
  greet "Zsh User"  # Example function call
  ```

---

## Zsh Shortcuts & Tips

- **Use the `Alt` key** to jump between words:  
  `Alt + Left/Right Arrow`
- **Search previous commands** with **Ctrl + R**:  
  Type a keyword and press **Ctrl + R** to search through history.

---

Feel free to add more useful shortcuts, functions, and customization tips!
