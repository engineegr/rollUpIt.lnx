# Typescript

## Basic

Typescript uses project configuration to set a number of compile options.

`tsc --init` - produces config file

	{
    	"compilerOptions": {
        	"target": "ES3",
        	"module": "commonjs",
        	"strict": true,
        	"esModuleInterop": true,
        	"skipLibCheck": true,
        	"forceConsistentCasingInFileNames": true
		} 
	}


`tsc -w` - watches any project changes and recomplie .js files

### Types

* string
* boolean
* number
* array

> Examples
> 
		var myBoolean : boolean = true;
		var myNumber : number = 1234;
		var myStringArray : string[] = [`first`, `second`, `third`];	

Typescript uses type inferring when there is no type declaration:

		var myString = "Heisenberg";
		var myNumber = 1234;
		myString = myNumber # causes TS2322	

### Duck typing

If two object has the same properties and methods then they belong to the same type.

		var nameIdObject = { name: "myName", id: 1, print() { } };
		nameIdObject = { id: 2, name: "anotherName", print() { } };

Note that the type errors will occur if the name of a property, the type of a property, or the number of properties are not exactly the same when assigning a value to an object.

The following example won't generate any error because obj2 has all minimum suit of properties/methods relating to *obj1*

		var obj1 = { id: 1, print() { } };
		var obj2 = { id: 2, print() { }, select() { } }
		obj1 = obj2;
		// obj2 = obj1;


Remember that the duck typing examples used here are also using inferred typing, so the type of an object is inferred from *when it is first assigned*.

### Functions

Functions can declare argument type and return value type:

		function calculate(var1:number, var2:number, var3: number) : number {	
			return (var1 * var2) + var3;
		}
		
		console.log(calculate(1, 3, 4));
		
		function calculate2(var1:number, var2:number, var3: number) : void {	
			console.log((var1 * var2) + var3);
		}
		
		console.log(calculate2(1, 3, 4));

### Debugging

To debug code we have to add *sourceMap: true* property to our *tsconfig.json* file. The VS Code editor, therefore, needs to know how to map the executing JavaScript code back to our TypeScript source. This is what the .map file is used for.

### External Javascript libs

So how does TypeScript enforce strict type checking on external JavaScript libraries? 
TypeScript uses files known as declaration files as a sort of header file, similar to languages such as C++, in order to superimpose strong typing on existing JavaScript libraries. These declaration files, which have a .d.ts extension, hold information that describes the available functions and variables that a library exposes, along with their associated type annotations.  

## Type system

### Any
For backward compatibility with JS Typescript involves `any` type:

		var item1: any = { id: 1, name: "item1" }
		item1 = { id: 2 };

### Explicit casting
