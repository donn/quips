# quips
quips (stands for Quickly Unleashed Inline Packaging for Swift) is a script that allows you to inline Swift packages in single Swift files.

Why? Well, because Swift lacks a lot of basic functionality for scripting despite some basic positioning for scripting, and having to form an actual, proper folder structure for a script to process some text files or something can get very tiresome.

# Dependencies
Any officially supported version of Swift with the Swift Package Manager, Ruby 2.0+.

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
In your Swift source file:

```swift
    // @quip ModuleName : "https://example.com/link-to-repository.git": MajorVersion : MinorVersion (Optional)
    @quip PlayingCard:"https://github.com/apple/example-package-playingcard.git":3:0
    // or
    @quip PlayingCard:"https://github.com/apple/example-package-playingcard.git":3
```

To use quips, you need to use the "quips" command to call the script:

```bash
    quips Example.swift
```

You can also use quips as a shebang:

```swift
    #!/usr/bin/env quips
    
    // [...]
```

# License
MIT. Check 'LICENSE'.