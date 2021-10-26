#!/usr/bin/env quips
import Foundation

@quipgh Defile:donn/Defile:5.0.0

guard let file = File("README.md") else {
    print("Could not open file README.md.")
    exit(0)
}

let lines = file.lines!

print(lines)