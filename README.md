# t3 - Temporary File Saver and Auto-Deleter

**t3** is a command-line utility designed to save piped output into a temporary file and automatically delete it after a specified delay. It provides options for customization, including filename, deletion time, safety checks, lock modes, and verbose logging.

## Installation

To install t3 on your system, use the following one-liner:
```bash
curl -sSL https://raw.githubusercontent.com/Agusx1211/t3/refs/heads/master/t3.sh -o /usr/local/bin/t3 && chmod +x /usr/local/bin/t3
```

or

```bash
sudo sh -c 'curl -sSL https://raw.githubusercontent.com/Agusx1211/t3/refs/heads/master/t3.sh -o /usr/local/bin/t3 && chmod +x /usr/local/bin/t3'
```

This command downloads the script to `/usr/local/bin/t3` and grants execute permissions.

## Usage

**t3** was originally created to solve a specific problem: copying command outputs when working on remote machines via VSCode's SSH connection. When connected remotely through VSCode, the traditional method of copying terminal output can be cumbersome. **t3** provides a simple solution by saving the output to a temporary file that can be easily opened and copied through VSCode's interface, and then automatically cleaned up.

While this was the primary motivation, **t3** can be useful in many other scenarios where you need to temporarily store command outputs or data for quick access before automatic cleanup.

### Basic Usage

```bash
your_command | t3
```

This saves the output of `your_command` into a file named `<unix timestamp>.tmp` in the current directory, which will be deleted after 30 seconds.

### Options

- `-n <name>` or `--name=<name>`: Specify a custom filename or directory path. If a directory is specified, the file will be created inside it with the default timestamp-based name (default: `<unix timestamp>.tmp`).
- `-s <seconds>` or `--seconds=<seconds>`: Set the delay before deletion (default: 30).
- `-l` or `--lock`: Lock mode. Wait in the foreground for the specified time without spawning a background process.
- `-u` or `--unsafe`: Disable safety checks, deleting the file regardless of modifications.
- `-v` or `--verbose`: Enable detailed logging.

You can also specify the filename or directory as a positional argument:

```bash
your_command | t3 ./myfile.txt
your_command | t3 ./mydirectory/
```

> **Note**: If both `-n/--name` and a positional filename are provided, the value from `-n/--name` will be used, and a warning will be displayed.

### Example with Options

```bash
# Save to a specific file
echo "Hello, World!" | t3 -n greeting.txt -s 60 -v
# or
echo "Hello, World!" | t3 greeting.txt -s 60 -v

# Save to a directory with timestamp-based name
echo "Hello, World!" | t3 -n /path/to/directory -s 60 -v
# or
echo "Hello, World!" | t3 /path/to/directory -s 60 -v

# Warning example (both methods used)
echo "Hello, World!" | t3 -n file1.txt file2.txt
# Warning: Both -n/--name and positional filename provided. Using -n/--name value.
```

The examples show different ways to save the output:
- To a specific file (using either `-n` option or positional argument)
- To a directory with a timestamp-based name (using either `-n` option or positional argument)
- What happens when both methods are used (warning is shown)

Verbose mode provides detailed logs throughout the process.

## License

MIT License

Copyright (c) 2025 Agusx1211

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
