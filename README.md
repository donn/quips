# quips
quips (stands for nothing, I just like the word quip) is like a small shim around Swift Package Manager that allows you to import Swift packages in single Swift files.

I wrote this dumpster fire during my downtime as a Microsoft intern (not on company time though.) As it stands, four years later, there isn't a better way to run single Swift files, and I honestly prefer to study algorithms by writing them in Swift. So I decided to unarchive and re-use this.

# Dependencies
Swift Package Manger on either macOS or Linux, Ruby 2.0+.

## Why wouldn't I just use Ruby then
I prefer Swift's syntax, personally. :)

# Installation
```bash
    mkdir -p ~/bin
    curl -s https://raw.githubusercontent.com/donn/quips/master/quips.rb > ~/bin/quips
    chmod 755 ~/bin/quips
```

Ensure ~/bin is in path. Or don't.

# Usage
The syntax is as follows:
```swift
    @quip ModuleName:"https://example.com/link-to-repository.git":SemanticVersion
```

As an example. in your Swift source file:

```swift
    @quip PlayingCard:"https://github.com/apple/example-package-playingcard.git":3.0.0
```

To make things even shorter, you can also use a GitHub-specific quip:

```swift
    @quipgh PlayingCard:apple/example-package-playingcard:3.0.0
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
