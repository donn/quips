#!/usr/bin/env quips
import Foundation

@quip Colors:"https://github.com/skyus/Colors":1
@quipgh Defile:skyus/Defile:2

guard let file = Defile("README.md")
else {
    print("Could not open file README.md.")
    exit(0)
}

let lines = file.lines!

for line in lines {
    var lineMutable = line
    if lineMutable.hasPrefix("#")
    {
        lineMutable = line.blue.bold
    }
    print(lineMutable)
}