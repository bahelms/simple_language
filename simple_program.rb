require_relative "simple_semantics"

puts "Small Step Semantics"
statement = While.new(
  LessThan.new(Variable.new(:x), Number.new(5)),
  Assign.new(
    :x, 
    Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Variable.new(:x)
    )
  )
)
env = { x: Number.new(1) }

# Execute
Machine.new(statement, env).run

puts "------------------------------------------------------"
puts
puts "------------------------------------------------------"

puts "Big Step Semantics"
statement = Sequence.new(
  Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
  Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
)
env = {}

# Execute
puts statement.evaluate(env)

puts "------------------------------------------------------"
puts
puts "------------------------------------------------------"

puts "Denotational Semantics"
statement = LessThan.new(
  Add.new(Variable.new(:x), Number.new(1)), Number.new(3)
)
env = {x: 3}

# Execute
puts eval(statement.to_ruby).call(env)
