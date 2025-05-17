# Morse Code Encoder/Decoder

A 64-bit Linux assembly program written in NASM that converts text to Morse code and Morse code to text. This program supports uppercase letters (A-Z), numbers (0-9), common punctuation (.,?!), and spaces between words.

## Features

- **Text to Morse Conversion**: Converts plain text (letters, numbers, punctuation) to Morse code, using '/' to represent spaces between words.
- **Morse to Text Conversion**: Decodes Morse code back to plain text, handling word spaces marked by '/'.
- **Interactive Menu**: Simple command-line interface with options to encode, decode, or exit.
- **Input Validation**: Handles invalid inputs gracefully with error messages.
- **Efficient Design**: Optimized for 64-bit Linux using NASM assembly for low-level performance.

## Requirements

- **Operating System**: 64-bit Linux distribution
- **Assembler**: NASM (Netwide Assembler)
- **Linker**: GNU ld (part of binutils)
- **Build Tools**: make (optional, if using the provided Makefile)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/morse-translator.git
   cd morse-translator
   ```

2. Assemble and link the program:
   ```bash
   nasm -f elf64 morse_translator.asm -o morse_translator.o
   ld morse_translator.o -o morse_translator
   ```

## Usage

1. Run the program:
   ```bash
   ./morse_translator
   ```

2. Follow the menu prompts:
   - **1. Text to Morse**: Enter text (e.g., "SOS HELP") to get Morse code output (e.g., "... --- ... / .... . .-.. .--.").
   - **2. Morse to Text**: Enter Morse code with spaces between letters and '/' for word spaces (e.g., "... --- ... / .... . .-.. .--.") to get text output (e.g., "SOS HELP").
   - **3. Exit**: Terminates the program.

### Example Interaction

```
Morse Code Encoder/Decoder

1. Text to Morse
2. Morse to Text
3. Exit
Enter choice: 1

Enter input: HELLO WORLD

Output: .... . .-.. .-.. --- / .-- --- .-. .-.. -..

1. Text to Morse
2. Morse to Text
3. Exit
Enter choice: 2

Enter input: .... . .-.. .-.. --- / .-- --- .-. .-.. -..

Output: HELLO WORLD
```

## Notes

- **Input Limitations**:
  - Input text is limited to 255 characters.
  - Only uppercase letters, numbers, and specific punctuation (.,?!) are supported. Lowercase letters are automatically converted to uppercase.
  - Unrecognized characters are ignored during text-to-Morse conversion.
- **Morse Code Format**:
  - Letters are separated by spaces (e.g., ".- .-." for "AR").
  - Words are separated by '/' (e.g., ".- / -.." for "A D").
  - Invalid Morse codes are skipped during decoding.

## Building from Source

Ensure NASM and GNU ld are installed. On a Debian-based system, you can install them with:

```bash
sudo apt update
sudo apt install nasm binutils
```

Then build using the commands above or the Makefile.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for bug fixes, improvements, or new features.
