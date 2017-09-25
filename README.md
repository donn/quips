# quips
quips (stands for Quickly Unleashed Inline Packaging for Swift) is a script that allows you to inline Swift packages in single Swift files.

Why? Well, because Swift lacks a lot of basic functionality for scripting despite its positioning for scripting, and having to form an actual, proper folder structure for a script to process some text files or something can get very tiresome.

# Dependencies
Swift Package Manger on either macOS or Linux, Ruby 2.0+.

## Why wouldn't I just use Ruby then
Good question.

...Moving on.

# Installation
```bash
    # macOS
    curl -s https://raw.githubusercontent.com/Skyus/quips/master/quips.rb > /usr/local/bin/quips
    chmod 755 /usr/local/bin/quips

    # Linux/Windows Subsystem for Linux
    curl -s https://raw.githubusercontent.com/Skyus/quips/master/quips.rb > ~/bin/quips
    chmod 755 ~/bin/quips
```

# Usage
The syntax is generally:
```swift
    @quip ModuleName:"https://example.com/link-to-repository.git":MajorVersion:MinorVersion?
```

In your Swift source file:

```swift
    @quip PlayingCard:"https://github.com/apple/example-package-playingcard.git":3:0

    // or if you don't really care about the minor version

    @quip PlayingCard:"https://github.com/apple/example-package-playingcard.git":3
```

To make things even shorter, you can also use a GitHub-specific quip:

```swift
    @quipgh PlayingCard:apple/example-package-playingcard:3
```

To run a quips-based Swift file, you need to use the "quips" command to call the script:

```bash
    quips Example.swift
```

You can also use quips as a shebang:

```php
    // Swift
    #!/usr/bin/env quips

    # Bash
    ./Example.swift
```

# License
The Unlicense. Check 'UNLICENSE'.
