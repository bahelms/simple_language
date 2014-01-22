This is the implementation of the Simple programming language from 
Understanding Computation by Tom Stuart, and also an example program using
the language.

#### Small Step Semantics
A virtual machine is used to iteratively reduce each step.
Expressions reduce to further expressions and finally a value.
Statements reduce to do-nothing and modify the environment.

#### Big Step Semantics
No machine is needed. Just the evaluate method, which recursively finds the
end point.
