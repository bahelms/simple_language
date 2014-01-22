require_relative "simple_semantics"

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

statement2 = Sequence.new(
  Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
  Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
)

env = { x: Number.new(1) }
env2 = {}

puts "Small Step Semantics"
Machine.new(statement, env).run

puts

puts "Big Step Semantics"
puts statement.evaluate(env)

