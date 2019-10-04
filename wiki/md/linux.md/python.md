#### Python
------------

1. ##### A very basic example

Example 001.
```
#!/bin/env python3.6

import sys

a = sys.argv[1]

if a == "1":
    print('a is one')
    print('This is still the then clause of the if statement.')
else:
    print('a is one')
    print('This is still the then clause of the if statement.')

print("hello, world!")
```

You can split long lines by backslashing the end of line breaks. When you do this, the indentation of only the first line is significant. You can indent the continuation lines however you like. Lines with unbalanced parentheses, square brackets, or curly braces automatically signal continuation even in the absence of backslashes, but you can include the backslashes if doing so clarifies the structure of the code.

2. ##### Some types

**All data types in Python are objects.**

In Python, **lists** are enclosed in **square brackets** and indexed from zero. They are essentially similar to arrays, but can hold objects of any type.

Python also has **“tuples"**, which are essentially **immutable lists**. **Tuples** are faster than lists and are helpful for representing constant data. The syntax for tuples is the same as for lists, except that the delimiters are parentheses instead of square brackets. Because (thing) looks like a simple algebraic expression, tuples that con- tain only a single element need a marker comma to disambiguate them: (thing, ).

Example 002
```
name = 'Gwen'
rating = 10
# list
characters = [ 'SpongeBob', 'Patrick', 'Squidward' ] 
# tuples
elements = ( 'lithium', 'carbon', 'boron' )

print("name:\t%s\nrating:\t%d" % (name, rating)) print("characters:\t%s" % characters) print("hero:\t%s" % characters[0]) print("elements:\t%s" % (elements, ))
```

Variables in Python are **not syntactically marked or declared by type**, but the **objects** to which they refer **do have an underlying type**. 

A Python **dictionary** (also known as a hash or an associative array) represents a set of key/value pairs. You can think of a hash as an array whose subscripts (keys) are arbitrary values; they do not have to be numbers. But in practice, numbers and strings are common keys.
Dictionary literals are enclosed in curly braces, with each key/value pair being sepa- rated by a colon. In use, dictionaries work much like lists, except that the subscripts (keys) can be objects other than integers.

Example 003
```
ordinal = { 1 : 'first', 2 : 'second', 3 : 'third' } 
print("The ordinal dictionary contains", ordinal) 
print("The ordinal of 1 is", ordinal[1])
```

3. ##### Files

Example 004
```
f = open('/etc/passwd', 'r') 
print(f.readline(), end="") 
print(f.readline(), end="") 
f.close()
```

The newlines at the end of the print calls are suppressed with end="" because each line already includes a newline character from the original file. Python does **not automatically strip these.**

4. ##### Basic validation

Example 005
```
import sys 
import os

def show_usage(message, code = 1): 
    print(message)
    print("%s: source_dir dest_dir" % sys.argv[0]) sys.exit(code)

if len(sys.argv) != 3:
    show_usage("2 args required; you supplied %d" % (len(sys.argv) - 1))
elif not os.path.isdir(sys.argv[1]):
    show_usage("Invalid source directory")
elif not os.path.isdir(sys.argv[2]):
    show_usage("Invalid destination directory")

source, dest = sys.argv[1:3]
print("Source directory is", source) print("Destination directory is", dest)
```

Here we import `os,sys` modules but we have to point a full path to its function: `sys.argv[1:3]`.

The *parallel assignment* (`source, dest = sys.argv[1:3]`) of the source and dest variables is a bit different from some languages in that the variables themselves are not in a list. Python allows parallel assignments in either form.

5. ##### Loops
    
5.1 For
Python’s for has several
features that distinguish it from for in other languages:
- Nothing is special about numeric ranges. Any object can support Python’s iteration model, and most common objects do. You can iterate through a string (by character), a list, a file (by character, line, or block), a list slice, etc.
- Iterators can yield multiple values, and you can have multiple loop vari- ables. The assignment at the top of each iteration acts just like Python’s regular multiple assignments. This feature is particularly nice for iterating through dictionaries.
- Both `for` and `while` loops can have `else` clauses at the end.The else clause is executed only if the loop **terminates normally**, as opposed to exiting through a break statement. This feature may initially seem counterintui- tive, but it handles certain use cases quite elegantly.

Example 006

```
import sys 
import re

suits = {
'Bashful':'yellow', 'Sneezy':'brown', 'Doc':'orange', 'Grumpy':'red',
'Dopey':'green', 'Happy':'blue', 'Sleepy':'taupe'
}

pattern = re.compile("(%s)" % sys.argv[1])

for dwarf, color in suits.items():
    if pattern.search(dwarf) or pattern.search(color):
        print("%s's dwarf suit is %s." %
            (pattern.sub(r"_\1_", dwarf), pattern.sub(r"_\1_", color)))
        break
    else: 
        print("No dwarves or dwarf suits matched the pattern.")
```

The `\1` in the substitution string is a **back-reference** to the contents of the first capture group. The strange-looking `r` prefix that precedes the substitution string (`r"_\1_"`) **suppresses** the normal substitution of escape sequences in string con- stants (r stands for “raw”). Without this, the **replacement pattern would consist of two underscores surrounding a character with numeric code 1**.

One thing to note about dictionaries is that they have no defined iteration order. If you run the dwarf search a second time, you may well receive a different answer:

`$ python3 dwarfsearch '[aeiou]{2}' Dopey's dwarf suit is gr_ee_n.`

6. ##### pip
- `pip search`

- `pip install --user` - install in a user's home dir

- `pip install -r requirements.txt` - Package developers create a text file at the root of the project that lists its dependencies. Both file formats allow a source to be specified for each package, so dependencies need not be distributed through the language’s standard package warehouse. All common sources are supported, from web URLs to local files to GitHub repositories.You install a batch of Python dependencies with `pip install -r requirements.txt`. 

- `python3.6 -m pip freeze` - if the system has several python installed we can explicitly point that to `pip`

- `virtualenv` - is a tool to create isolated Python environments. The basic problem being addressed is one of dependencies and versions, and indirectly permissions. Imagine you have an application that needs version 1 of LibFoo, but another application requires version 2. How can you use both these applications? If you install everything into /usr/lib/python2.7/site-packages (or whatever your platform’s standard location is), it’s easy to end up in a situation where you unintentionally upgrade an application that shouldn’t be upgraded.

Or more generally, what if you want to install an application and leave it be? If an application works, any change in its libraries or the versions of those libraries can break the application.

Also, what if you can’t install packages into the global site-packages directory? For instance, on a shared host.

In all these cases, virtualenv can help you.

7. ###### Virualenv

- create an env: `virtualenv $ENV`

- activate the env: `source /path/to/ENV/bin/activate`
This will change your $PATH so its first entry is the virtualenv’s bin/ directory.  

If you directly run a script or the python interpreter from the virtualenv’s bin/ directory (e.g. `path/to/ENV/bin/pip` or `/path/to/ENV/bin/python-script.py`) then **sys.path** will automatically be set to use the Python libraries associated with the virtualenv. **But, unlike the activation scripts, the environment variables PATH and VIRTUAL_ENV will not be modified.** This means that if your Python script uses e.g. subprocess to run another Python script (e.g. via a #!/usr/bin/env python shebang line) the second script may **not be executed with the same Python binary as the first** nor have the same libraries available to it. To avoid this happening your first script will need to modify the environment variables in the same manner as the activation scripts, before the second script is executed.

- To undo these changes to your path (and prompt), just run: `deactivate`

- Virtual environments are tied to specific versions of Python. At the time a virtual environment is created, you can set the associated Python binary with virtualenv’s --python option: `virtualenv -p PYTHON_EXE, --python=PYTHON_EXE`

>[!Link]
> 1. [About virtualenv](https://virtualenv.pypa.io/en/latest/reference/)
> 2. [Automate the Boring Stuff with Python: Practical Programming for Total Beginners](https://www.amazon.com/dp/1593275994/ref=sr_1_1?keywords=Automate+the+Boring+Stuff+with+Python%3A+Practical+Programming+in+book&qid=1562578810&sr=8-1#customerReviews)

