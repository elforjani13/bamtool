# bamtool

A Rust-based genomics tool for processing BAM files and performing operations on chromosomal regions.

## Features

- Processes BAM files, aggregates chromosomal data.
- Efficient serialization with "bincode" crate.
- Includes `bin.sh` script for seamless data handling.

## Configure the Bash script

In the `bin.sh` script, there is a configuration section where you need to set up the data directory. Locate the following lines and customize them based on your project structure:

```bash
# Define the data directory
DATA_DIR="$DIR/[YOUR_DATA_DIR]/[YOUR_FILE]"
```
## Building and Running

```bash

# Clone the repository
   git clone https://github.com/yourusername/bamtool.git
   cd bamtool
   
# Build the Rust program
   cargo build
   
# Run the Bash script
   ./bin.sh
