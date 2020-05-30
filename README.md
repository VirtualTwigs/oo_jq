![oo_jq logo](logo.png)
# Bash OOP using jq
**oo_jq** provides lightweight bash OOP based on [jq](). Inspired by [bash oo framework](https://github.com/niieani/bash-oo-framework), but with the benefit of using jq for object representation, **oo_jq** implements many OOP features with a tiny footprint, also allowing debugging and unit testing with vscode and [BATS](https://github.com/sstephenson/bats). Read [**this article**](https://www.virtualtwigs.com/articles/oo_jq_article) for more history and details
# How to create and use objects with oo_jq
You write bash functions that bundle an object's properties and methods using case statements, and then use **oo_jq** to call them.
**oo_jq** provides a single function oo followed by space separated arguments that mimic OOP syntax(arguments include "=" for assignment, "." for properties, and ":" for methods). Thus, the code for calling the example mentioned later consists of:
<pre>
oo mark = new Human
oo mark . name = 'Mark G. Smith'
oo mark . height = 180
oo mark : eat 'corn'
oo mark : eat 'blueberries'

# get properties
echo $(oo result = mark . name)
oo description = mark : describeYourSelf
echo $description

$ name: Mark G. Smith, height: 180, meals eaten: 2, meals: [ corn, blueberries ]
</pre>

# Implementation
the oo function depends on a json string {"class": "bashFunctionName"} where "bashFunctionName" implements the class methods. For example: mark='{"class": "Human"}. The oo function expects parameters in different orders to imitate typical object oriented notation. If you want to use the "new" operator, your "bashFunctionName" must contain a 'constructor' selector.

# Examples
Human.sh imitates [bash oo framework's human.sh example](https://github.com/niieani/bash-oo-framework/blob/master/example/human.sh)
It implements the class for the bash sample shown this document. It uses mostly oo, with a couple of lines of jq to handle an array of meals.

There are a few more examples in the unit tests (oo_jq.bats). You can copy and paste them into .sh files and run and debug them.
# Running unit tests
BATS tests show usage, and oo.debug.sh is for use with the VScode bash debugger

## BATS installation
Install [bats](https://opensource.com/article/19/2/testing-bash-bats). On a mac, this would be:
<pre>
brew install jq
brew install bats
cd  ~/your_code_dir/oo_jq
git submodule add -f https://github.com/ztombol/bats-assert test/libs/bats-assert
git submodule add -f https://github.com/ztombol/bats-support test/libs/bats-support
</pre>

## Running the tests
<pre>bats test</pre>
To run a single bats file:
<pre>bats test/oo.bats</pre>

# Debugging bash using VSCode
Setup a newer version of bash and vscode following [this article](https://medium.com/@faizanahemad/debugging-bash-shell-scripts-df52c5428235)
* for debugging tests residing in BATS, I copy the code from a test and paste it into oo_jq.debug.sh and use a configuration in vscode:
<pre>
       {
            "type": "bashdb",
            "request": "launch",
            "name": "Bash-Debug oo_jq.debug.sh",
            "cwd": "${workspaceFolder}",
            "program": "${workspaceFolder}/test/oo_jq.debug.sh",
            "args": []
        }
</pre>
